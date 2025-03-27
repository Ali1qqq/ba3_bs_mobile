import 'dart:developer';

import '../../../../features/accounts/data/models/account_model.dart';
import '../../../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../../features/bond/data/models/entry_bond_model.dart';
import '../../../../features/cheques/data/models/cheques_model.dart';
import '../../../../features/cheques/service/cheques_entry_bond_creator.dart';
import '../../../helper/enums/enums.dart';
import '../../../helper/extensions/getx_controller_extensions.dart';
import 'entry_bond_creator_factory.dart';

mixin EntryBondsGenerator {
  Future<void> createAndStoreEntryBonds<T>({
    required List<T> sourceModels,
    required List<int> sourceNumbers,
    void Function(double progress)? onProgress,
  }) async {
    final entryBondModels = _mapModelsToEntryBonds(sourceModels);
    await read<EntryBondController>().saveAllEntryBondModels(
      entryBonds: entryBondModels,
      sourceNumbers: sourceNumbers,
      onProgress: onProgress,
      isSave: true,
    );
  }

  Future<void> createAndStoreEntryBond<T>({
    required T model,
    required List<int> sourceNumbers,
    required bool isSave,
    Map<String, AccountModel> modifiedAccounts = const {},
    void Function(double progress)? onProgress,
  }) async {
    final entryBondController = read<EntryBondController>();

    final entryBondModels = _mapModelToEntryBonds(model);

    if (entryBondModels.length == 1) {
      log('entryBondModels.length == 1', name: 'createAndStoreEntryBond');
      await entryBondController.saveEntryBondModel(
        entryBondModel: entryBondModels.first,
        sourceNumber: sourceNumbers.first,
        isSave: isSave,
        modifiedAccounts: modifiedAccounts,
      );
    } else {
      await entryBondController.saveAllEntryBondModels(
        entryBonds: entryBondModels,
        sourceNumbers: sourceNumbers,
        isSave: isSave,
        onProgress: onProgress,
      );
    }
  }

  List<EntryBondModel> _mapModelsToEntryBonds<T>(List<T> sourceModels) {
    return sourceModels.expand(_mapModelToEntryBonds).toList();
  }

  List<EntryBondModel> _mapModelToEntryBonds<T>(T model) {
    return EntryBondCreatorFactory.resolveEntryBondCreators(model)
        .map(
          (creator) => creator.createEntryBond(
            originType: EntryBondCreatorFactory.resolveOriginType(model),
            model: model,
          ),
        )
        .toList();
  }

  EntryBondModel createChequeEntryBondByStrategy(ChequesModel model, {required ChequesStrategyType chequesStrategyType}) {
    final creators = ChequesStrategyBondFactory.determineStrategy(model, type: chequesStrategyType);
    return creators.first.createEntryBond(
      model: model,
      originType: EntryBondCreatorFactory.resolveOriginType(model),
    );
  }

  Future<void> createAndStoreChequeEntryBondByStrategy(
    ChequesModel model, {
    required ChequesStrategyType chequesStrategyType,
    required int sourceNumber,
    required bool isSave,
  }) async {
    final entryBondModel = createChequeEntryBondByStrategy(model, chequesStrategyType: chequesStrategyType);
    await read<EntryBondController>().saveEntryBondModel(
      entryBondModel: entryBondModel,
      sourceNumber: sourceNumber,
      isSave: isSave,
    );
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
