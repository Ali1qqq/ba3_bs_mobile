import 'package:dartz/dartz.dart';

import '../../../../network/error/failure.dart';

abstract class IJsonImportRepository<T> {
  Either<Failure, List<T>> importJsonFile(String filePath);
}
