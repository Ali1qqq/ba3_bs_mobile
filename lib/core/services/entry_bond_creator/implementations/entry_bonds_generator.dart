import '../../../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../../features/bond/data/models/entry_bond_model.dart';
import '../../../helper/extensions/getx_controller_extensions.dart';
import '../interfaces/entry_bond_creator.dart';
import '../interfaces/i_entry_bonds_generator.dart';
import 'entry_bond_creator_factory.dart';

class EntryBondGenerator implements IEntryBondGenerator {
  @override
  List<EntryBondModel> createEntryBondModels(List sourceModels) {
    return sourceModels.map(
      (model) {
        final EntryBondCreator creator = EntryBondCreatorFactory.resolveEntryBondCreator(model);

        return creator.createEntryBond(
          originType: EntryBondCreatorFactory.determineOriginType(model),
          model: model,
        );
      },
    ).toList();
  }
}

class EntryBondGeneratorRepo {
  final IEntryBondGenerator entryBondGenerator;

  EntryBondGeneratorRepo(this.entryBondGenerator);

  Future<void> saveEntryBonds(List sourceModels) async {
    final entryBondModels = entryBondGenerator.createEntryBondModels(sourceModels);

    await read<EntryBondController>().saveAllEntryBondModels(entryBondModels);
  }
}
