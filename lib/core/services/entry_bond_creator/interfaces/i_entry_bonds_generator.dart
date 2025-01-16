import '../../../../features/bond/data/models/entry_bond_model.dart';

abstract class IEntryBondGenerator {
  List<EntryBondModel> createEntryBondModels(List sourceModels);
}
