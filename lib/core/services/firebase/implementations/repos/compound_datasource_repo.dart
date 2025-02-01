import 'dart:developer';

import 'package:ba3_bs_mobile/core/models/query_filter.dart';
import 'package:dartz/dartz.dart';

import '../../../../models/date_filter.dart';
import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import '../../interfaces/compound_datasource_base.dart';

class CompoundDatasourceRepository<T, I> {
  final CompoundDatasourceBase<T, I> _dataSource;

  CompoundDatasourceRepository(this._dataSource);

  Future<Either<Failure, List<T>>> fetchWhere<V>(
      {required I itemIdentifier, required String field, required V value, DateFilter? dateFilter}) async {
    try {
      final savedItems = await _dataSource.fetchWhere(itemIdentifier: itemIdentifier, field: field, value: value, dateFilter: dateFilter);
      return Right(savedItems); // Return the list of saved items
    } catch (e, stackTrace) {
      log('Error in fetchWhere: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, T>> getById({required String id, required I itemIdentifier}) async {
    try {
      final item = await _dataSource.fetchById(id: id, itemIdentifier: itemIdentifier);
      return Right(item); // Return the found item
    } catch (e, stackTrace) {
      log('Error in getById: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }

  Future<Either<Failure, Unit>> delete(T item) async {
    try {
      await _dataSource.delete(item: item);
      return const Right(unit); // Return success
    } catch (e, stackTrace) {
      log('Error in delete: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, T>> save(T item) async {
    try {
      final savedItem = await _dataSource.save(item: item);
      return Right(savedItem); // Return success
    } catch (e, stackTrace) {
      log('Error in save: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, int>> count({required I itemIdentifier, QueryFilter? countQueryFilter}) async {
    try {
      final count = await _dataSource.countDocuments(itemIdentifier: itemIdentifier, countQueryFilter: countQueryFilter);
      return Right(count); // Return the found item
    } catch (e, stackTrace) {
      log('Error in count: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }

  Future<Either<Failure, List<T>>> getAll(I itemIdentifier) async {
    try {
      final items = await _dataSource.fetchAll(itemIdentifier: itemIdentifier);
      return Right(items); // Return list of items
    } catch (e, stackTrace) {
      log('Error in getAll: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, List<T>>> saveAll(List<T> items, I itemIdentifier) async {
    try {
      final savedItems = await _dataSource.saveAll(items: items, itemIdentifier: itemIdentifier);
      return Right(savedItems); // Return the list of saved items
    } catch (e, stackTrace) {
      log('Error in saveAll: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, Map<I, List<T>>>> saveAllNested(
    List<T> items,
    List<I> itemIdentifiers,
    void Function(double progress)? onProgress,
  ) async {
    try {
      final savedItems = await _dataSource.saveAllNested(items: items, itemIdentifiers: itemIdentifiers, onProgress: onProgress);
      return Right(savedItems); // Return the list of saved items
    } catch (e, stackTrace) {
      log('Error in saveAllNested: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, Map<I, List<T>>>> fetchAllNested(List<I> itemIdentifiers) async {
    try {
      final nestedItems = await _dataSource.fetchAllNested(itemIdentifiers: itemIdentifiers);
      return Right(nestedItems); // Return list of  Nested items
    } catch (e, stackTrace) {
      log('Error in fetchAllNested: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }
}
