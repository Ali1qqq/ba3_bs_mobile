import 'package:ba3_bs_mobile/core/models/date_filter.dart';
import 'package:ba3_bs_mobile/core/models/query_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/filterable_datasource.dart';
import 'package:ba3_bs_mobile/features/user_loan_requests/data/model/loan_request_model.dart';

class LoanRequestRemoteDatasource
    extends FilterableDatasource<LoanRequestModel> {
  LoanRequestRemoteDatasource({required super.databaseService});

  @override
  String get path => ApiConstants.loanRequests;

  @override
  Future<List<LoanRequestModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);
    return data.map((e) => LoanRequestModel.fromJson(e)).toList();
  }

  @override
  Future<LoanRequestModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return LoanRequestModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<LoanRequestModel> save(LoanRequestModel item) async {
    final data = await databaseService.add(
      path: path,
      documentId: item.id,
      data: item.toJson(),
    );

    return LoanRequestModel.fromJson(data);
  }

  @override
  Future<List<LoanRequestModel>> fetchWhere({
    required List<QueryFilter<dynamic>>? queryFilters,
    DateFilter? dateFilter,
  }) async {
    final data = await databaseService.fetchWhere(
      path: path,
      queryFilters: queryFilters,
      dateFilter: dateFilter,
    );

    return data.map((e) => LoanRequestModel.fromJson(e)).toList();
  }
}
