import 'package:ba3_bs_mobile/features/materials/data/models/mat_statement/mat_statement_model.dart';
import 'package:ba3_bs_mobile/features/materials/service/mat_statement_creator.dart';

import '../../../../features/bill/data/models/bill_model.dart';
import '../../../core/helper/enums/enums.dart';

class MatStatementCreatorFactory {
  static MatStatementCreator resolveMatStatementCreator<T>(T model) {
    if (model is BillModel) {
      // Returns a single BillEntryBondCreator wrapped in a list
      return BillMatStatementCreator();
    }
    throw UnimplementedError("No EntryBondCreator implementation for model of type ${model.runtimeType}");
  }

  static MatOrigin resolveOriginType<T>(T model) {
    if (model is BillModel) {
      return MatOrigin(
        originId: model.billId,
        originNumber: model.billDetails.billNumber,
        originTypeId: model.billTypeModel.billTypeId,
        originType: MatOriginType.bill,
      );
    }
    throw UnimplementedError("No EntryBondType defined for model of type ${model.runtimeType}");
  }
}