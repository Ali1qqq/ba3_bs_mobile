import 'dart:developer';

import 'package:ba3_bs_mobile/core/network/error/error_handler.dart';
import 'package:dartz/dartz.dart';

import '../../../../network/error/failure.dart';
import '../../interfaces/export/i_export_repository.dart';
import '../../interfaces/export/i_export_service.dart';

class ExportRepository<T> implements IExportRepository<T> {
  final IExportService<T> _jsonExport;

  ExportRepository(this._jsonExport);

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
