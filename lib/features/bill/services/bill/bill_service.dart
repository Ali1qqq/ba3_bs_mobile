import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_items_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_model_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs_mobile/core/i_controllers/i_pluto_controller.dart';
import 'package:ba3_bs_mobile/core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_model.dart';
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
import '../../../../core/network/api_constants.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../bond/ui/screens/entry_bond_details_screen.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../../materials/service/mat_statement_generator.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/all_bills_controller.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/invoice_record_model.dart';
import '../../ui/widgets/bill_shared/bill_header_field.dart';

class BillDetailsService with PdfBase, EntryBondsGenerator, MatsStatementsGenerator, FloatingLauncher {
  final IPlutoController<InvoiceRecordModel> plutoController;

  final BillDetailsController billDetailsController;

  BillDetailsService({
    required this.plutoController,
    required this.billDetailsController,
  });

  BillModel? createBillModel({
    BillModel? billModel,
    required BillTypeModel billTypeModel,
    required String billCustomerId,
    required String billAccountId,
    required String billSellerId,
    required String? billNote,
    required String? orderNumber,
    required String? customerPhone,
    required int billPayType,
    required DateTime billDate,
    required double billFirstPay,
    required bool freeBill,
  }) =>
      BillModel.fromBillData(
        billModel: billModel,
        billTypeModel: billTypeModel,
        status: RoleItemType.viewBill.status,
        note: billNote,
        orderNumber: orderNumber,
        customerPhone: customerPhone,
        billCustomerId: billCustomerId,
        billAccountId: billAccountId,
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
        billRecords: plutoController.generateRecords,
        freeBill: freeBill,
      );

  void launchFloatingEntryBondDetailsScreen({required BuildContext context, required BillModel billModel}) {
    if (!hasModelId(billModel.billId)) return;

    final entryBondModel = createSimulatedVatEntryBond(billModel);

    launchFloatingWindow(
      context: context,
      minimizedTitle: 'سند خاص ب ${BillType.byLabel(billModel.billTypeModel.billTypeLabel!).value}',
      floatingScreen: EntryBondDetailsScreen(entryBondModel: entryBondModel),
    );
  }

  /// bill delete number = 5
  /// lastBillNumber = 3
  /// decrementedBillNumber = 2
  Future<void> handleDeleteSuccess({required BillModel billToDelete, required BillSearchController billSearchController}) async {
    log('billSearchController.isTail: ${billSearchController.isTail}');
    log('currentBillIndex: ${billSearchController.currentBillIndex}');
    log('billSearchController.bills.length: ${billSearchController.bills.length}');
    log('isLastValidBill(billToDelete): ${billSearchController.isLastValidBill(billToDelete)}');

    if (billToDelete.isSellRelated) {
      await _updateSoldSerialNumbers(billToDelete);
      await billDetailsController.deleteSellSerialTransactions(billToDelete);
    } else if (billToDelete.isPurchaseRelated) {
      await billDetailsController.deleteBuySerialTransactions(billToDelete);
    }

    if (billSearchController.isLastValidBill(billToDelete)) {
      final decrementedBillNumber = (billToDelete.billDetails.previous ?? 0) - billToDelete.billDetails.billNumber!;
      log('decrementedBillNumber: $decrementedBillNumber');

      await billDetailsController.decrementLastNumber(
        ApiConstants.bills,
        billToDelete.billTypeModel.billTypeLabel!,
        number: decrementedBillNumber,
      );
    }

    // 1. Update previous and next bill references.
    await _updatePreviousBillLink(billToDelete, billSearchController);

    await _updateNextBillLink(billToDelete, billSearchController);

    // 2. Remove the bill locally from the search controller
    billSearchController.removeBill(billToDelete);

    // 3. Show success message.
    AppUIUtils.onSuccess('تم حذف الفاتورة بنجاح!');

    // 4. Clean up bonds/mats statements if this is an approved bill with materials
    if (billToDelete.status == Status.approved) {
      _handleApprovedBillDeletions(billToDelete);
    }
  }

