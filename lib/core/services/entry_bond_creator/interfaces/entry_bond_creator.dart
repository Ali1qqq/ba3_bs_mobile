import '../../../../features/bond/data/models/entry_bond_model.dart';
import '../../../helper/enums/enums.dart';

abstract class EntryBondCreator<T> {
  EntryBondModel createEntryBond({
    required EntryBondType originType,
    required T model,
    required DateTime entryBondDate,
    bool? isSimulatedVat,
  });
}