import 'dart:developer';

import 'package:ba3_bs_mobile/core/services/firebase/interfaces/bulk_savable_datasource.dart';
import 'package:dartz/dartz.dart';

import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import 'remote_datasource_repo.dart';

class BulkSavableDatasourceRepository<T> extends DataSourceRepository<T> {
  final BulkSavableDatasource<T> _bulkSavableDatasource;

  BulkSavableDatasourceRepository(this._bulkSavableDatasource) : super(_bulkSavableDatasource);

  Future<Either<Failure, List<T>>> saveAll(List<T> items) async {
    try {
      final savedItems = await _bulkSavableDatasource.saveAll(items);
      return Right(savedItems); // Return the list of saved items
    } catch (e) {
      log('Error in fetchWhere: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