  /// Updates the sold serial numbers by setting their `sold` status to false.
  Future<void> _updateSoldSerialNumbers(BillModel billToDelete) async {
    final materialController = read<MaterialController>();

    for (final billItem in billToDelete.items.itemList) {
      final materialModel = materialController.getMaterialById(billItem.itemGuid);
      final soldSerialNumber = billItem.soldSerialNumber;

      if (materialModel?.serialNumbers == null) {
        continue; // Skip if the material is not found or has no serial numbers
      }

      final updatedSerialNumbers = Map<String, bool>.from(materialModel!.serialNumbers!);

      if (soldSerialNumber != null && updatedSerialNumbers.containsKey(soldSerialNumber)) {
        updatedSerialNumbers[soldSerialNumber] = false; // Mark as unsold

        // Apply the update to the material model
        materialController.updateMaterialWithChanges(
          materialModel.copyWith(serialNumbers: updatedSerialNumbers),
        );

        log('✅ Serial number [$soldSerialNumber] of material (${materialModel.matName}) marked as unsold.');
      }
    }
  }

  /// Updates the reference of the previous bill to maintain correct linkage.
  Future<void> _updatePreviousBillLink(BillModel billToDelete, BillSearchController billSearchController) async {
    final previousNumber = billToDelete.billDetails.previous;
    if (previousNumber == null) return;

    final previousBillResult = await read<AllBillsController>().fetchBillByNumber(
      billTypeModel: billToDelete.billTypeModel,
      billNumber: previousNumber,
    );

    await previousBillResult.fold(
      (failure) => AppUIUtils.onFailure('فشل في جلب الفاتورة السابقة: ${failure.message}'),
      (previousBills) async {
        if (previousBills.isEmpty) return;

        final oldPrevBill = previousBills.first;

        if (oldPrevBill.billDetails.next == billToDelete.billDetails.billNumber) {
          final BillModel updatedPrevBill;

          if (billSearchController.isLastValidBill(billToDelete)) {
            log('_updatePreviousBillLink isLastValidBill(billToDelete): true');

            updatedPrevBill = oldPrevBill.copyWith(
              billDetails: oldPrevBill.billDetails.copyWith(next: null),
            );
          } else {
            log('_updatePreviousBillLink isLastValidBill(billToDelete): false');

            updatedPrevBill = oldPrevBill.copyWith(
              billDetails: oldPrevBill.billDetails.copyWith(next: billToDelete.billDetails.next),
            );
          }

          final updatedPrevBillLocal = oldPrevBill.copyWith(
            billDetails: oldPrevBill.billDetails.copyWith(next: billToDelete.billDetails.next ?? billToDelete.billDetails.billNumber! + 1),
          );

          log('updatedPrevBill: ${updatedPrevBill.billDetails.next}');
          log('updatedPrevBillLocal: ${updatedPrevBillLocal.billDetails.next}');

          final updateResult = await billDetailsController.updateOnly(updatedPrevBill);
          updateResult.fold(
            (failure) => AppUIUtils.onFailure(failure.message),
            (_) => _updateBillSearchController(billSearchController, updatedPrevBillLocal, '_updatePreviousBillLink'),
          );
          // await _updateAndNotifyBillSearch(updatedPrevBill, billSearchController, '_updateAndNotifyBillSearch _updatePreviousBillLink');
        }
      },
    );
  }

