import 'package:ba3_bs_mobile/core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/helper/mixin/floating_launcher.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/helper/mixin/pdf_base.dart';
import '../../bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../bond/ui/screens/entry_bond_details_screen.dart';
import '../controllers/cheques/all_cheques_controller.dart';
import '../controllers/cheques/cheques_details_controller.dart';
import '../controllers/cheques/cheques_search_controller.dart';
import '../data/models/cheques_model.dart';

class ChequesDetailsService with PdfBase, EntryBondsGenerator, FloatingLauncher {
  void launchChequesEntryBondScreen({
    required BuildContext context,
    required ChequesModel chequesModel,
    required ChequesStrategyType chequesStrategyType,
  }) {
    // final creators = ChequesStrategyBondFactory.determineStrategy(chequesModel, type: chequesStrategyType);
    //
    // final EntryBondModel entryBondModel =
    //     creators.first.createEntryBond(model: chequesModel, originType: EntryBondType.cheque);

    final entryBondModel = createChequeEntryBondByStrategy(chequesModel, chequesStrategyType: chequesStrategyType);

    launchFloatingWindow(
      context: context,
      minimizedTitle: 'سند خاص ب ${ChequesType.byTypeGuide(chequesModel.chequesTypeGuid!).value}',
      floatingScreen: EntryBondDetailsScreen(entryBondModel: entryBondModel),
    );
  }

  ChequesModel? createChequesModel({
    ChequesModel? chequesModel,
    required ChequesType chequesType,
    required String chequesTypeGuid,
    required int chequesNum,
    required String chequesDate,
    required String chequesDueDate,
    required String chequesNote,
    required double chequesVal,
    required String chequesAccount2Guid,
    required String accPtr,
    required String accPtrName,
    required String chequesAccount2Name,
    required bool isPayed,
    required bool isRefund,
  }) {
    return ChequesModel.fromChequesData(
      chequesAccount2Name: chequesAccount2Name,
      accPtrName: accPtrName,
      accPtr: accPtr,
      chequesModel: chequesModel,
      chequesType: chequesType,
      chequesNote: chequesNote,
      chequesVal: chequesVal,
      chequesNum: chequesNum,
      chequesDueDate: chequesDueDate,
      chequesAccount2Guid: chequesAccount2Guid,
      chequesTypeGuid: chequesTypeGuid,
      chequesDate: chequesDate,
      isPayed: isPayed,
      isRefund: isRefund,
    );
  }

  Future<void> handleDeleteSuccess(ChequesModel chequesModel, ChequesSearchController chequesSearchController, [fromChequesById]) async {
    final entryBondController = read<EntryBondController>();
    // Only fetchCheques if open cheques details by cheques id from AllChequesScreen
    if (fromChequesById) {
      await read<AllChequesController>().fetchAllChequesByType(ChequesType.byTypeGuide(chequesModel.chequesTypeGuid!));
      Get.back();
    } else {
      chequesSearchController.removeCheques(chequesModel);
    }
    entryBondController.deleteEntryBondModel(entryId: chequesModel.chequesGuid!, sourceNumber: chequesModel.chequesNumber!);
    if (chequesModel.chequesPayGuid != null) {
      entryBondController.deleteEntryBondModel(entryId: chequesModel.chequesPayGuid!, sourceNumber: chequesModel.chequesNumber!);
    }
    if (chequesModel.chequesRefundPayGuid != null) {
      entryBondController.deleteEntryBondModel(entryId: chequesModel.chequesRefundPayGuid!, sourceNumber: chequesModel.chequesNumber!);
    }

    AppUIUtils.onSuccess('تم حذف الشيك بنجاح!');
  }

  Future<void> handleSaveOrUpdateSuccess({
    required ChequesModel currentChequesModel,
    ChequesModel? prevChequesModel,
    required ChequesDetailsController chequesDetailsController,
    required ChequesSearchController chequesSearchController,
    required bool isSave,
  }) async {
    final successMessage = isSave ? 'تم حفظ الشيك بنجاح!' : 'تم تعديل الشيك بنجاح!';

    AppUIUtils.onSuccess(successMessage);

    if (isSave) {
      chequesDetailsController.updateIsChequesSaved(true);
      generatePdfAndSendToEmail(
        fileName: AppStrings.newBond.tr,
        itemModel: currentChequesModel,
      );
    } else {
      chequesSearchController.updateCheques(currentChequesModel);
      generatePdfAndSendToEmail(
        fileName: AppStrings.newBond.tr,
        itemModel: [prevChequesModel!, currentChequesModel],
      );
    }

    await createAndStoreEntryBond(
      model: currentChequesModel,
      sourceNumbers: [currentChequesModel.chequesNumber!],
      isSave: isSave,
    );

    // final creators = EntryBondCreatorFactory.resolveEntryBondCreators(currentChequesModel);
    //
    // for (final creator in creators) {
    //   entryBondController.saveEntryBondModel(
    //     entryBondModel: creator.createEntryBond(
    //       originType: EntryBondType.cheque,
    //       model: currentChequesModel,
    //     ),
    //   );
    // }
  }

  bool validateAccount(AccountModel? customerAccount) {
    if (customerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم الحساب!');
      return false;
    }
    return true;
  }
}