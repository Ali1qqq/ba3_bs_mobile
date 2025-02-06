import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill_items_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs_mobile/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs_mobile/core/i_controllers/i_pluto_controller.dart';
import 'package:ba3_bs_mobile/core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/dialogs/e_invoice_dialog_content.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/helper/mixin/pdf_base.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bond/ui/screens/entry_bond_details_screen.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../../materials/controllers/material_controller.dart';
import '../../../materials/data/models/materials/material_model.dart';
import '../../../materials/service/mat_statement_generator.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/all_bills_controller.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/invoice_record_model.dart';
import '../../ui/widgets/bill_shared/bill_header_field.dart';

class BillDetailsService with PdfBase, EntryBondsGenerator, MatsStatementsGenerator, FloatingLauncher {
  final IPlutoController<InvoiceRecordModel> plutoController;
  final IBillController billController;

  BillDetailsService(this.plutoController, this.billController);

  BillModel? createBillModel({
    BillModel? billModel,
    required BillTypeModel billTypeModel,
    required String billCustomerId,
    required String billSellerId,
    required String? billNote,
    required int billPayType,
    required DateTime billDate,
    required double billFirstPay,
  }) {
    return BillModel.fromBillData(
      billModel: billModel,
      billTypeModel: billTypeModel,
      status: RoleItemType.viewBill.status,
      note: billNote,
      billCustomerId: billCustomerId,
      billSellerId: billSellerId,
      billPayType: billPayType,
      billDate: billDate,
      billFirstPay: billFirstPay,
      billTotal: plutoController.calculateFinalTotal,
      billVatTotal: plutoController.computeTotalVat,
      billWithoutVatTotal: plutoController.computeBeforeVatTotal,
      billGiftsTotal: plutoController.computeGifts,
      billDiscountsTotal: plutoController.computeDiscounts,
      billAdditionsTotal: plutoController.computeAdditions,
      billRecordsItems: plutoController.generateRecords,
    );
  }

  void launchFloatingEntryBondDetailsScreen({required BuildContext context, required BillModel billModel}) {
    if (!hasModelId(billModel.billId)) return;

    // final creator = EntryBondCreatorFactory.resolveEntryBondCreator(billModel);
    //
    // final entryBondModel = creator.createEntryBond(
    //   isSimulatedVat: true,
    //   originType: EntryBondType.bill,
    //   model: billModel,
    // );

    final entryBondModel = createSimulatedVatEntryBond(billModel);

    launchFloatingWindow(
      context: context,
      minimizedTitle: 'سند خاص ب ${BillType.byLabel(billModel.billTypeModel.billTypeLabel!).value}',
      floatingScreen: EntryBondDetailsScreen(entryBondModel: entryBondModel),
    );
  }

  Future<void> handleDeleteSuccess({
    required BillModel billModel,
    required BillSearchController billSearchController,
    bool fromBillById = false,
  }) async {
    // Only fetchBills if open bill details by bill id from AllBillsScreen
    if (fromBillById) {
      await read<AllBillsController>().fetchAllBillsByType(billModel.billTypeModel);
      Get.back();
    } else {
      billSearchController.removeBill(billModel);
    }

    AppUIUtils.onSuccess('تم حذف الفاتورة بنجاح!');

    if (billModel.status == Status.approved && billModel.billTypeModel.billPatternType!.hasMaterialAccount) {
      entryBondController.deleteEntryBondModel(entryId: billModel.billId!);
    }

    if (billModel.status == Status.approved) {
      deleteMatsStatementsModels(billModel);
    }
  }

