import 'dart:developer';
import 'dart:isolate';

import '../../../core/helper/enums/enums.dart';
import '../../bond/data/models/entry_bond_model.dart';
import '../service/account_statement_service.dart';

// process_entry_bond_items_in_isolate_use_case
class ProcessEntryBondItemsInIsolateUseCase {
  final AccountStatementService _accountStatementService;

  ProcessEntryBondItemsInIsolateUseCase(this._accountStatementService);

  /// Runs _processEntryBondItems in an Isolate for better performance
  Future<List<EntryBondItemModel>> execute(List<EntryBondItems> data) async {
    final ReceivePort receivePort = ReceivePort();
    final Isolate isolate = await Isolate.spawn(_processEntryBondItemsIsolate, [receivePort.sendPort, data]);

    final List<EntryBondItemModel> result = await receivePort.first as List<EntryBondItemModel>;

    // Cleanup: Close the isolate and receive port
    receivePort.close();
    isolate.kill(priority: Isolate.immediate);

    return result;
  }

  /// Function that runs in the isolate
  void _processEntryBondItemsIsolate(List<dynamic> args) {
    final SendPort sendPort = args[0];
    final List<EntryBondItems> data = args[1];

    final List<EntryBondItemModel> result = _processEntryBondItems(data);

    sendPort.send(result);
  }

  /// Processes entry bond items in a background isolate
  List<EntryBondItemModel> _processEntryBondItems(List<EntryBondItems> result) {
    final Map<String, EntryBondItemModel> mergedMap = {};

    for (var entry in result) {
      for (var currentItem in entry.itemList) {
        final String key = currentItem.account.id;

        if (key == '27e7c0e6-9734-4319-bafb-483292e87f17') {
          log(
            '${currentItem.account.name} - ${currentItem.amount} - ${currentItem.bondItemType?.label}',
            name: '_processEntryBondItems account id: ${currentItem.account.id} - docId: ${currentItem.docId}',
          );
        }

        if (mergedMap.containsKey(key)) {
          final existingItem = mergedMap[key]!;

          double updatedAmount = _accountStatementService.getAmountSign(existingItem.amount!, existingItem.bondItemType!) +
              _accountStatementService.getAmountSign(currentItem.amount, currentItem.bondItemType!);

          BondItemType finalType = updatedAmount >= 0 ? BondItemType.debtor : BondItemType.creditor;

          mergedMap[key] = EntryBondItemModel(
            account: currentItem.account,
            amount: updatedAmount.abs(),
            bondItemType: finalType,
            date: currentItem.date,
            //  note: '${existingItem.note} + ${currentItem.note}',
            note: currentItem.note,
            originId: currentItem.originId,
            docId: currentItem.docId,
          );
        } else {
          mergedMap[key] = currentItem;
        }
      }
    }

    return mergedMap.values.toList();
  }
}