  /// Updates the reference of the next bill to maintain correct linkage.
  Future<void> _updateNextBillLink(BillModel billToDelete, BillSearchController billSearchController) async {
    final nextNumber = billToDelete.billDetails.next;

    if (nextNumber == null) return;

    if (billSearchController.isLastValidBill(billToDelete)) {
      final oldNextBill = billSearchController.getBillByNumber(nextNumber);

      final updatedNextBill = oldNextBill.copyWith(
        billDetails: oldNextBill.billDetails.copyWith(previous: billToDelete.billDetails.previous),
      );
      _updateBillSearchController(billSearchController, updatedNextBill, '_updateNextBillLink isLastValidBill');

      return;
    }

    final nextBillResult = await read<AllBillsController>().fetchBillByNumber(
      billTypeModel: billToDelete.billTypeModel,
      billNumber: nextNumber,
    );

    await nextBillResult.fold(
      (failure) => AppUIUtils.onFailure('فشل في جلب الفاتورة اللاحقة: ${failure.message}'),
      (nextBills) async {
        if (nextBills.isEmpty) return;

        final oldNextBill = nextBills.first;

        if (oldNextBill.billDetails.previous == billToDelete.billDetails.billNumber) {
          final updatedNextBillLocal = oldNextBill.copyWith(
            billDetails: oldNextBill.billDetails.copyWith(
              previous: billToDelete.billDetails.previous,
              next: oldNextBill.billDetails.next ?? billToDelete.billDetails.next! + 1,
            ),
          );

          final updatedNextBill = oldNextBill.copyWith(
            billDetails: oldNextBill.billDetails.copyWith(previous: billToDelete.billDetails.previous),
          );

          final updateResult = await billDetailsController.updateOnly(updatedNextBill);
          updateResult.fold(
            (failure) => AppUIUtils.onFailure(failure.message),
            (_) => _updateBillSearchController(billSearchController, updatedNextBillLocal, '_updateNextBillLink'),
          );

          //  await _updateAndNotifyBillSearch(updatedNextBill, billSearchController, '_updateAndNotifyBillSearch _updateNextBillLink');
        }
      },
    );
  }

