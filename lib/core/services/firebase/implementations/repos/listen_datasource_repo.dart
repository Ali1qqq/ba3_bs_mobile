import 'dart:developer';

import 'package:ba3_bs_mobile/core/services/firebase/interfaces/listen_datasource.dart';
import 'package:dartz/dartz.dart';

import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import 'remote_datasource_repo.dart';

class ListenDataSourceRepository<T> extends RemoteDataSourceRepository<T> {
  final ListenableDatasource<T> _listenableDatasource;

  ListenDataSourceRepository(this._listenableDatasource) : super(_listenableDatasource);

  Either<Failure, Stream<T>> listenDoc(String userId) {
    try {
      final documentStream = _listenableDatasource.subscribeToDoc(documentId: userId);
      return Right(documentStream);
    } catch (e, stackTrace) {
      log('Error in listenDoc: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, List<T>>> saveAll(List<T> items) async {
    try {
      final savedItems = await _listenableDatasource.saveAll(items);
      return Right(savedItems); // Return the list of saved items
    } catch (e, stackTrace) {
      log('Error in saveAll: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
