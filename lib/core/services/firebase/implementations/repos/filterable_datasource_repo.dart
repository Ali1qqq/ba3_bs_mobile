import 'dart:developer';

import 'package:ba3_bs_mobile/core/services/firebase/interfaces/filterable_datasource.dart';
import 'package:dartz/dartz.dart';

import '../../../../models/date_filter.dart';
import '../../../../models/query_filter.dart';
import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import 'remote_datasource_repo.dart';

class FilterableDatasourceRepository<T> extends RemoteDatasourceRepository<T> {
  final FilterableDatasource<T> _filterableDatasource;

  FilterableDatasourceRepository(this._filterableDatasource) : super(_filterableDatasource);

  Future<Either<Failure, List<T>>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter}) async {
    try {
      final savedItems = await _filterableDatasource.fetchWhere(queryFilters: queryFilters);
      return Right(savedItems); // Return the list of saved items
    } catch (e) {
      log('Error in fetchWhere: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
