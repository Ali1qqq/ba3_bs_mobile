import 'package:ba3_bs_mobile/core/network/error/error_handler.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/network/error/failure.dart';
import '../models/bill_items.dart';
import '../models/bill_model.dart';
import 'first_period_inventory_data_source.dart';

class FirstPeriodInventoryRepository {
  final FirstPeriodInventoryDataSource _dataSource;

  FirstPeriodInventoryRepository(this._dataSource);

  /// Uploads the given [bill] with chunked items to Firestore.
  ///
  /// Optionally does additional domain logic: e.g., validate items,
  /// handle chunkSize, transformations, etc.
  Future<Either<Failure, Unit>> uploadLargeBill({
    required BillModel bill,
    required void Function(double) onProgress,
    int chunkSize = 250,
  }) async {
    try {
      await _dataSource.uploadBillAndItemsInChunks(
        bill: bill,
        onProgress: onProgress,
        chunkSize: chunkSize,
      );
      return right(unit);
    } catch (e) {
      return left(ErrorHandler(e).failure);
    }
  }

  /// Retrieves all items from a given bill's subcollection and merges them
  Future<Either<Failure, List<BillItem>>> fetchAllBillItems({
    required String billTypeId,
    required String billTypeLabel,
    required String billId,
  }) async {
    try {
      final fetchAllBillItems = await _dataSource.fetchBillItems(
        billTypeId: billTypeId,
        billTypeLabel: billTypeLabel,
        billId: billId,
      );
      return right(fetchAllBillItems);
    } catch (e) {
      return left(ErrorHandler(e).failure);
    }
  }
}