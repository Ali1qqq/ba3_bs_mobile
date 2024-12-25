import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/cheques/data/models/cheques_model.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../bond/data/models/entry_bond_model.dart';

mixin ChequesBondService {
  EntryBondModel createEntryBondModel({
    required EntryBondType originType,
    required ChequesModel chequesModel,
  }) {
    return EntryBondModel(
      origin: EntryBondOrigin(
        originId: chequesModel.chequesGuid,
        originType: originType,
        originTypeId: chequesModel.chequesTypeGuid,
      ),
      items: generateEntryBondItems(
        chequesModel: chequesModel,
      ),
    );
  }



  EntryBondModel createNormalEntryBondModel({
    required EntryBondType originType,
    required ChequesModel chequesModel,
  }) {
    return EntryBondModel(
      origin: EntryBondOrigin(
        originId: chequesModel.chequesGuid,
        originType: originType,
        originTypeId: chequesModel.chequesTypeGuid,
      ),
      items: _generateNormalEntryBond(
        chequesModel: chequesModel,
        note:  "سند قيد ل${ChequesType.byTypeGuide(chequesModel.chequesTypeGuid!).value} رقم :${chequesModel.chequesNumber}",
        amount: chequesModel.chequesVal!,
        date:chequesModel.chequesDate?? _currentDate,
        originId: chequesModel.chequesGuid!
      ),
    );
  }
  EntryBondModel createPayEntryBondModel({
    required EntryBondType originType,
    required ChequesModel chequesModel,
  }) {
    return EntryBondModel(
      origin: EntryBondOrigin(
        originId: chequesModel.chequesGuid,
        originType: originType,
        originTypeId: chequesModel.chequesTypeGuid,
      ),
      items: _generatePayEntryBond(
        chequesModel: chequesModel,
        note:  "سند قيد لدفع ${ChequesType.byTypeGuide(chequesModel.chequesTypeGuid!).value} رقم :${chequesModel.chequesNumber}",
        amount: chequesModel.chequesVal!,
        date: chequesModel.chequesDate??_currentDate,
        originId: chequesModel.chequesGuid!
      ),
    );
  }

  List<EntryBondItemModel> generateEntryBondItems({
    required ChequesModel chequesModel,
  }) {
    List<EntryBondItemModel> itemBonds = [];
    final date = chequesModel.chequesDate??_currentDate;
    final note = "سند قيد ل${ChequesType.byTypeGuide(chequesModel.chequesTypeGuid!).value} رقم :${chequesModel.chequesNumber}";
    final amount = chequesModel.chequesVal;
    final originId = chequesModel.chequesGuid;
    itemBonds.addAll( _generateNormalEntryBond(chequesModel: chequesModel, note: note, originId: originId!, amount: amount!, date: date)) ;
    if(chequesModel.isPayed!) {
      itemBonds.addAll( _generatePayEntryBond(chequesModel: chequesModel, note: note, originId: originId, amount: amount, date: date)) ;
    }

    return itemBonds;
  }

  List<EntryBondItemModel> _generateNormalEntryBond({required ChequesModel chequesModel, required String note, required String originId, required double amount, required String date}) {
    List<EntryBondItemModel> itemBonds = [];
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.creditor,
      accountId: chequesModel.chequesAccount2Guid,
      accountName: chequesModel.chequesAccount2Name,
      date: date,
      originId: originId,
    ));
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.debtor,
      accountId: chequesModel.accPtr,
      accountName: chequesModel.accPtrName,
      date: date,
      originId: originId,
    ));
    return itemBonds;
  }
  List<EntryBondItemModel> _generatePayEntryBond({required ChequesModel chequesModel, required String note, required String originId, required double amount, required String date}) {
    List<EntryBondItemModel> itemBonds = [];
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.debtor,
      accountId: chequesModel.chequesAccount2Guid,
      accountName: chequesModel.chequesAccount2Name,
      date: date,
      originId: originId,
    ));
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.creditor,
      accountId: AppStrings.bankAccountId,
      accountName: AppStrings.bankToAccountName,
      date: date,
      originId: originId,
    ));
    return itemBonds;
  }


  String get _currentDate => DateTime.now().toString().split(" ")[0];
}
