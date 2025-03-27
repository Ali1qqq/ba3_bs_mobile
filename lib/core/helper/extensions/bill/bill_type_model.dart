import '../../../../features/patterns/data/models/bill_type_model.dart';

extension BillTypeExtension on BillTypeModel {
  bool get isSale => billTypeId == "6ed3786c-08c6-453b-afeb-a0e9075dd26d";

  bool get isPurchase => billTypeId == "eb10653a-a43f-44e5-889d-41ce68c43ec4";

  bool get isSalesReturn => billTypeId == "2373523c-9f23-4ce7-a6a2-6277757fc381";

  bool get isPurchaseReturn => billTypeId == "507f9e7d-e44e-4c4e-9761-bb3cd4fc1e0d";

  bool get isAdjustmentEntry => billTypeId == "06f0e6ea-3493-480c-9e0c-573baf049605";

  bool get isOutputAdjustment => billTypeId == "563af9aa-5d7e-470b-8c3c-fee784da810a";

  bool get isFirstPeriodInventory => billTypeId == "5a9e7782-cde5-41db-886a-ac89732feda7";

  bool get isTransferIn => billTypeId == "494fa945-3fe5-4fc3-86d6-7a9999b6c9e8";

  bool get isTransferOut => billTypeId == "35c75331-1917-451e-84de-d26861134cd4";
}
