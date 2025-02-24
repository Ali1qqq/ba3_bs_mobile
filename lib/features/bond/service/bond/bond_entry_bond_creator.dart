import 'package:ba3_bs_mobile/core/helper/extensions/basic/date_time_extensions.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/bond_model.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/entry_bond_creator/implementations/base_entry_bond_creator.dart';
import '../../../bond/data/models/entry_bond_model.dart';

class BondEntryBondCreator extends BaseEntryBondCreator<BondModel> {
  @override
  List<EntryBondItemModel> generateItems({required BondModel model, bool? isSimulatedVat}) {
    List<EntryBondItemModel> itemBonds = [];

    final date = _currentDate;
    final note = "سند قيد ل${BondType.byTypeGuide(model.payTypeGuid!).value} رقم :${model.payNumber}";
    final originId = model.payGuid;
    for (var element in model.payItems.itemList) {
      itemBonds.add(EntryBondItemModel(
        originId: originId,
        docId: originId,
        date: model.payDate ?? date,
        note: note,
        account: AccountEntity(
          id: element.entryAccountGuid!,
          name: element.entryAccountName!,
        ),
        bondItemType: element.entryCredit! > 0 ? BondItemType.creditor : BondItemType.debtor,
        amount: element.entryCredit! > 0 ? element.entryCredit : element.entryDebit,
      ));
    }
    return itemBonds;
  }

  String get _currentDate => DateTime.now().dayMonthYear;

  @override
  EntryBondOrigin createOrigin({required BondModel model, required EntryBondType originType}) => EntryBondOrigin(
        originId: model.payGuid,
        originType: originType,
        originTypeId: model.payTypeGuid,
      );

  @override
  String getModelId(BondModel model) => model.payGuid!;
}
