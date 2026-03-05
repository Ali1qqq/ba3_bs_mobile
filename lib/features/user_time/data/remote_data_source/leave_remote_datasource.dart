import 'package:ba3_bs_mobile/core/models/date_filter.dart';
import 'package:ba3_bs_mobile/core/models/query_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/filterable_datasource.dart';
import 'package:ba3_bs_mobile/features/user_time/data/models/leave_requests_model.dart';

class LeaveRemoteDatasource extends FilterableDatasource<LeaveRequestModel> {
  LeaveRemoteDatasource({required super.databaseService});

  @override
  String get path => ApiConstants.leaveRequests;

  @override
  Future<List<LeaveRequestModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);
    return data.map((e) => LeaveRequestModel.fromJson(e)).toList();
  }

  @override
  Future<LeaveRequestModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return LeaveRequestModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<LeaveRequestModel> save(LeaveRequestModel item) async {
    final data = await databaseService.add(
      path: path,
      documentId: item.id,
      data: item.toJson(),
    );

    return LeaveRequestModel.fromJson(data);
  }

  @override
  Future<List<LeaveRequestModel>> fetchWhere(
      {required List<QueryFilter<dynamic>>? queryFilters,
      DateFilter? dateFilter}) async {
    final data = await databaseService.fetchWhere(
        path: path, queryFilters: queryFilters, dateFilter: dateFilter);

    final leaves =
        data.map((item) => LeaveRequestModel.fromJson(item)).toList();

    return leaves;
  }
}
