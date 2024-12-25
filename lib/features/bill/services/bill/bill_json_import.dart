import '../../../../core/services/json_file_operations/interfaces/import/json_import_service_base.dart';
import '../../data/models/bill_model.dart';

class BillJsonImport extends JsonImportServiceBase<BillModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BillModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson = jsonContent['Bill'] ?? [];
    return billsJson.map((billJson) => BillModel.fromImportedJsonFile(billJson as Map<String, dynamic>)).toList();
  }
}
