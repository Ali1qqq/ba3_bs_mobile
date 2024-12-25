import 'package:dartz/dartz.dart';

import '../../../../network/error/failure.dart';

abstract class IJsonExportRepository<T> {
  Future<Either<Failure, String>> exportJsonFile(List<T> itemsModels);
}
