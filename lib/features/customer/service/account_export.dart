import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';

import '../../../../core/services/json_file_operations/interfaces/export/export_service_base.dart';

class AccountExport extends ExportServiceBase<AccountModel> {
  /// Converts the list of `BillModel` to the exportable JSON structure
  @override
  Map<String, dynamic> toExportJson(List<AccountModel> itemsModels) {
    return {};
  }
}