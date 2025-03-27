import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

import 'i_import_service.dart';

abstract class ImportServiceBase<T> implements IImportService<T> {
  /// Abstract method to be implemented by subclasses for JSON parsing
  @override
  List<T> fromImportJson(Map<String, dynamic> json);

  @override
  Future<List<T>> fromImportXml(XmlDocument document);

  @override
  List<T> importFromJsonFile(File file) {
    final jsonContent = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    return fromImportJson(jsonContent);
  }

  @override
  Future<List<T>> importFromXmlFile(File file)async {
    final xmlContent = file.readAsStringSync();
    final XmlDocument document = XmlDocument.parse(xmlContent);

    return fromImportXml(document);
  }
}
