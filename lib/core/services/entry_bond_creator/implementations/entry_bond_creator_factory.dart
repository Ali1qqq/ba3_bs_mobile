import '../../../../features/bill/data/models/bill_model.dart';
import '../../../../features/bill/services/bill/bill_entry_bond_creator.dart';
import '../../../../features/bond/data/models/bond_model.dart';
import '../../../../features/bond/service/bond/bond_entry_bond_creator.dart';
import '../../../../features/cheques/data/models/cheques_model.dart';
import '../../../../features/cheques/service/cheques_entry_bond_creator.dart';
import '../../../helper/enums/enums.dart';
import '../interfaces/entry_bond_creator.dart';

class EntryBondCreatorFactory {
  static EntryBondCreator resolveEntryBondCreator<T>(T model) {
    if (model is ChequesModel) {
      return ChequesEntryBondCreator().determineStrategy(chequesModel: model);
    } else if (model is BondModel) {
      return BondEntryBondCreator();
    } else if (model is BillModel) {
      return BillEntryBondCreator();
    }
    throw UnimplementedError("No EntryBondCreator implementation for model of type ${T.runtimeType}");
  }

  static EntryBondType determineOriginType<T>(T model) {
    if (model is ChequesModel) {
      return EntryBondType.cheque;
    } else if (model is BondModel) {
      return EntryBondType.bond;
    } else if (model is BillModel) {
      return EntryBondType.bill;
    }
    throw UnimplementedError("No EntryBondType defined for model of type ${T.runtimeType}");
  }
}
