import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../bond/data/models/entry_bond_model.dart';
import '../../users_management/controllers/user_management_controller.dart';
import '../data/models/log_model.dart';

class LogController extends GetxController {
  final RemoteDataSourceRepository<LogModel> _repository;

  LogController(this._repository);

  final logs = <LogModel>[].obs;
  final filteredLogs = <LogModel>[].obs;
  final isLoading = false.obs;

  final searchController = TextEditingController();

  RxnString selectedEventType = RxnString();

  final String allLabel = 'الكل';

  @override
  void onInit() {
    super.onInit();
    selectedEventType.value = allLabel;
  }

  Future<void> loadLogs() async {
    isLoading.value = true;
    final result = await _repository.getAll();
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (logList) {
        logs.value = logList;
        applyFilters();
      },
    );
    isLoading.value = false;
  }

  void applyFilters() {
    final searchText = searchController.text;

    filteredLogs.value = logs.where(
      (log) {
        final matchesSearch = searchText.isEmpty || log.userName.contains(searchText) || log.note.contains(searchText);

        final matchesType =
            selectedEventType.value == null || selectedEventType.value == allLabel || log.eventType.label == selectedEventType.value;

        return matchesSearch && matchesType;
      },
    ).toList();
  }

  LogModel getLogModel({
    required EntryBondModel entryBondModel,
    required LogEventType eventType,
    required int sourceNumber,
  }) {
    final userName = read<UserManagementController>().loggedInUserModel!.userName!;
    return LogModel.fromEntryBondModel(
      userName: userName,
      entry: entryBondModel,
      eventType: eventType,
      sourceNumber: sourceNumber,
    );
  }

  Future<void> addLog(LogModel log) async {
    final result = await _repository.save(log);
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedLog) {
        logs.add(savedLog);
        applyFilters();
      },
    );
  }

  Future<void> deleteLog(String id) async {
    final result = await _repository.delete(id);
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) {
        logs.removeWhere((log) => log.id == id);
        applyFilters();
      },
    );
  }

  Color getEventColor(LogEventType type) {
    switch (type) {
      case LogEventType.add:
        return Colors.green;
      case LogEventType.update:
        return Colors.orange;
      case LogEventType.delete:
        return Colors.red;
    }
  }

  IconData getEventIcon(LogEventType type) {
    switch (type) {
      case LogEventType.add:
        return Icons.add_circle;
      case LogEventType.update:
        return Icons.edit;
      case LogEventType.delete:
        return Icons.delete;
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy - hh:mm a').format(date);
  }
}