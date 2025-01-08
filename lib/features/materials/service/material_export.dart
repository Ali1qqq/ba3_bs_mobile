import 'package:ba3_bs_mobile/features/materials/data/models/material_model.dart';

import '../../../../core/services/json_file_operations/interfaces/export/export_service_base.dart';

class MaterialExport extends ExportServiceBase<MaterialModel> {
  /// Converts the list of `BillModel` to the exportable JSON structure
  @override
  Map<String, dynamic> toExportJson(List<MaterialModel> itemsModels) {
    return {};
  }
}
