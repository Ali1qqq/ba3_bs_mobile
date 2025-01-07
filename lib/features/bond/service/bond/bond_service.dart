import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/pay_item_model.dart';
import 'package:ba3_bs_mobile/features/bond/service/bond/bond_pdf_generator.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/helper/mixin/floating_launcher.dart';
import '../../../../core/i_controllers/i_recodes_pluto_controller.dart';
import '../../../../core/i_controllers/pdf_base.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../controllers/bonds/all_bond_controller.dart';
import '../../controllers/bonds/bond_search_controller.dart';
import '../../controllers/entry_bond/entry_bond_controller.dart';
import '../../data/models/bond_model.dart';
import '../../ui/screens/entry_bond_details_screen.dart';
import 'bond_entry_bond_service.dart';

class BondService with PdfBase, BondEntryBondService, FloatingLauncher {
  final IRecodesPlutoController<PayItem> plutoController;
  final BondDetailsController bondController;

  BondService(this.plutoController, this.bondController);

  EntryBondController get entryBondController => read<EntryBondController>();

  void launchBondEntryBondScreen({required BuildContext context, required BondModel bondModel}) {
    final entryBondModel = createEntryBondModel(originType: EntryBondType.cheque, bondModel: bondModel);

    launchFloatingWindow(
      context: context,
      minimizedTitle: 'سند خاص ب ${BondType.byTypeGuide(bondModel.payTypeGuid!).value}',
      floatingScreen: EntryBondDetailsScreen(entryBondModel: entryBondModel),
    );
  }

  BondModel? createBondModel({
    BondModel? bondModel,
    required BondType bondType,
    required String payAccountGuid,
    required String payDate,
    String? note,
  }) =>
      BondModel.fromBondData(
        bondModel: bondModel,
        bondType: bondType,
        note: note,
        payAccountGuid: payAccountGuid,
        payDate: payDate,
        bondRecordsItems: plutoController.generateRecords,
      );

  Future<void> handleDeleteSuccess(BondModel bondModel, BondSearchController bondSearchController, [fromBondById]) async {
    // Only fetchBonds if open bond details by bond id from AllBondsScreen
    if (fromBondById) {
      await read<AllBondsController>().fetchAllBondsByType(BondType.byTypeGuide(bondModel.payTypeGuid!));
      // await read<AllBondsController>().fetchAllBondsLocal();
      Get.back();
    } else {
      bondSearchController.removeBond(bondModel);
    }

    AppUIUtils.onSuccess('تم حذف السند بنجاح!');

    entryBondController.deleteEntryBondModel(entryId: bondModel.payGuid!);
  }

  Future<void> handleSaveOrUpdateSuccess({
    required BondModel bondModel,
    required BondDetailsController bondDetailsController,
    required BondSearchController bondSearchController,
    required bool isSave,
  }) async {
    final successMessage = isSave ? 'تم حفظ السند بنجاح!' : 'تم تعديل السند بنجاح!';

    AppUIUtils.onSuccess(successMessage);

    if (isSave) {
      bondDetailsController.updateIsBondSaved(true);
    } else {
      bondSearchController.updateBond(bondModel);
    }

    generateAndSendPdf(
      fileName: AppStrings.bond,
      itemModel: bondModel,
      itemModelId: bondModel.payGuid,
      items: bondModel.payItems.itemList,
      pdfGenerator: BondPdfGenerator(),
    );

    entryBondController.saveEntryBondModel(
      entryBondModel: createEntryBondModel(
        originType: EntryBondType.bond,
        bondModel: bondModel,
      ),
    );
  }

/*  Future<void> handleSaveSuccess(BondModel bondModel, BondDetailsController bondDetailsController) async {
    AppUIUtils.onSuccess('تم حفظ السند بنجاح!');

    bondDetailsController.updateIsBondSaved(true);

    generateAndSendPdf(
      fileName: AppStrings.bond,
      itemModel: bondModel,
      itemModelId: bondModel.payGuid,
      items: bondModel.payItems.itemList,
      pdfGenerator: BondPdfGenerator(),
    );
  }

  void handleUpdateSuccess(BondModel bondModel, BondSearchController bondSearchController) {
    AppUIUtils.onSuccess('تم تعديل السند بنجاح!');

    bondSearchController.updateBond(bondModel);

    generateAndSendPdf(
      fileName: AppStrings.bond,
      itemModel: bondModel,
      itemModelId: bondModel.payGuid,
      items: bondModel.payItems.itemList,
      pdfGenerator: BondPdfGenerator(),
    );
  }*/

  bool validateAccount(AccountModel? customerAccount) {
    if (customerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم الحساب!');
      return false;
    }
    return true;
  }
}
