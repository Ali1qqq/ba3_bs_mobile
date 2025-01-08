import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../network/error/failure.dart';

abstract class IImportRepository<T> {
  Either<Failure, List<T>> importJsonFile(File filePath);

  Either<Failure, List<T>> importXmlFile(File filePath);
}
