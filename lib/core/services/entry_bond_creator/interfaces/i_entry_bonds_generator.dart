import '../../../../features/bond/data/models/entry_bond_model.dart';

abstract class IEntryBondGenerator {
  List<EntryBondModel> createEntryBondsModels(List sourceModels);

  EntryBondModel createEntryBondsModel<T>(T model);
}
