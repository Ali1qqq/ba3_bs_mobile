abstract class IJsonImportService<T> {
  List<T> fromImportJson(Map<String, dynamic> json);

  List<T> importFromFile(String filePath);
}