  Future<void> handleUpdateBillStatusSuccess({
    required BillModel updatedBillModel,
    required BillSearchController billSearchController,
  }) async {
    AppUIUtils.onSuccess('تم القبول بنجاح');
    billSearchController.updateBill(updatedBillModel);

    if (updatedBillModel.status == Status.approved && updatedBillModel.billTypeModel.billPatternType!.hasMaterialAccount) {
      createAndStoreEntryBond(model: updatedBillModel);

      // final creator = EntryBondCreatorFactory.resolveEntryBondCreator(updatedBillModel);
      //
      // entryBondController.saveEntryBondModel(
      //   entryBondModel: creator.createEntryBond(
      //     isSimulatedVat: false,
      //     originType: EntryBondType.bill,
      //     model: updatedBillModel,
      //   ),
      // );
    }

    if (updatedBillModel.status == Status.approved) {
      generateAndSaveMatsStatements(
        sourceModels: [updatedBillModel],
        onProgress: (progress) {
          log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );
    }
  }

  Map<String, AccountModel> findModifiedBillTypeAccounts({required BillModel previousBill, required BillModel currentBill}) {
    // Extract accounts from the bill type models or default to empty maps
    final previousAccounts = previousBill.billTypeModel.accounts ?? {};
    final currentAccounts = currentBill.billTypeModel.accounts ?? {};

    // Identify accounts that are present in both bills but have changed
    final Map<String, AccountModel> modifiedAccounts = Map.fromEntries(
      previousAccounts.entries.where((MapEntry<Account, AccountModel> previousAccount) {
        final currentAccountModel = currentAccounts[previousAccount.key];
        return currentAccountModel != null && currentAccountModel != previousAccount.value;
      }).map(
        // Use the account key's label for the map
        (entry) => MapEntry(entry.key.label, entry.value),
      ),
    );

    // Log modified accounts
    log('Modified accounts count: ${modifiedAccounts.length}');
    modifiedAccounts.forEach(
      (key, account) => log('Account Key: $key, Account Model: ${account.toJson()}'),
    );

    return modifiedAccounts;
  }

  Map<String, List<BillItem>> findDeletedMaterials({required BillModel previousBill, required BillModel currentBill}) {
    final previousGroupedItems = previousBill.items.itemList.groupBy((item) => item.itemGuid);
    final currentGroupedItems = currentBill.items.itemList.groupBy((item) => item.itemGuid);

    return Map.fromEntries(
      previousGroupedItems.entries.where(
        (entry) => !currentGroupedItems.containsKey(entry.key),
      ),
    );
  }

  ({List<BillItem> newItems, List<BillItem> deletedItems, List<BillItem> updatedItems})? findBillItemChanges({
    required List<BillItem> previousItems,
    required List<BillItem> currentItems,
  }) {
    // Merge repeated items in the previous list.
    final mergedPrevious = previousItems.merge();

    // Merge repeated items in the current list.
    final mergedCurrent = currentItems.merge();

    // Use extension methods to determine differences between the merged lists.
    final newItems = mergedCurrent.subtract(mergedPrevious, (item) => item.itemGuid);
    final deletedItems = mergedPrevious.subtract(mergedCurrent, (item) => item.itemGuid);

    // Find updated items among common items.
    // Identify updated items with adjusted quantities.
    final updatedItems = mergedCurrent.quantityDiff(
      mergedPrevious,
      (item) => item.itemGuid, // Key selector
      (item) => item.itemQuantity, // Quantity selector
      (item, difference) => item.copyWith(itemQuantity: difference), // Update quantity
    );

    return (newItems: newItems, deletedItems: deletedItems, updatedItems: updatedItems);
  }

  _handelUpdate({
    required Map<String, AccountModel> modifiedBillTypeAccounts,
    required BillModel previousBill,
    required BillModel currentBill,
  }) {
    modifiedBillTypeAccounts = findModifiedBillTypeAccounts(previousBill: previousBill, currentBill: currentBill);

    if (hasModelId(currentBill.billId) &&
        hasModelItems(currentBill.items.itemList) &&
        hasModelId(previousBill.billId) &&
        hasModelItems(previousBill.items.itemList)) {
      generateAndSendPdf(
        fileName: AppStrings.updatedBill,
        itemModel: [previousBill, currentBill],
      );
    }
  }

// Updated handleSaveOrUpdateSuccess method.
  Future<void> handleSaveOrUpdateSuccess({
    BillModel? previousBill,
    required BillModel currentBill,
    required BillSearchController billSearchController,
    required bool isSave,
  }) async {
    // 1. Display the success message.
    _showSuccessMessage(isSave);

    // 2. Prepare containers for modified accounts and deleted materials.
    final modifiedBillTypeAccounts = <String, AccountModel>{};

    ({List<BillItem> newItems, List<BillItem> deletedItems, List<BillItem> updatedItems})? itemChanges;

    // 3. Process the bill: add if new, update if modifying.
    if (isSave) {
      _handleAdd(currentBill);
    } else {
      // Process update and compute the differences between bill items.
      itemChanges = _processUpdate(
        previousBill: previousBill!,
        currentBill: currentBill,
        modifiedBillTypeAccounts: modifiedBillTypeAccounts,
      );
    }

    // 4. Update the bill search controller.
    _updateBillSearchController(billSearchController, currentBill);

    // 5. Create an entry bond if the bill is approved and its pattern requires a material account.
    if (_shouldCreateEntryBond(currentBill)) {
      createAndStoreEntryBond(
        modifiedAccounts: modifiedBillTypeAccounts,
        model: currentBill,
      );
    }

    // 6. Determine whether to generate a material statement.
    final shouldGenerateMatStatement = _determineIfShouldGenerateMatStatement(isSave, currentBill, itemChanges);

    // For updates, extract the list of updated materials (or an empty list for a new bill).
    final updatedMaterials = isSave ? <BillItem>[] : (itemChanges?.updatedItems ?? []);

    final deletedMaterials = isSave ? <BillItem>[] : (itemChanges?.deletedItems ?? []);

    // 7. Generate and save the material statement if the bill is approved and changes exist.
    if (currentBill.status == Status.approved && shouldGenerateMatStatement) {
      generateAndSaveMatStatement(
        model: currentBill,
        deletedMaterials: deletedMaterials,
        updatedMaterials: updatedMaterials,
      );
    }
  }

  /// Displays a success message based on the operation type.
  void _showSuccessMessage(bool isSave) {
    final message = isSave ? 'تم حفظ الفاتورة بنجاح!' : 'تم تعديل الفاتورة بنجاح!';
    AppUIUtils.onSuccess(message);
  }

  /// Updates the bill search controller with the current bill.
  void _updateBillSearchController(BillSearchController controller, BillModel bill) {
    controller.updateBill(bill);
  }

  /// Processes an update by calling the update handler and computing item changes.
  ({List<BillItem> newItems, List<BillItem> deletedItems, List<BillItem> updatedItems})? _processUpdate({
    required BillModel previousBill,
    required BillModel currentBill,
    required Map<String, AccountModel> modifiedBillTypeAccounts,
  }) {
    // Update the bill (PDF generation etc.) and collect modifications.
    _handelUpdate(
      modifiedBillTypeAccounts: modifiedBillTypeAccounts,
      previousBill: previousBill,
      currentBill: currentBill,
    );

    // Compute the differences between the previous and current bill items.
    final changes = findBillItemChanges(previousItems: previousBill.items.itemList, currentItems: currentBill.items.itemList);

    return changes;
  }

  /// Determines whether a material statement should be generated.
  /// For new bills, a statement is generated if there is at least one item.
  /// For updates, the statement is generated only if there are new, deleted, or updated items.
  bool _determineIfShouldGenerateMatStatement(
    bool isSave,
    BillModel currentBill,
    ({List<BillItem> newItems, List<BillItem> deletedItems, List<BillItem> updatedItems})? itemChanges,
  ) {
    if (isSave) {
      return currentBill.items.itemList.isNotEmpty;
    } else {
      return (itemChanges?.newItems.isNotEmpty ?? false) ||
          (itemChanges?.deletedItems.isNotEmpty ?? false) ||
          (itemChanges?.updatedItems.isNotEmpty ?? false);
    }
  }

  /// Adds a new bill by marking it as saved and generating its PDF.
  void _handleAdd(BillModel currentBill) {
    billController.updateIsBillSaved = true;

    if (hasModelId(currentBill.billId) && hasModelItems(currentBill.items.itemList)) {
      generateAndSendPdf(
        fileName: AppStrings.newBill,
        itemModel: currentBill,
      );
    }
  }

  /// Returns `true` if the bill is approved and its pattern requires a material account.
  bool _shouldCreateEntryBond(BillModel bill) => bill.status == Status.approved && bill.billTypeModel.billPatternType!.hasMaterialAccount;

  showEInvoiceDialog(BillModel billModel, BuildContext context) {
    if (!hasModelId(billModel.billId)) return;

    OverlayService.showDialog(
      context: context,
      title: 'Invoice QR Code',
      content: EInvoiceDialogContent(
        billController: billController,
        billId: billModel.billId!,
      ),
      onCloseCallback: () {
        log('E-Invoice dialog closed.');
      },
    );
  }

  showFirstPayDialog(BuildContext context, TextEditingController firstPayController) {
    OverlayService.showDialog(
      color: AppColors.backGroundColor,
      context: context,
      height: 200,
      showDivider: true,
      title: 'المزيد',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 5,
        children: [
          TextAndExpandedChildField(
            label: 'الدفعة الاولى',
            child: CustomTextFieldWithoutIcon(
              textEditingController: firstPayController,
            ),
          ),
          AppButton(title: 'تم', onPressed: () => OverlayService.back())
        ],
      ),
    );
  }

  Future<void> showBarCodeScanner({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required IPlutoController plutoController,
    required BillTypeModel billTypeModel,
  }) async {
    final barCode = await SimpleBarcodeScanner.scanBarcode(context, scanFormat: ScanFormat.ONLY_BARCODE) ?? '';
    // String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);

    _handleBarCodeScan(stateManager: stateManager, plutoController: plutoController, barCode: barCode, billTypeModel: billTypeModel);
  }

  void _handleBarCodeScan({
    required PlutoGridStateManager stateManager,
    required IPlutoController plutoController,
    required String barCode,
    required BillTypeModel billTypeModel,
  }) async {
    final materialController = read<MaterialController>();
    final searchedMaterials = materialController.searchOfProductByText(barCode);

    final MaterialModel? selectedMaterial = searchedMaterials.length == 1 ? searchedMaterials.first : null;

    plutoController.updateWithSelectedMaterial(
        stateManager: stateManager, materialModel: selectedMaterial, plutoController: plutoController, billTypeModel: billTypeModel);
  }
}
