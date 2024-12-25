import 'dart:developer';

import 'package:ba3_bs_mobile/core/network/error/error_handler.dart';
import 'package:ba3_bs_mobile/core/network/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../interfaces/datasource_base.dart';

class DataSourceRepository<T> {
  final DatasourceBase<T> _dataSource;

  DataSourceRepository(this._dataSource);

  Future<Either<Failure, List<T>>> getAll() async {
    try {
      final items = await _dataSource.fetchAll();
      return Right(items); // Return list of items
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, T>> getById(String id) async {
    try {
      final item = await _dataSource.fetchById(id);
      return Right(item); // Return the found item
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }

  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return const Right(unit); // Return success
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, T>> save(T item, [bool? save]) async {
    try {
      final savedItem = await _dataSource.save(item, save);
      return Right(savedItem); // Return success
    } catch (e) {
      log('Error in save: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
