import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../network/error/error_handler.dart';
import '../../../network/error/failure.dart';
import '../interfaces/export/i_export_repository.dart';
import '../interfaces/export/i_export_service.dart';
import '../interfaces/import/i_import_repository.dart';
import '../interfaces/import/i_import_service.dart';

class ImportExportRepository<T>
    implements IImportRepository<T>, IExportRepository<T> {
  final IImportService<T> _jsonImport;
  final IExportService<T> _jsonExport;

  ImportExportRepository(this._jsonImport, this._jsonExport);

  @override
  Either<Failure, List<T>> importJsonFile(File filePath) {
    try {
      List<T> itemsModels = _jsonImport.importFromJsonFile(filePath);
      return Right(itemsModels);
    } catch (e) {
      log('[$e] فشل في استيراد الملف');
      return Left(ErrorHandler(e).failure);
    }
  }

  @override
  Future<Either<Failure, List<T>>> importXmlFile(File filePath) async {
    // try {
    List<T> itemsModels = await _jsonImport.importFromXmlFile(filePath);
    return Right(itemsModels);
    // } catch (e) {
    //   log('[$e] فشل في استيراد الملف');
    //   return Left(ErrorHandler(e).failure);
    // }
  }

  @override
  Future<Either<Failure, String>> exportJsonFile(List<T> itemsModels) async {
    try {
      String filePath = await _jsonExport.exportToFile(itemsModels);
      return Right(filePath);
    } catch (e) {
      log('[$e] فشل في تصدير الملف');
      return Left(ErrorHandler(e).failure);
    }
  }
}
