abstract class IJsonExportService<T> {
  Map<String, dynamic> toExportJson(List<T> itemsModels);

  Future<String> exportToFile(List<T> itemsModels);
}
