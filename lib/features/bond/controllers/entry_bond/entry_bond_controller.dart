import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/entry_bond_model.dart';

class EntryBondController extends GetxController with FloatingLauncher {
  final RemoteDataSourceRepository<EntryBondModel> _entryBondsFirebaseRepo;

  final CompoundDatasourceRepository<EntryBondItems, AccountEntity> _accountsStatementsFirebaseRepo;

  EntryBondController(this._entryBondsFirebaseRepo, this._accountsStatementsFirebaseRepo);

  /// Method to save an Entry Bond and update related account statements
  Future<void> saveEntryBondModel({
    required EntryBondModel entryBondModel,
    Map<String, AccountModel> modifiedAccounts = const {},
  }) async {
    final result = await _entryBondsFirebaseRepo.save(entryBondModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedEntryBondModel) => _onEntryBondSaved(
        entryBondModel: savedEntryBondModel,
        modifiedAccounts: modifiedAccounts,
      ),
    );
  }

  /// Handles logic after an Entry Bond is successfully saved
  Future<void> _onEntryBondSaved({
    required EntryBondModel entryBondModel,
    Map<String, AccountModel> modifiedAccounts = const {},
  }) async {
    final entryBondItems = entryBondModel.items?.itemList;

    // Exit early if there are no items
    if (entryBondItems == null || entryBondItems.isEmpty) return;

    // Group items by account and save them
    await _saveGroupedEntryBondItems(entryBondItems);

    // Handle modifications to the Entry Bond items
    await _handleModifiedEntryBondItems(
      entryBondModel: entryBondModel,
      modifiedAccounts: modifiedAccounts,
    );
  }

  /// Saves grouped Entry Bond items by account
  Future<void> _saveGroupedEntryBondItems(List<EntryBondItemModel> entryBondItems) async {
    // Group items by account ID

    final itemsGroupedByAccount = entryBondItems.groupBy((item) => item.account.id);
    // log('itemsGroupedByAccount $itemsGroupedByAccount');

    for (final accountId in itemsGroupedByAccount.keys) {
      final groupedItems = itemsGroupedByAccount[accountId]!;

      await _accountsStatementsFirebaseRepo.save(
        EntryBondItems(
          id: groupedItems.first.originId!,
          docId: groupedItems.first.docId,
          itemList: groupedItems,
        ),
      );
    }
  }

  /// Handles modifications to the Entry Bond items
  Future<void> _handleModifiedEntryBondItems({
    required EntryBondModel entryBondModel,
    Map<String, AccountModel> modifiedAccounts = const {},
  }) async {
    final modifiedEntryBondItems = _mapToEntryBondItems(
      originId: entryBondModel.origin!.originId!,
      modifiedAccounts: modifiedAccounts,
    );

    if (modifiedEntryBondItems.isEmpty) return;

    // Delete modified Entry Bond items
    for (final entryBondItem in modifiedEntryBondItems) {
      final result = await _accountsStatementsFirebaseRepo.delete(entryBondItem);

      result.fold(
        (failure) => AppUIUtils.onFailure('${failure.message} in _handleModifiedEntryBondItems'),
        (_) {},
      );
    }
  }

  /// Converts modified bill type accounts to EntryBondItems
  List<EntryBondItems> _mapToEntryBondItems({
    required String originId,
    required Map<String, AccountModel> modifiedAccounts,
  }) {
    return modifiedAccounts.entries.map((entry) {
      final accountModel = entry.value;
      return EntryBondItems(
        id: originId,
        itemList: [
          EntryBondItemModel(
            account: AccountEntity.fromAccountModel(accountModel),
          ),
        ],
      );
    }).toList();
  }

  Future<void> saveAllEntryBondModels({
    required List<EntryBondModel> entryBonds,
    void Function(double progress)? onProgress,
  }) async {
    int counter = 0;
    for (final entryBond in entryBonds) {
      await saveEntryBondModel(entryBondModel: entryBond);

      onProgress?.call((counter++) / entryBonds.length);
    }
  }

  Future<EntryBondModel> getEntryBondById({required String entryId}) async {
    final result = await _entryBondsFirebaseRepo.getById(entryId);

    return result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (entryBondModel) => entryBondModel,
    );
  }

  // Method to create a bond based on bill type
  void deleteEntryBondModel({required String entryId}) async {
    final result = await _entryBondsFirebaseRepo.getById(entryId);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (entryBondModel) async => await onEntryBondDeleted(entryBondModel: entryBondModel, entryId: entryId),
    );
  }

  Future<void> onEntryBondDeleted({required EntryBondModel entryBondModel, required String entryId}) async {
    final List<Future<void>> deletedTasks = [];
    final errors = <String>[]; // Collect error messages.

    final entryBondItems = entryBondModel.items!.itemList;

    for (final entryBondItem in entryBondItems) {
      final itemsGroupedByAccount = entryBondItems.where((item) => item.account.id == entryBondItem.account.id).toList();

      deletedTasks.add(
        _accountsStatementsFirebaseRepo
            .delete(EntryBondItems(docId: entryBondItem.docId, id: entryBondItem.originId!, itemList: itemsGroupedByAccount))
            .then(
          (deleteResult) {
            deleteResult.fold(
              (failure) => errors.add(failure.message), // Collect errors.
              (_) {},
            );
          },
        ),
      );
    }

    await Future.wait(deletedTasks);

    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some deletions failed: ${errors.join(', ')}');
      return;
    }

    final deleteBondResult = await _entryBondsFirebaseRepo.delete(entryId);
    deleteBondResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) {},
    );
  }

  // EntryBondItems getUniqueEntryBondItemsFromBond(EntryBondModel entryBondModel) {
  //   final uniqueItemsByAccountId = <String, EntryBondItems>{};
  //
  //   // Populate the map with unique items using accountId as the key.
  //   for (final EntryBondItemModel item in entryBondModel.items?.itemList ?? []) {
  //     final accountId = item.account.id;
  //     uniqueItemsByAccountId.putIfAbsent(accountId, () => item);
  //   }
  //
  //   // Return the unique items as a list.
  //   return EntryBondItems(itemList: uniqueItemsByAccountId.values.toList());
  // }

  void openEntryBondOrigin(EntryBondModel entryBondModel, BuildContext context) {
    final origin = entryBondModel.origin;

    // Handle the case where origin details are missing
    if (origin == null || origin.originType == null || origin.originId == null) {
      return;
    }

    final actions = {
      EntryBondType.bond: () => read<AllBondsController>()
          .openBondDetailsById(origin.originId!, context, BondType.byTypeGuide(entryBondModel.origin!.originTypeId!)),
      EntryBondType.bill: () => read<AllBillsController>()
          .openFloatingBillDetailsById(origin.originId!, context, BillType.byTypeGuide(entryBondModel.origin!.originTypeId!).billTypeModel),
      EntryBondType.cheque: () => read<AllChequesController>()
          .openChequesDetailsById(origin.originId!, context, ChequesType.byTypeGuide(entryBondModel.origin!.originTypeId!)),
    };

    final action = actions[origin.originType];
    if (action != null) {
      action();
    }
  }
}
