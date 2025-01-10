import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/datasources/remote/accounts_statements_data_source.dart';
import '../../data/models/entry_bond_model.dart';

class EntryBondController extends GetxController with FloatingLauncher {
  final RemoteDataSourceRepository<EntryBondModel> _entryBondsFirebaseRepo;

  final AccountsStatementsRepository _accountsStatementsRepo;

  EntryBondController(this._entryBondsFirebaseRepo, this._accountsStatementsRepo);

  // Method to create a bond based on bill type
  void saveEntryBondModel({required EntryBondModel entryBondModel}) async {
    final result = await _entryBondsFirebaseRepo.save(entryBondModel);
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (entryBondModel) async {
        for (final item in entryBondModel.items!) {
          await _accountsStatementsRepo.addBond(item.accountId!, entryBondModel);
        }
      },
    );
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
      (entryBondModel) async {
        final List<Future<void>> deletedTasks = [];
        final errors = <String>[]; // Collect error messages.

        final uniqueAccountIdsFromBond = getUniqueAccountIdsFromBond(entryBondModel);

        for (final accountId in uniqueAccountIdsFromBond) {
          deletedTasks.add(
            _accountsStatementsRepo.deleteBond(accountId, entryId).then(
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
        }

        final deleteBondResult = await _entryBondsFirebaseRepo.delete(entryId);
        deleteBondResult.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (_) {},
        );
      },
    );
  }

  List<String> getUniqueAccountIdsFromBond(EntryBondModel entryBondModel) {
    final Set<String> accountsIds = <String>{}; // Use a Set to ensure unique account IDs.

    // Iterate through each EntryBondItemModel in the items list.
    for (final item in entryBondModel.items ?? []) {
      if (item.accountId != null) {
        accountsIds.add(item.accountId!);
      }
    }

    return accountsIds.toList(); // Convert the Set back to a List.
  }

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
