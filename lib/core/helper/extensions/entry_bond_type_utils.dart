import '../../../features/bond/data/models/entry_bond_model.dart';
import '../enums/enums.dart';

extension EntryBondTypeUtils on EntryBondOrigin {
  /// Returns the exact source type (from BillType, BondType, or ChequesType) based on the origin
  String get getSourceType {
    final EntryBondType? entryBondType = originType;
    final String? typeGuide = originTypeId;

    if (entryBondType == null || typeGuide == null) {
      throw ArgumentError('originType or originTypeId is null');
    }

    switch (entryBondType) {
      case EntryBondType.bill:
        return BillType.byTypeGuide(typeGuide).value;

      case EntryBondType.bond:
        return BondType.byTypeGuide(typeGuide).value;

      case EntryBondType.cheque:
        return ChequesType.byTypeGuide(typeGuide).value;
    }
  }
}
