import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs_mobile/features/logs/controllers/log_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/entry_bond_model.dart';

class EntryBondController extends GetxController with FloatingLauncher {
  final BulkSavableDatasourceRepository<EntryBondModel> _entryBondsFirebaseRepo;

  final CompoundDatasourceRepository<EntryBondItems, AccountEntity> _accountsStatementsFirebaseRepo;

  EntryBondController(this._entryBondsFirebaseRepo, this._accountsStatementsFirebaseRepo);

  /// Method to save an Entry Bond and update related account statements
  Future<List<EntryBondModel>> fetchAllEntryBonds() async {
    final result = await _entryBondsFirebaseRepo.getAll();

    return result.fold(
      (failure) {
        AppUIUtils.onFailure(failure.message);
        return [];
      },
      (fetchedEntryBonds) => fetchedEntryBonds,
    );
  }

  /// Method to save an Entry Bond and update related account statements
  Future<void> saveEntryBondModel({
    required EntryBondModel entryBondModel,
    required int sourceNumber,
    required bool isSave,
    Map<String, AccountModel> modifiedAccounts = const {},
  }) async {
    log('saveEntryBondModel', name: 'saveEntryBondModel');
    final result = await _entryBondsFirebaseRepo.save(entryBondModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedEntryBondModel) => _onEntryBondSaved(
        entryBondModel: savedEntryBondModel,
        sourceNumber: sourceNumber,
        isSave: isSave,
        modifiedAccounts: modifiedAccounts,
      ),
    );
  }

  /// Saves a list of EntryBondModels in a single batch (if the repo supports `saveAll`).
  Future<void> saveAllEntryBondModels({
    required List<EntryBondModel> entryBonds,
    required List<int> sourceNumbers,
    required bool isSave,
    void Function(double progress)? onProgress,
  }) async {
    log('Start SaveAllEntryBondModels');

    // 1. Perform a single batch save in your repository
    final saveResult = await _entryBondsFirebaseRepo.saveAll(entryBonds);

    log('Finish SaveAllEntryBondModels');

    // 2. Check if the batch save succeeded/failed
    return saveResult.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedBonds) async {
        // 3. For each successfully saved bond, run post-save logic
        int counter = 0;
        for (final savedBond in savedBonds) {
          await _onEntryBondSaved(entryBondModel: savedBond, sourceNumber: sourceNumbers[counter], isSave: isSave);

          // Update progress
          onProgress?.call(++counter / savedBonds.length);
        }
      },
    );
  }

  // 11:34
  // 5430

  /// Handles logic after an Entry Bond is successfully saved
  Future<void> _onEntryBondSaved({
    required EntryBondModel entryBondModel,
    required int sourceNumber,
    required bool isSave,
    Map<String, AccountModel> modifiedAccounts = const {},
  }) async {
    log('Start _onEntryBondSaved');

    final entryBondItems = entryBondModel.items?.itemList;
    if (entryBondItems == null || entryBondItems.isEmpty) return;

    // Run grouped-item saving and item modifications in parallel
    await Future.wait([
      _saveGroupedEntryBondItems(entryBondItems),
      _handleModifiedEntryBondItems(
        entryBondModel: entryBondModel,
        modifiedAccounts: modifiedAccounts,
      ),
    ]);

    final logController = read<LogController>();

    read<LogController>().addLog(
      logController.getLogModel(
        entryBondModel: entryBondModel,
        eventType: isSave ? LogEventType.add : LogEventType.update,
        sourceNumber: sourceNumber,
      ),
    );

    log('Finish _onEntryBondSaved');
  }

  /// Saves grouped Entry Bond items by account, in parallel
  Future<void> _saveGroupedEntryBondItems(List<EntryBondItemModel> entryBondItems) async {
    log('Start _saveGroupedEntryBondItems', name: entryBondItems.isNotEmpty ? entryBondItems.first.account.id : '');
    final itemsGroupedByAccount = entryBondItems.groupBy((item) => item.account.id);

    // Build a list of futures
    final List<Future<Either<Failure, EntryBondItems>>> futures = [];

    for (final accountId in itemsGroupedByAccount.keys) {
      final groupedItems = itemsGroupedByAccount[accountId]!;

      final bondItems = EntryBondItems(
        id: groupedItems.first.originId!,
        docId: groupedItems.first.docId,
        itemList: groupedItems,
      );

      futures.add(_accountsStatementsFirebaseRepo.save(bondItems));
    }

    // Wait for all to complete
    final results = await Future.wait(futures);

    // Handle potential failures
    for (final result in results) {
      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (_) => {}, // or success
      );
    }

    log('Finish _saveGroupedEntryBondItems');
  }

  /// Deletes modified Entry Bond items in parallel
  Future<void> _handleModifiedEntryBondItems({
    required EntryBondModel entryBondModel,
    Map<String, AccountModel> modifiedAccounts = const {},
  }) async {
    log('Start _handleModifiedEntryBondItems ${modifiedAccounts.length}');

    final modifiedEntryBondItems = _mapToEntryBondItems(
      originId: entryBondModel.origin!.originId!,
      modifiedAccounts: modifiedAccounts,
    );

    if (modifiedEntryBondItems.isEmpty) return;

    // Build a list of futures for parallel deletes
    final futures = modifiedEntryBondItems.map(
      (entryBondItem) {
        return _accountsStatementsFirebaseRepo.delete(entryBondItem);
      },
    );

    final results = await Future.wait(futures);

    // Handle potential failures
    for (final result in results) {
      result.fold(
        (failure) => AppUIUtils.onFailure('${failure.message} in _handleModifiedEntryBondItems'),
        (_) => {},
      );
    }

    log('Finish _handleModifiedEntryBondItems');
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

  Future<EntryBondModel> getEntryBondById({required String entryId}) async {
    final result = await _entryBondsFirebaseRepo.getById(entryId);

    return result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (entryBondModel) => entryBondModel,
    );
  }

  // Method to create a bond based on bill type
  Future<void> deleteEntryBondModel({required String entryId, required int sourceNumber}) async {
    final result = await _entryBondsFirebaseRepo.getById(entryId);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (entryBondModel) async => await onEntryBondDeleted(entryBondModel: entryBondModel, entryId: entryId, sourceNumber: sourceNumber),
    );
  }

  Future<void> onEntryBondDeleted({required EntryBondModel entryBondModel, required String entryId, required int sourceNumber}) async {
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
              (failure) {
                log('error ${failure.message}');
                errors.add(failure.message); // Collect errors.
              },
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
      (_) {
        log('deleteBond Success');
        final logController = read<LogController>();

        read<LogController>().addLog(
          logController.getLogModel(
            entryBondModel: entryBondModel,
            eventType: LogEventType.delete,
            sourceNumber: sourceNumber,
          ),
        );
      },
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
      EntryBondType.bill: () {
        log(origin.toJson().toString());
        read<AllBillsController>().openFloatingBillDetailsById(
            billId: origin.originId!,
            context: context,
            bilTypeModel: BillType.byTypeGuide(entryBondModel.origin!.originTypeId!).billTypeModel);
      },
      EntryBondType.cheque: () => read<AllChequesController>()
          .openChequesDetailsById(origin.originId!, context, ChequesType.byTypeGuide(entryBondModel.origin!.originTypeId!)),
    };

    final action = actions[origin.originType];
    if (action != null) {
      action();
    }
  }
}