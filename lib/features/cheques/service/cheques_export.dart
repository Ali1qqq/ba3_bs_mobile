
import '../../../../core/services/json_file_operations/interfaces/export/export_service_base.dart';
import '../data/models/cheques_model.dart';

class ChequesExport extends ExportServiceBase<ChequesModel> {
  @override
  Map<String, dynamic> toExportJson(List<ChequesModel> itemsModels) {
    return {

    };
  }


}
