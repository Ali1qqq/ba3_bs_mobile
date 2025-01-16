import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time_extensions.dart';
import 'package:ba3_bs_mobile/features/cheques/data/models/cheques_model.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/services/entry_bond_creator/implementations/base_entry_bond_creator.dart';
import '../../accounts/data/models/account_model.dart';
import '../../bond/data/models/entry_bond_model.dart';
import '../data/models/cheques_model.dart';

class ChequesEntryBondCreator {
  final DefaultChequesBondStrategy _defaultStrategy = DefaultChequesBondStrategy();
  final NormalChequesBondStrategy _normalStrategy = NormalChequesBondStrategy();
  final PayChequesBondStrategy _payStrategy = PayChequesBondStrategy();

  /// Determines the appropriate strategy based on the ChequesModel.
  BaseEntryBondCreator<ChequesModel> determineStrategy({required ChequesModel chequesModel, bool? isPayStrategy}) {
    if (isPayStrategy != null) {
      if (isPayStrategy) {
        return _payStrategy;
      } else {
        return _normalStrategy;
      }
    } else {
      if (chequesModel.isPayed == true) {
        return _defaultStrategy;
      } else {
        return _normalStrategy;
      }
    }
  }
}

class DefaultChequesBondStrategy extends BaseEntryBondCreator<ChequesModel> {
  @override
  List<EntryBondItemModel> generateItems({required ChequesModel model, bool? isSimulatedVat}) {
    List<EntryBondItemModel> itemBonds = [];
    final date = model.chequesDate ?? DateTime.now().dayMonthYear;
    final note = "سند قيد ل${ChequesType.byTypeGuide(model.chequesTypeGuid!).value} رقم :${model.chequesNumber}";
    final amount = model.chequesVal;
    final originId = model.chequesGuid;
    itemBonds.addAll(
        _generateNormalEntryBond(chequesModel: model, note: note, originId: originId!, amount: amount!, date: date));

    itemBonds
        .addAll(_generatePayEntryBond(chequesModel: model, note: note, originId: originId, amount: amount, date: date));

    return itemBonds;
  }

  List<EntryBondItemModel> _generateNormalEntryBond(
      {required ChequesModel chequesModel,
      required String note,
      required String originId,
      required double amount,
      required String date}) {
    List<EntryBondItemModel> itemBonds = [];
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      account: AccountEntity(
        id: chequesModel.chequesAccount2Guid!,
        name: chequesModel.chequesAccount2Name!,
      ),
      bondItemType: BondItemType.creditor,
      date: date,
      originId: originId,
    ));
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.debtor,
      account: AccountEntity(
        id: chequesModel.accPtr!,
        name: chequesModel.accPtrName!,
      ),
      date: date,
      originId: originId,
    ));
    return itemBonds;
  }

  List<EntryBondItemModel> _generatePayEntryBond(
      {required ChequesModel chequesModel,
      required String note,
      required String originId,
      required double amount,
      required String date}) {
    List<EntryBondItemModel> itemBonds = [];
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.debtor,
      account: AccountEntity(
        id: chequesModel.chequesAccount2Guid!,
        name: chequesModel.chequesAccount2Name!,
      ),
      date: date,
      originId: originId,
    ));
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.creditor,
      account: AccountEntity(
        id: AppStrings.bankAccountId,
        name: AppStrings.bankToAccountName,
      ),
      date: date,
      originId: originId,
    ));
    return itemBonds;
  }

  @override
  EntryBondOrigin createOrigin({required ChequesModel model, required EntryBondType originType}) => EntryBondOrigin(
        originId: model.chequesGuid,
        originType: originType,
        originTypeId: model.chequesTypeGuid,
      );

  @override
  String getModelId(ChequesModel model) => model.chequesGuid!;
}

class NormalChequesBondStrategy extends BaseEntryBondCreator<ChequesModel> {
  @override
  EntryBondOrigin createOrigin({required ChequesModel model, required EntryBondType originType}) => EntryBondOrigin(
        originId: model.chequesGuid,
        originType: originType,
        originTypeId: model.chequesTypeGuid,
      );

  @override
  List<EntryBondItemModel> generateItems({required ChequesModel model, bool? isSimulatedVat}) =>
      _generateNormalEntryBond(
        chequesModel: model,
        note: "سند قيد ل${ChequesType.byTypeGuide(model.chequesTypeGuid!).value} رقم :${model.chequesNumber}",
        amount: model.chequesVal!,
        date: model.chequesDate ?? DateTime.now().dayMonthYear,
        originId: model.chequesGuid!,
      );

  @override
  String getModelId(ChequesModel model) => model.chequesGuid!;

  List<EntryBondItemModel> _generateNormalEntryBond(
      {required ChequesModel chequesModel,
      required String note,
      required String originId,
      required double amount,
      required String date}) {
    List<EntryBondItemModel> itemBonds = [];
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      account: AccountEntity(
        id: chequesModel.chequesAccount2Guid!,
        name: chequesModel.chequesAccount2Name!,
      ),
      bondItemType: BondItemType.creditor,
      date: date,
      originId: originId,
    ));
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.debtor,
      account: AccountEntity(
        id: chequesModel.accPtr!,
        name: chequesModel.accPtrName!,
      ),
      date: date,
      originId: originId,
    ));
    return itemBonds;
  }
}

class PayChequesBondStrategy extends BaseEntryBondCreator<ChequesModel> {
  @override
  EntryBondOrigin createOrigin({required ChequesModel model, required EntryBondType originType}) => EntryBondOrigin(
        originId: model.chequesGuid,
        originType: originType,
        originTypeId: model.chequesTypeGuid,
      );

  @override
  List<EntryBondItemModel> generateItems({required ChequesModel model, bool? isSimulatedVat}) => _generatePayEntryBond(
        chequesModel: model,
        note: "سند قيد لدفع ${ChequesType.byTypeGuide(model.chequesTypeGuid!).value} رقم :${model.chequesNumber}",
        amount: model.chequesVal!,
        date: model.chequesDate ?? DateTime.now().dayMonthYear,
        originId: model.chequesGuid!,
      );

  @override
  String getModelId(ChequesModel model) => model.chequesGuid!;

  List<EntryBondItemModel> _generatePayEntryBond(
      {required ChequesModel chequesModel,
      required String note,
      required String originId,
      required double amount,
      required String date}) {
    List<EntryBondItemModel> itemBonds = [];
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.debtor,
      account: AccountEntity(
        id: chequesModel.chequesAccount2Guid!,
        name: chequesModel.chequesAccount2Name!,
      ),
      date: date,
      originId: originId,
    ));
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.creditor,
      account: AccountEntity(
        id: AppStrings.bankAccountId,
        name: AppStrings.bankToAccountName,
      ),
      date: date,
      originId: originId,
    ));
    return itemBonds;
  }
}
