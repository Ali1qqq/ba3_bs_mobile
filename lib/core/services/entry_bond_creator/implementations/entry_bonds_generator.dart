import '../../../../features/accounts/data/models/account_model.dart';
import '../../../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../../features/bond/data/models/entry_bond_model.dart';
import '../../../../features/cheques/data/models/cheques_model.dart';
import '../../../../features/cheques/service/cheques_entry_bond_creator.dart';
import '../../../helper/enums/enums.dart';
import '../../../helper/extensions/getx_controller_extensions.dart';
import 'entry_bond_creator_factory.dart';

mixin EntryBondsGenerator {
  final EntryBondController entryBondController = read<EntryBondController>();

  Future<void> createAndStoreEntryBonds<T>({
    required List<T> sourceModels,
    void Function(double progress)? onProgress,
  }) async {
    final entryBondModels = _mapModelsToEntryBonds(sourceModels);
    await entryBondController.saveAllEntryBondModels(
      entryBonds: entryBondModels,
      onProgress: onProgress,
    );
  }

  Future<void> createAndStoreEntryBond<T>({
    required T model,
    Map<String, AccountModel> modifiedAccounts = const {},
    void Function(double progress)? onProgress,
  }) async {
    final entryBondModels = _mapModelToEntryBonds(model);

    if (entryBondModels.length == 1) {
      await entryBondController.saveEntryBondModel(
        entryBondModel: entryBondModels.first,
        modifiedAccounts: modifiedAccounts,
      );
    } else {
      await entryBondController.saveAllEntryBondModels(
        entryBonds: entryBondModels,
        onProgress: onProgress,
      );
    }
  }

  List<EntryBondModel> _mapModelsToEntryBonds<T>(List<T> sourceModels) {
    return sourceModels.expand(_mapModelToEntryBonds).toList();
  }

  List<EntryBondModel> _mapModelToEntryBonds<T>(T model) {
    return EntryBondCreatorFactory.resolveEntryBondCreators(model)
        .map((creator) => creator.createEntryBond(
              originType: EntryBondCreatorFactory.resolveOriginType(model),
              model: model,
            ))
        .toList();
  }

  EntryBondModel createChequeEntryBondByStrategy(ChequesModel model,
      {required ChequesStrategyType chequesStrategyType}) {
    final creators = ChequesStrategyBondFactory.determineStrategy(model, type: chequesStrategyType);
    return creators.first.createEntryBond(
      model: model,
      originType: EntryBondCreatorFactory.resolveOriginType(model),
    );
  }

  Future<void> createAndStoreChequeEntryBondByStrategy(ChequesModel model,
      {required ChequesStrategyType chequesStrategyType}) async {
    final entryBondModel = createChequeEntryBondByStrategy(model, chequesStrategyType: chequesStrategyType);
    await entryBondController.saveEntryBondModel(entryBondModel: entryBondModel);
  }

  EntryBondModel createSimulatedVatEntryBond<T>(T model) => _createEntryBondInstance(model, isSimulatedVat: true);

  EntryBondModel createEntryBond<T>(T model) => _createEntryBondInstance(model);

  EntryBondModel _createEntryBondInstance<T>(T model, {bool? isSimulatedVat}) {
    return EntryBondCreatorFactory.resolveEntryBondCreator(model).createEntryBond(
      isSimulatedVat: isSimulatedVat,
      originType: EntryBondCreatorFactory.resolveOriginType(model),
      model: model,
    );
  }
}
