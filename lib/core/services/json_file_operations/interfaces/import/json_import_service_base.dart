import 'dart:convert';
import 'dart:io';

import 'i_json_import_service.dart';

abstract class JsonImportServiceBase<T> implements IJsonImportService<T> {
  /// Abstract method to be implemented by subclasses for JSON parsing
  @override
  List<T> fromImportJson(Map<String, dynamic> json);

  @override
  List<T> importFromFile(String filePath) {
    final File file = File(filePath);
    final jsonContent = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

    return fromImportJson(jsonContent);
  }
}
