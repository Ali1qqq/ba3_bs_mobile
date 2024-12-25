import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import '../../interfaces/import/i_json_import_repository.dart';
import '../../interfaces/import/i_json_import_service.dart';

class JsonImportRepository<T> implements IJsonImportRepository<T> {
  final IJsonImportService<T> _jsonImport;

  JsonImportRepository(this._jsonImport);

  @override
  Either<Failure, List<T>> importJsonFile(String filePath) {
    try {
      List<T> itemsModels = _jsonImport.importFromFile(filePath);
      return Right(itemsModels);
    } catch (e) {
      log('[$e] فشل في استيراد الملف');
      return Left(ErrorHandler(e).failure);
    }
  }
}
