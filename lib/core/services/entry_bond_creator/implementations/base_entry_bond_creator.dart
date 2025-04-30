import '../../../../features/bond/data/models/entry_bond_model.dart';
import '../../../helper/enums/enums.dart';
import '../interfaces/entry_bond_creator.dart';

abstract class BaseEntryBondCreator<T> implements EntryBondCreator<T> {
  @override
  EntryBondModel createEntryBond({
    required EntryBondType originType,
    required T model,
    bool? isSimulatedVat,
  }) =>
      EntryBondModel(
        origin: createOrigin(model: model, originType: originType),
        items: EntryBondItems(
          id: getModelId(model),
          itemList: generateItems(model: model, isSimulatedVat: isSimulatedVat),
        ),
      );

  EntryBondOrigin createOrigin(
      {required T model, required EntryBondType originType});

  String getModelId(T model);

  List<EntryBondItemModel> generateItems(
      {required T model, bool? isSimulatedVat});
}