  /// Updates a bill in the database and refreshes the search controller.
  Future<void> _updateAndNotifyBillSearch(BillModel updatedBill, BillSearchController billSearchController, String from) async {
    final updateResult = await billDetailsController.updateOnly(updatedBill);
    updateResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) => _updateBillSearchController(billSearchController, updatedBill, from),
    );
  }

  /// Removes the related bond and statements if the bill is approved
  /// and the pattern type requires a material account.
  void _handleApprovedBillDeletions(BillModel billModel) {
    if (billModel.billTypeModel.billPatternType!.hasMaterialAccount) {
      read<EntryBondController>().deleteEntryBondModel(entryId: billModel.billId!, sourceNumber: billModel.billDetails.billNumber!);
    }
    deleteMatsStatementsModels(billModel);
  }

  Future<void> handleUpdateBillStatusSuccess({
    required BillModel updatedBillModel,
    required BillSearchController billSearchController,
  }) async {
    AppUIUtils.onSuccess('تم القبول بنجاح');
    billSearchController.updateBill(updatedBillModel, 'handleUpdateBillStatusSuccess');

    if (updatedBillModel.status == Status.approved && updatedBillModel.billTypeModel.billPatternType!.hasMaterialAccount) {
      createAndStoreEntryBond(model: updatedBillModel, sourceNumbers: [updatedBillModel.billDetails.billNumber!], isSave: false);
    }

    if (updatedBillModel.status == Status.approved) {
      createAndStoreMatsStatements(
        sourceModels: [updatedBillModel],
        onProgress: (progress) {
          log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );
    }
  }

  Map<String, AccountModel> findModifiedBillTypeAccounts({required BillModel previousBill, required BillModel currentBill}) {
    log('currentBill ${currentBill.billId}', name: 'findModifiedBillTypeAccounts');

    // Extract accounts from the bill type models or default to empty maps
    final previousAccounts = previousBill.billTypeModel.accounts ?? {};
    final currentAccounts = currentBill.billTypeModel.accounts ?? {};

    // Identify accounts that are present in both bills but have changed
    final modifiedBillTypeAccounts = Map.fromEntries(
      previousAccounts.entries.where(
        (MapEntry<Account, AccountModel> previousAccount) {
          final currentAccountModel = currentAccounts[previousAccount.key];
          return currentAccountModel != null && currentAccountModel != previousAccount.value;
        }, // Use the account key's label for the map
      ).map(
        (entry) => MapEntry(entry.key.label, entry.value),
      ),
    );

    // Log modified accounts
    log('Modified accounts count: ${modifiedBillTypeAccounts.length}');
    modifiedBillTypeAccounts.forEach(
      (key, account) => log('Account Key: $key, Account Model: ${account.toJson()}'),
    );

    return modifiedBillTypeAccounts;
  }

  Map<String, List<BillItem>> findDeletedMaterials({required BillModel previousBill, required BillModel currentBill}) {
    final previousGroupedItems = previousBill.items.itemList.groupBy((item) => item.itemGuid);
    final currentGroupedItems = currentBill.items.itemList.groupBy((item) => item.itemGuid);

    return Map.fromEntries(previousGroupedItems.entries.where((entry) => !currentGroupedItems.containsKey(entry.key)));
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

  Map<String, AccountModel> _handelModifiedAccountsUpdate({required BillModel previousBill, required BillModel currentBill}) {
    final Map<String, AccountModel> modifiedAccounts = findModifiedBillTypeAccounts(previousBill: previousBill, currentBill: currentBill);

    if (hasModelId(currentBill.billId) &&
        hasModelItems(currentBill.items.itemList) &&
        hasModelId(previousBill.billId) &&
        hasModelItems(previousBill.items.itemList)) {
      generatePdfAndSendToEmail(
        fileName: AppStrings.updatedBill.tr,
        itemModel: [previousBill, currentBill],
      );
    }
    return modifiedAccounts;
  }

  // Updated handleSaveOrUpdateSuccess method.
  Future<void> handleSaveOrUpdateSuccess({
    BillModel? previousBill,
    required BillModel currentBill,
    required BillSearchController billSearchController,
    required bool isSave,
    required bool withPrint,
    required BuildContext context,
  }) async {
    // 1. Display the success message.
    _showSuccessMessage(isSave);

    // 2. Prepare containers for modified accounts and deleted materials.
    Map<String, AccountModel> modifiedBillTypeAccounts = <String, AccountModel>{};

    ({List<BillItem> newItems, List<BillItem> deletedItems, List<BillItem> updatedItems})? itemChanges;

    // 3. Process the bill: add if new, update if modifying.
    if (isSave) {
      _handleAdd(savedBill: currentBill, billSearchController: billSearchController);
    } else {
      // Update the bill (PDF generation etc.) and collect modifications.
      modifiedBillTypeAccounts = _handelModifiedAccountsUpdate(previousBill: previousBill!, currentBill: currentBill);

      // Process update and compute the differences between bill items.
      itemChanges = _processUpdate(previousBill: previousBill, currentBill: currentBill);
    }

    // 4. Update the bill search controller.
    if (isSave) {
      _updateBillSearchController(
        billSearchController,
        currentBill.copyWith(
          billDetails: currentBill.billDetails.copyWith(
            next: billSearchController.currentBill.billDetails.next,
          ),
        ),
        'handleSaveOrUpdateSuccess isSave $isSave',
      );
    } else {
      _updateBillSearchController(
        billSearchController,
        currentBill,
        'handleSaveOrUpdateSuccess isSave $isSave',
      );
    }
    if (withPrint) {
      billDetailsController.printBill(
        context: context,
        billModel: currentBill,
        invRecords: plutoController.generateRecords,
      );
    }

    //  log('if Modified accounts count: ${modifiedBillTypeAccounts.length}');
    // 5. Create an entry bond if the bill is approved and its pattern requires a material account.
    if (_shouldCreateEntryBond(currentBill)) {
      log('createAndStoreEntryBond', name: '_shouldCreateEntryBond');
      createAndStoreEntryBond(
        modifiedAccounts: modifiedBillTypeAccounts,
        model: currentBill,
        isSave: isSave,
        sourceNumbers: [currentBill.billDetails.billNumber!],
      );
    }

    // 6. Determine whether to generate a material statement.
    final shouldGenerateMatStatement = _determineIfShouldGenerateMatStatement(isSave, currentBill, itemChanges);

    // For updates, extract the list of updated materials (or an empty list for a new bill).
    final updatedMaterials = isSave ? <BillItem>[] : (itemChanges?.updatedItems ?? []);

    final deletedMaterials = isSave ? <BillItem>[] : (itemChanges?.deletedItems ?? []);

    // 7. Generate and save the material statement if the bill is approved and changes exist.
    if (currentBill.status == Status.approved && shouldGenerateMatStatement) {
      createAndStoreMatStatement(
        model: currentBill,
        deletedMaterials: deletedMaterials,
        updatedMaterials: updatedMaterials,
      );
    }

    // 8. Save material serials.
    saveMaterialsSerials(currentBill);
  }

  Future<void> saveMaterialsSerials(BillModel savedBill) async {
    final Map<MaterialModel, List<TextEditingController>> buySerialsControllers = plutoController.buyMaterialsSerialsControllers;
    final Map<MaterialModel, List<TextEditingController>> sellSerialsControllers = plutoController.sellMaterialsSerialsControllers;

    log('BillTypeUtils.isPurchaseRelated(savedBill) ${savedBill.isPurchaseRelated}');

    final Map<MaterialModel, List<TextEditingController>> serialControllers =
        savedBill.isPurchaseRelated ? buySerialsControllers : sellSerialsControllers;

    if (serialControllers.isNotEmpty) {
      billDetailsController.saveSerialNumbers(savedBill, serialControllers);
    }
  }

  /// Displays a success message based on the operation type.
  void _showSuccessMessage(bool isSave) {
    final message = isSave ? 'تم حفظ الفاتورة بنجاح!' : 'تم تعديل الفاتورة بنجاح!';
    AppUIUtils.onSuccess(message);
  }

  /// Updates the bill search controller with the current bill.
  void _updateBillSearchController(BillSearchController controller, BillModel bill, String from) {
    controller.updateBill(bill, from);
  }

  /// Processes an update by calling the update handler and computing item changes.
  ({List<BillItem> newItems, List<BillItem> deletedItems, List<BillItem> updatedItems})? _processUpdate(
      {required BillModel previousBill, required BillModel currentBill}) {
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
  Future<void> _handleAdd({
    required BillModel savedBill,
    required BillSearchController billSearchController,
  }) async {
    // 1. Mark the bill as saved
    billDetailsController.updateIsBillSaved = true;

    // 2. If the bill has an ID and items, we generate & send a PDF
    if (_isValidBillForPdf(savedBill)) {
      generatePdfAndSendToEmail(
        fileName: AppStrings.newBill.tr,
        itemModel: savedBill,
      );
    }

    // 3. If there is no "previous" bill number, nothing more to do
    final previousBillNumber = savedBill.billDetails.previous;
    if (previousBillNumber == null) {
      return;
    }

    // 4. Fetch the previous bill
    final result = await read<AllBillsController>().fetchBillByNumber(
      billTypeModel: savedBill.billTypeModel,
      billNumber: previousBillNumber,
    );

    // 5. Handle the fetch result
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBills) => _updatePreviousBill(
        fetchedBills: fetchedBills,
        billSearchController: billSearchController,
        newBillNumber: savedBill.billDetails.billNumber,
      ),
    );
  }

  /// Returns true if [bill] has an ID and at least one item in its item list.
  /// This helps us decide whether to generate/send a PDF.
  bool _isValidBillForPdf(BillModel bill) {
    return hasModelId(bill.billId) && hasModelItems(bill.items.itemList);
  }

  bool hasClientPhoneNumber() {
    if (billDetailsController.customerPhoneController.text.isEmpty) {
      AppUIUtils.onFailure('يرجى إضافة رقم هاتف العميل!');
      return false;
    }
    return true;
  }

  /// Updates the 'next' field of the previously fetched bill if necessary.
  Future<void> _updatePreviousBill({
    required List<BillModel> fetchedBills,
    required BillSearchController billSearchController,
    required int? newBillNumber,
  }) async {
    // No bills or a null newBillNumber means we can’t update anything
    if (fetchedBills.isEmpty || newBillNumber == null) {
      return;
    }

    final previousBill = fetchedBills.first;

    // Assign 'next' = new bill number
    final updatedPreviousBill = previousBill.copyWith(
      billDetails: previousBill.billDetails.copyWith(next: newBillNumber),
    );

    await _updateAndNotifyBillSearch(updatedPreviousBill, billSearchController, '_updateAndNotifyBillSearch _updatePreviousBill');
  }

  /// Returns `true` if the bill is approved and its pattern requires a material account.
  bool _shouldCreateEntryBond(BillModel bill) => bill.status == Status.approved && bill.billTypeModel.billPatternType!.hasMaterialAccount;

  showEInvoiceDialog(BillModel billModel, BuildContext context) {
    if (!hasModelId(billModel.billId)) return;

    OverlayService.showDialog(
      context: context,
      title: 'Invoice QR Code',
      content: EInvoiceDialogContent(
        billDetailsController: billDetailsController,
        billId: billModel.billId!,
        billModel: billModel,
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

  ///  this only in mobile app
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