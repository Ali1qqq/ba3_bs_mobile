abstract class IExportService<T> {
  Map<String, dynamic> toExportJson(List<T> itemsModels);

  Future<String> exportToFile(List<T> itemsModels);
}
