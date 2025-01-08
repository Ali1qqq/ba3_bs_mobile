import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import '../../interfaces/import/i_import_repository.dart';
import '../../interfaces/import/i_import_service.dart';

class ImportRepository<T> implements IImportRepository<T> {
  final IImportService<T> _jsonImport;

  ImportRepository(this._jsonImport);

  @override
  Either<Failure, List<T>> importJsonFile(File file) {
    try {
      List<T> itemsModels = _jsonImport.importFromJsonFile(file);
      return Right(itemsModels);
    } catch (e) {
      log('[$e] فشل في استيراد الملف');
      return Left(ErrorHandler(e).failure);
    }
  }

  @override
  Either<Failure, List<T>> importXmlFile(File file) {
    try {
      List<T> itemsModels = _jsonImport.importFromXmlFile(file);
      return Right(itemsModels);
    } catch (e) {
      log('[$e] فشل في استيراد الملف');
      return Left(ErrorHandler(e).failure);
    }
  }
}
