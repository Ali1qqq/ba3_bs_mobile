import 'dart:developer';

import 'package:ba3_bs_mobile/core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/pay_item_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/helper/mixin/floating_launcher.dart';
import '../../../../core/helper/mixin/pdf_base.dart';
import '../../../../core/i_controllers/i_recodes_pluto_controller.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../controllers/bonds/all_bond_controller.dart';
import '../../controllers/bonds/bond_search_controller.dart';
import '../../controllers/entry_bond/entry_bond_controller.dart';
import '../../data/models/bond_model.dart';
import '../../ui/screens/entry_bond_details_screen.dart';

class BondDetailsService with PdfBase, EntryBondsGenerator, FloatingLauncher {
  final IRecodesPlutoController<PayItem> plutoController;
  final BondDetailsController bondController;

  BondDetailsService(this.plutoController, this.bondController);

  void launchBondEntryBondScreen({required BuildContext context, required BondModel bondModel}) {
    // final creator = EntryBondCreatorFactory.resolveEntryBondCreator(bondModel);
    //
    // final entryBond = creator.createEntryBond(
    //   originType: EntryBondType.cheque,
    //   model: bondModel,
    // );

    final entryBondModel = createEntryBond(bondModel);

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
  }) {
    log("generateRecords ${plutoController.generateRecords.length}", name: "createBondModel");

    return BondModel.fromBondData(
      bondModel: bondModel,
      bondType: bondType,
      note: note,
      payAccountGuid: payAccountGuid,
      payDate: payDate,
      bondRecordsItems: plutoController.generateRecords,
    );
  }

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

    read<EntryBondController>().deleteEntryBondModel(entryId: bondModel.payGuid!, sourceNumber: bondModel.payNumber!);
  }

  Future<void> handleSaveOrUpdateSuccess({
    BondModel? previousBond,
    required BondModel currentBond,
    required BondDetailsController bondDetailsController,
    required BondSearchController bondSearchController,
    required bool isSave,
  }) async {
    log("save handleSaveOrUpdateSuccess");
    final successMessage = isSave ? 'تم حفظ السند بنجاح!' : 'تم تعديل السند بنجاح!';

    AppUIUtils.onSuccess(successMessage);

    Map<String, AccountModel> modifiedBondTypeAccounts = {};
    if (isSave) {
      bondDetailsController.updateIsBondSaved(true);

      if (hasModelId(currentBond.payGuid) && hasModelItems(currentBond.payItems.itemList)) {
        generatePdfAndSendToEmail(
          fileName: AppStrings.newBond.tr,
          itemModel: currentBond,
        );
      }
    } else {
      modifiedBondTypeAccounts = findModifiedBondTypeAccounts(
        previousBond: previousBond!,
        currentBond: currentBond,
      );
      if (hasModelId(currentBond.payGuid) &&
          hasModelItems(currentBond.payItems.itemList) &&
          hasModelId(previousBond.payGuid) &&
          hasModelItems(previousBond.payItems.itemList)) {
        generatePdfAndSendToEmail(
          fileName: AppStrings.updatedBond.tr,
          itemModel: [previousBond, currentBond],
        );
      }
    }
    bondSearchController.updateBond(currentBond);

    createAndStoreEntryBond(
      model: currentBond,
      sourceNumbers: [currentBond.payNumber!],
      modifiedAccounts: modifiedBondTypeAccounts,
      isSave: isSave,
    );

    // final creator = EntryBondCreatorFactory.resolveEntryBondCreator(currentBond);
    //
    // entryBondController.saveEntryBondModel(
    //   modifiedAccounts: modifiedBondTypeAccounts,
    //   entryBondModel: creator.createEntryBond(
    //     originType: EntryBondType.bond,
    //     model: currentBond,
    //   ),
    // );
  }

  bool validateAccount(AccountModel? customerAccount) {
    if (customerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم الحساب!');
      return false;
    }
    return true;
  }

  Map<String, AccountModel> findModifiedBondTypeAccounts({
    required BondModel previousBond,
    required BondModel currentBond,
  }) {
    final previousAccounts = {
      for (var item in previousBond.payItems.itemList)
        item.entryAccountGuid!: AccountModel(id: item.entryAccountGuid!, accName: item.entryAccountName!)
    };

    final currentAccounts = {
      for (var item in currentBond.payItems.itemList)
        item.entryAccountGuid!: AccountModel(id: item.entryAccountGuid!, accName: item.entryAccountName!)
    };

    if (previousBond.payAccountGuid != null && currentBond.payAccountGuid != null) {
      previousAccounts[previousBond.payAccountGuid!] = AccountModel(
          id: previousBond.payAccountGuid!, accName: read<AccountsController>().getAccountNameById(previousBond.payAccountGuid!));
      currentAccounts[currentBond.payAccountGuid!] = AccountModel(
          id: currentBond.payAccountGuid!, accName: read<AccountsController>().getAccountNameById(currentBond.payAccountGuid!));
    }

    final Map<String, AccountModel> modifiedAccounts = {};

    previousAccounts.forEach(
      (accountKey, previousAccountModel) {
        // Find the corresponding account in the current bill
        final currentAccountModel = currentAccounts[accountKey];

        // Check if the account exists in the current bill and has been modified
        if (currentAccountModel?.id != previousAccountModel.id) {
          modifiedAccounts[accountKey] = previousAccountModel;
        }
      },
    );

    // log('modifiedAccounts length: ${modifiedAccounts.length}');
    //
    // modifiedAccounts.forEach((key, value) => log('modifiedBondTypeAccounts Account $key, AccountModel ${value.toJson()}'));

    return modifiedAccounts;
  }
}