import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import '../../../firebase/interfaces/compound_datasource_base.dart';
import '../../interfaces/local_datasource_base.dart';

class LocalDatasourceRepository<T, I> {
  final LocalDatasourceBase<T> localDatasource;
  final CompoundDatasourceBase<T, I> remoteDatasource;

  LocalDatasourceRepository({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  bool hasConnection = true;

  Future<Either<Failure, List<T>>> getAll(I itemIdentifier) async {
    try {
      if (!hasConnection) {
        final localData = await localDatasource.getAllData();

        return Right(localData);
      }

      // Fetch from remote if local is empty
      final remoteData = await remoteDatasource.fetchAll(itemIdentifier: itemIdentifier);

      await localDatasource.saveAllData(remoteData);

      log('remoteData ${remoteData.length}');

      return Right(remoteData);
    } catch (e, stackTrace) {
      log('Error in getAll: $e', stackTrace: stackTrace, name: 'LocalDatasourceRepository getAll');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, T?>> getById({required String id, required I itemIdentifier}) async {
    try {
      if (!hasConnection) {
        final localData = localDatasource.getDataById(id);

        return Right(localData);
      }

      // Fetch from remote if not found locally
      final remoteData = await remoteDatasource.fetchById(id: id, itemIdentifier: itemIdentifier);

      if (remoteData != null) {
        await localDatasource.saveData(remoteData);
      }

      return Right(remoteData);
    } catch (e, stackTrace) {
      log('Error in getById: $e', stackTrace: stackTrace, name: 'LocalDatasourceRepository getById');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, T>> save(T data) async {
    try {
      final savedItem = await remoteDatasource.save(item: data);

      await localDatasource.saveData(savedItem);

      return Right(savedItem);
    } catch (e, stackTrace) {
      log('Error in save: $e', stackTrace: stackTrace, name: 'LocalDatasourceRepository save');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, List<T>>> saveAll(List<T> data, I itemIdentifier) async {
    try {
      await remoteDatasource.saveAll(items: data, itemIdentifier: itemIdentifier);

      await localDatasource.saveAllData(data);

      return Right(data);
    } catch (e, stackTrace) {
      log('Error in saveAll: $e', stackTrace: stackTrace, name: 'LocalDatasourceRepository saveAll');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, T>> update(T data) async {
    try {
      final updatedItem = await remoteDatasource.save(item: data);

      await localDatasource.updateData(updatedItem);

      return Right(updatedItem);
    } catch (e, stackTrace) {
      log('Error in update: $e', stackTrace: stackTrace, name: 'LocalDatasourceRepository update');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> updateAll(List<T> data) async {
    try {
      await localDatasource.updateAllData(data);

      return Right(unit);
    } catch (e, stackTrace) {
      log('Error in updateAll: $e', stackTrace: stackTrace, name: 'LocalDatasourceRepository updateAll');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> delete(T item, String itemId) async {
    try {
      await remoteDatasource.delete(item: item);

      await localDatasource.removeData(item);

      return Right(unit);
    } catch (e, stackTrace) {
      log('Error in delete: $e', stackTrace: stackTrace, name: 'LocalDatasourceRepository delete');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> deleteAll(List<T> data) async {
    try {
      await localDatasource.removeAllData(data);

      return Right(unit);
    } catch (e, stackTrace) {
      log('Error in deleteAll: $e', stackTrace: stackTrace, name: 'LocalDatasourceRepository deleteAll');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> clear() async {
    try {
      await localDatasource.clearAllData();

      return Right(unit);
    } catch (e, stackTrace) {
      log('Error in clear: $e', stackTrace: stackTrace, name: 'LocalDatasourceRepository clear');
      return Left(ErrorHandler(e).failure);
    }
  }
}