import 'dart:io';

import 'package:xml/xml.dart';

abstract class IImportService<T> {
  List<T> fromImportJson(Map<String, dynamic> json);

  Future<List<T>> fromImportXml(XmlDocument document);

  List<T> importFromJsonFile(File filePath);

  Future<List<T>> importFromXmlFile(File filePath);

}
