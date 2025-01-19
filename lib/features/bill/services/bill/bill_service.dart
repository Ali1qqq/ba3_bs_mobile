import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs_mobile/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs_mobile/core/i_controllers/i_pluto_controller.dart';
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
import '../../../../core/i_controllers/pdf_base.dart';
import '../../../../core/services/entry_bond_creator/implementations/entry_bond_creator_factory.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../bond/ui/screens/entry_bond_details_screen.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../../materials/controllers/material_controller.dart';
import '../../../materials/data/models/material_model.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/all_bills_controller.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/invoice_record_model.dart';
import 'bill_pdf_generator.dart';

class BillDetailsService with PdfBase, FloatingLauncher {
  final IPlutoController<InvoiceRecordModel> plutoController;
  final IBillController billController;

  BillDetailsService(this.plutoController, this.billController);

  EntryBondController get entryBondController => read<EntryBondController>();

  BillModel? createBillModel({
    BillModel? billModel,
    required BillTypeModel billTypeModel,
    required String billCustomerId,
    required String billSellerId,
    required String? billNote,
    required int billPayType,
    required DateTime billDate,
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

    final creator = EntryBondCreatorFactory.resolveEntryBondCreator(billModel);

    final entryBondModel = creator.createEntryBond(
      isSimulatedVat: true,
      originType: EntryBondType.bill,
      model: billModel,
    );

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

    entryBondController.deleteEntryBondModel(entryId: billModel.billId!);
  }

  Future<void> handleUpdateBillStatusSuccess({
    required BillModel updatedBillModel,
    required BillSearchController billSearchController,
  }) async {
    AppUIUtils.onSuccess('تم القبول بنجاح');
    billSearchController.updateBill(updatedBillModel);

    if (updatedBillModel.status == Status.approved && updatedBillModel.billTypeModel.billPatternType!.hasCashesAccount) {
      final creator = EntryBondCreatorFactory.resolveEntryBondCreator(updatedBillModel);

      entryBondController.saveEntryBondModel(
        entryBondModel: creator.createEntryBond(
          isSimulatedVat: false,
          originType: EntryBondType.bill,
          model: updatedBillModel,
        ),
      );
    }
  }

  Future<void> handleSaveOrUpdateSuccess({
    required BillModel billModel,
    required BillSearchController billSearchController,
    required bool isSave,
  }) async {
    final successMessage = isSave ? 'تم حفظ الفاتورة بنجاح!' : 'تم تعديل الفاتورة بنجاح!';

    AppUIUtils.onSuccess(successMessage);

    if (isSave) {
      billController.updateIsBillSaved = true;
    } else {
      billSearchController.updateBill(billModel);
    }

    generateAndSendPdf(
      fileName: AppStrings.bill,
      itemModel: billModel,
      itemModelId: billModel.billId,
      items: billModel.items.itemList,
      pdfGenerator: BillPdfGenerator(),
    );

    if (billModel.status == Status.approved && billModel.billTypeModel.billPatternType!.hasMaterialAccount) {
      final creator = EntryBondCreatorFactory.resolveEntryBondCreator(billModel);

      entryBondController.saveEntryBondModel(
        entryBondModel: creator.createEntryBond(
          isSimulatedVat: false,
          originType: EntryBondType.bill,
          model: billModel,
        ),
      );
    }
  }

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

  Future<void> showBarCodeScanner({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required IPlutoController plutoController,
  }) async {
    final barCode = await SimpleBarcodeScanner.scanBarcode(context, scanFormat: ScanFormat.ONLY_BARCODE) ?? '';
    // String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel", false, ScanMode.DEFAULT);

    _handleBarCodeScan(
      stateManager: stateManager,
      plutoController: plutoController,
      barCode: barCode,
    );
  }

  void _handleBarCodeScan({
    required PlutoGridStateManager stateManager,
    required IPlutoController plutoController,
    required String barCode,
  }) async {
    final materialController = read<MaterialController>();
    final searchedMaterials = await materialController.searchOfProductByText(barCode);

    final MaterialModel? selectedMaterial = searchedMaterials.length == 1 ? searchedMaterials.first : null;

    plutoController.updateWithSelectedMaterial(
      stateManager: stateManager,
      materialModel: selectedMaterial,
      plutoController: plutoController,
    );
  }
}
