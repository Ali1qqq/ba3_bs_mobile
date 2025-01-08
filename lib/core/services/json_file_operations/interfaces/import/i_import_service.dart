import 'dart:io';

import 'package:xml/xml.dart';

abstract class IImportService<T> {
  List<T> fromImportJson(Map<String, dynamic> json);

  List<T> fromImportXml(XmlDocument document);

  List<T> importFromJsonFile(File filePath);

  List<T> importFromXmlFile(File filePath);
}
