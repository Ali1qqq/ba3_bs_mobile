import 'package:dartz/dartz.dart';

import '../../../../network/error/failure.dart';

abstract class IExportRepository<T> {
  Future<Either<Failure, String>> exportJsonFile(List<T> itemsModels);
}
