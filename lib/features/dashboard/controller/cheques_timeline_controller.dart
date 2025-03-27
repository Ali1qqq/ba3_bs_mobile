import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/features/cheques/data/models/cheques_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../cheques/controllers/cheques/all_cheques_controller.dart';

class ChequesTimelineController extends GetxController with FloatingLauncher {
  @override
  void onInit() {
    super.onInit();
    getAllDuesCheques();
  }

  Rx<RequestState> chequesChartRequestState = RequestState.initial.obs;

  final DateTime now = DateTime.now();

  DateTime get lastWeek => now.subtract(const Duration(days: 7));

  DateTime get thisMonth => now.subtract(const Duration(days: 30));

  final Map<String, int> groupedData = {};

  List<MapEntry<String, int>> sortedEntries = [];
  List<String> datesList = [];
  List<BarChartGroupData> barGroups = [];
  List<ChequesModel> allCheques = [];

  int get allChequesLength => allCheques.length;

  int get allChequesDuesLength => allCheques
      .where(
        (user) => user.isPayed != true,
      )
      .length;

  /// this for cheques in this month
  List<ChequesModel> get allChequesDuesThisMonth => allCheques
      .where(
        (user) => user.isPayed != true && DateTime.parse(user.chequesDueDate!).isBefore(now.add(Duration(days: 30))),
      )
      .toList();

  int get allChequesDuesThisMonthLength => allChequesDuesThisMonth.length;

  /// this for cheques Last 10 days
  List<ChequesModel> get allChequesDuesLastTen => allCheques
      .where(
        (user) => user.isPayed != true && DateTime.parse(user.chequesDueDate!).isBefore(now.add(Duration(days: 10))),
      )
      .toList();

  int get allChequesDuesLastTenLength => allChequesDuesLastTen.length;

  /// this for cheques today
  List<ChequesModel> get allChequesDuesToday => allCheques
      .where(
        (user) => user.isPayed != true && DateTime.parse(user.chequesDueDate!).isBefore(now),
      )
      .toList();

  int get allChequesDuesTodayLength => allChequesDuesToday.length;

  getAllDuesCheques() async {
    chequesChartRequestState.value = RequestState.loading;
    barGroups = [];
    groupedData.clear();
    allCheques = await read<AllChequesController>().fetchChequesByType(ChequesType.paidChecks);
    List<DateTime> dueDates = allCheques
        .where((cheque) =>
            cheque.isPayed != true &&
            cheque.chequesDueDate != null &&
            DateTime.parse(cheque.chequesDueDate!).isBefore(now.add(const Duration(days: 1))))
        .map((cheque) => DateTime.parse(cheque.chequesDueDate!))
        .toList();
    for (var date in dueDates) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      groupedData.update(formattedDate, (value) => value + 1, ifAbsent: () => 1);
    }

    sortedEntries = groupedData.entries.toList()..sort((a, b) => DateTime.parse(a.key).compareTo(DateTime.parse(b.key)));

    datesList = sortedEntries.map((e) => e.key).toList();
    int index = 0;

    for (var entry in sortedEntries) {
      DateTime dueDate = DateTime.parse(entry.key);

      Color barColor = dueDate.isAfter(lastWeek)
          ? Colors.red
          : dueDate.isAfter(thisMonth)
              ? AppColors.accessorySaleColor
              : AppColors.blueColor;

      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: entry.value.toDouble(),
              color: barColor,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      index++;
    }
    chequesChartRequestState.value = RequestState.success;
  }

  openChequesDuesScreen(BuildContext context) {
    read<AllChequesController>().navigateToChequesScreen(onlyDues: true, context: context);
  }

  void lunchChequesScreen(BuildContext context, int index) {
    log(sortedEntries.elementAt(index).key);

    read<AllChequesController>().navigateToChequesScreenByList(
        chequesListItems: allCheques
            .where(
              (element) => element.chequesDueDate == sortedEntries.elementAt(index).key && element.isPayed == false,
            )
            .toList(),
        context: context);
  }
}