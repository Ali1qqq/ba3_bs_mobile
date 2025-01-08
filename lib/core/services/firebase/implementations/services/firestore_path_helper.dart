import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';

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

    throw ArgumentError('Unsupported typeModel for getRootDocumentId.');
  }

  /// Retrieves the sub-collection path based on the model type.
  /// Example: "purchase", "sales"
  String getSubCollectionPath(ItemTypeModel typeModel) {
    if (typeModel is BillTypeModel) {
      return typeModel.billTypeLabel ?? (throw ArgumentError('billTypeLabel is required for BillTypeModel.'));
    }
    if (typeModel is BondType) {
      return typeModel.label;
    }
    if (typeModel is ChequesType) {
      return typeModel.label;
    }
    throw ArgumentError('Unsupported typeModel for getSubcollectionPath.');
  }
}
