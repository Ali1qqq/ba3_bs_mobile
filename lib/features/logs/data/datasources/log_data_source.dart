import 'package:ba3_bs_mobile/core/services/firebase/interfaces/filterable_datasource.dart';

import '../../../../core/models/date_filter.dart';
import '../../../../core/models/query_filter.dart';
import '../../../../core/network/api_constants.dart';
import '../models/log_model.dart';

class LogDataSource extends FilterableDatasource<LogModel> {
  LogDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.logs;

  @override
  Future<List<LogModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);
    return data.map((item) => LogModel.fromJson(item)).toList();
  }

  @override
  Future<LogModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return LogModel.fromJson(item);
  }

  @override
  Future<List<LogModel>> fetchWhere({required List<QueryFilter>? queryFilters, DateFilter? dateFilter}) async {
    final data = await databaseService.fetchWhere(path: path, queryFilters: queryFilters, dateFilter: dateFilter);

    final users = data.map((item) => LogModel.fromJson(item)).toList();

    return users;
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<LogModel> save(LogModel item) async {
    final data = await databaseService.add(path: path, documentId: item.docId, data: item.toJson());
    return LogModel.fromJson(data);
  }
}