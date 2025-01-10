import 'dart:developer';

import 'package:ba3_bs_mobile/core/services/firebase/interfaces/queryable_savable_datasource.dart';
import 'package:dartz/dartz.dart';

import '../../../../models/date_filter.dart';
import '../../../../models/query_filter.dart';
import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import 'remote_datasource_repo.dart';

class QueryableSavableRepository<T> extends RemoteDataSourceRepository<T> {
  final QueryableSavableDatasource<T> _queryableSavableDatasource;

  QueryableSavableRepository(this._queryableSavableDatasource) : super(_queryableSavableDatasource);

  Future<Either<Failure, List<T>>> saveAll(List<T> items) async {
    try {
      final savedItems = await _queryableSavableDatasource.saveAll(items);
      return Right(savedItems); // Return the list of saved items
    } catch (e, stackTrace) {
      log('Error in saveAll: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, List<T>>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter}) async {
    try {
      final filteredItems = await _queryableSavableDatasource.fetchWhere(queryFilters: queryFilters);
      return Right(filteredItems); // Return the list of filtered items
    } catch (e, stackTrace) {
      log('Error in fetchWhere: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
