import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';

import '../../../../../features/accounts/data/models/account_model.dart';
import '../../../../../features/patterns/data/models/bill_type_model.dart';

mixin FirestorePathHelper<ItemTypeModel> {
  /// Retrieves the root document ID based on the model type.
  /// Example: "eb10653a-a43f-44e5-889d-41ce68c43ec4"
  String getRootDocumentId(ItemTypeModel typeModel) {
    if (typeModel is BillTypeModel) {
      return typeModel.billTypeId ?? (throw ArgumentError('billTypeId is required for BillTypeModel.'));
    }
    if (typeModel is BondType) {
      return typeModel.typeGuide;
    }
    if (typeModel is ChequesType) {
      return typeModel.typeGuide;
    }
    if (typeModel is AccountEntity) {
      return typeModel.id;
    }

    throw ArgumentError('Unsupported typeModel for getRootDocumentId.');
  }

  /// Retrieves the sub-collection path based on the model type.
  /// Example: "purchase", "sales"
  String getSubCollectionPath(ItemTypeModel typeModel) {
    final label = switch (typeModel) {
      BillTypeModel(:final billTypeLabel) => billTypeLabel,
      BondType(:final label) => label,
      ChequesType(:final label) => label,
      AccountEntity(:final name) => name,
      _ => throw ArgumentError('Unsupported typeModel for getSubCollectionPath.'),
    };

    if (label == null) {
      throw ArgumentError('A valid label is required for the provided typeModel.');
    }

    return label.replaceAll('/', ' ');
  }
}
