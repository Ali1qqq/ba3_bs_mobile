import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/models/date_filter.dart';
import '../../../core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../accounts/controllers/accounts_controller.dart';
import '../../bill/controllers/bill/all_bills_controller.dart';
import '../../bond/controllers/bonds/all_bond_controller.dart';
import '../../cheques/controllers/cheques/all_cheques_controller.dart';
import '../../materials/controllers/material_controller.dart';
import '../data/models/log_model.dart';
import '../services/log_model_factory.dart';
import '../services/log_origin_factory.dart';

class LogController extends GetxController with FloatingLauncher {
  final FilterableDataSourceRepository<LogModel> _repository;

  LogController(this._repository);

  final logs = <LogModel>[].obs;
  final filteredLogs = <LogModel>[].obs;
  final isLoading = false.obs;

  final searchController = TextEditingController();

  RxnString selectedEventType = RxnString();

  final String allLabel = 'الكل';

  final Rxn<PickerDateRange> logDateRange = Rxn<PickerDateRange>();

  @override
  void onInit() {
    super.onInit();
    selectedEventType.value = allLabel;
  }

  PickerDateRange get defaultDateRange {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    return PickerDateRange(firstDay, lastDay);
  }

  void onDateRangeSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    logDateRange.value = args.value;
  }

  void onDateRangeSubmit(BuildContext context) {
    if (logDateRange.value?.startDate != null && logDateRange.value?.endDate != null) {
      loadLogs(context);
    }
  }

  Future<void> loadLogs(BuildContext context) async {
    isLoading.value = true;
    final result = await _repository.fetchWhere(
        dateFilter: DateFilter(
      dateFieldName: 'date',
      range: DateTimeRange(
        start: logDateRange.value?.startDate ?? DateTime.now(),
        end: logDateRange.value?.endDate ?? DateTime.now(),
      ),
    ));
    result.fold(
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
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
        final matchesSearch = searchText.isEmpty ||
            log.userName.toLowerCase().contains(searchText.toLowerCase()) ||
            log.note.toLowerCase().contains(searchText.toLowerCase());

        final matchesType =
            selectedEventType.value == null || selectedEventType.value == allLabel || log.eventType.label == selectedEventType.value;

        return matchesSearch && matchesType;
      },
    ).toList();
  }

  Future<void> addLog<T>({required T item, required LogEventType eventType, int? sourceNumber}) async {
    final LogModel logModel = LogModelFactory.create(item: item, eventType: eventType, sourceNumber: sourceNumber);

    final result = await _repository.save(logModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
      (savedLog) {
        logs.add(savedLog);
        applyFilters();
      },
    );
  }

  Future<void> deleteLog(String id, BuildContext context) async {
    final result = await _repository.delete(id);
    result.fold(
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
      (_) {
        logs.removeWhere((log) => log.sourceId == id);
        applyFilters();
      },
    );
  }

  /// Opens the relevant screen or details view based on the origin type of the log entry
  void openLogModelOrigin(LogModel log, BuildContext context) {
    // Resolve the origin og the log (bill, cheque, bond, etc.)
    final logOrigin = log.resolveOrigin();

    // Get the source ID and source type related ro the log entry (used to fetch details)
    final originId = log.sourceId;
    final sourceType = log.sourceType;

    // Define a map of actions for each possible LogOrigin
    final actions = {
      /// If the log is a bond (e.g., payment, receipt), open bond details
      LogOrigin.bond: () => read<AllBondsController>().openBondDetailsById(
            originId,
            context,
            BondType.byValue(sourceType),
          ),

      /// Ig the log is related to a bill (Invoice or settlement), open bill details
      LogOrigin.bill: () {
        read<AllBillsController>().openFloatingBillDetailsById(
          billId: originId,
          context: context,
          bilTypeModel: BillType.byValue(sourceType).billTypeModel,
        );
      },

      /// If the log is a cheque, open cheque details
      LogOrigin.cheque: () => read<AllChequesController>().openChequesDetailsById(
            originId,
            context,
            ChequesType.byValue(sourceType),
          ),

      /// If the log is related to a material item, navigate to the material screen
      LogOrigin.material: () => read<MaterialController>().navigateToAddOrUpdateMaterialScreen(
            matId: originId,
            context: context,
          ),

      /// If the related log is related to an account, navigate to the account screen
      LogOrigin.account: () => read<AccountsController>().navigateToAddOrUpdateAccountScreen(
            accountId: originId,
            context: context,
          ),
    };

    // Execute the corresponding action fot the resolved log origin
    final action = actions[logOrigin];
    if (action != null) {
      action();
    }
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

  String formatShortDate(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }
}