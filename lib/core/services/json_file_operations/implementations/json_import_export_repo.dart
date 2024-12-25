import 'package:dartz/dartz.dart';

import '../../../network/error/failure.dart';
import '../interfaces/export/i_json_export_repository.dart';
import '../interfaces/import/i_json_import_repository.dart';

class JsonImportExportRepository<T> implements IJsonImportRepository<T>, IJsonExportRepository<T> {
  final IJsonImportRepository<T> _importRepo;
  final IJsonExportRepository<T> _exportRepo;

  JsonImportExportRepository(this._importRepo, this._exportRepo);

  @override
  Either<Failure, List<T>> importJsonFile(String filePath) {
    return _importRepo.importJsonFile(filePath);
  }

  @override
  Future<Either<Failure, String>> exportJsonFile(List<T> itemsModels) async {
    return await _exportRepo.exportJsonFile(itemsModels);
  }
}
