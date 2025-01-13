import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import '../../../firebase/interfaces/remote_datasource_base.dart';
import '../../interfaces/local_datasource_base.dart';

class LocalDatasourceRepository<T> {
  final LocalDatasourceBase<T> localDatasource;
  final RemoteDatasourceBase<T> remoteDatasource;

  LocalDatasourceRepository({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  Future<Either<Failure, List<T>>> getAll() async {
    try {
      final localData = await localDatasource.getAllData();
      if (localData.isNotEmpty) {
        log('localData ${localData.length}');
        return Right(localData);
      }

      // Fetch from remote if local is empty
      final remoteData = await remoteDatasource.fetchAll();
      await localDatasource.saveAllData(remoteData);
      log('remoteData ${remoteData.length}');

      return Right(remoteData);
    } catch (e) {
      log('Error in getAll: $e');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, T?>> getById(String id) async {
    try {
      final localData = await localDatasource.getDataById(id);
      if (localData != null) {
        return Right(localData);
      }

      // Fetch from remote if not found locally
      final remoteData = await remoteDatasource.fetchById(id);
      if (remoteData != null) {
        await localDatasource.saveData(remoteData);
      }
      return Right(remoteData);
    } catch (e) {
      log('Error in getById: $e');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, T>> save(T data) async {
    try {
      final savedItem = await remoteDatasource.save(data);

      await localDatasource.saveData(data);

      return Right(savedItem); // Return success
    } catch (e) {
      log('Error in save on LocalDatasourceRepository: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, List<T>>> saveAll(List<T> data) async {
    try {
      await localDatasource.saveAllData(data);

      return Right(data);
    } catch (e) {
      log('Error in saveAll: $e');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> delete(T item, String itemId) async {
    try {
      await remoteDatasource.delete(itemId);

      await localDatasource.removeData(item);

      return Right(unit); // Return success
    } catch (e) {
      log('Error in delete on LocalDatasourceRepository: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, Unit>> deleteAll(List<T> data) async {
    try {
      await localDatasource.removeAllData(data);
      return Right(unit);
    } catch (e) {
      log('Error in delete all: $e');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> clear() async {
    try {
      await localDatasource.clearAllData();
      return Right(unit);
    } catch (e) {
      log('Error in clear: $e');
      return Left(ErrorHandler(e).failure);
    }
  }
}
