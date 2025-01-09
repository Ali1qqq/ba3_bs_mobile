import 'dart:developer';

import 'package:ba3_bs_mobile/core/services/firebase/interfaces/listen_datasource.dart';
import 'package:dartz/dartz.dart';

import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import 'remote_datasource_repo.dart';

class ListenDataSourceRepository<T> extends RemoteDatasourceRepository<T> {
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
}
