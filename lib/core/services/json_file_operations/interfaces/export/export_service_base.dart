import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'i_export_service.dart';

abstract class ExportServiceBase<T> implements IExportService<T> {
  /// Abstract method to be implemented by subclasses for JSON conversion
  @override
  Map<String, dynamic> toExportJson(List<T> itemsModels);

  /// Shared method for exporting JSON data to a file
  @override
  Future<String> exportToFile(List<T> itemsModels) async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String filePath = '${documentsDirectory.path}/exported_data.json';

    final File file = File(filePath);
    final jsonContent = jsonEncode(toExportJson(itemsModels));

    await file.writeAsString(jsonContent);

    return filePath;
  }
}
