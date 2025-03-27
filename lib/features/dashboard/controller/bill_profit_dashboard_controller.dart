import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/models/date_filter.dart';
import '../../../core/network/api_constants.dart';
import '../../bill/controllers/bill/all_bills_controller.dart';
import '../../bill/data/models/bill_model.dart';
import '../../materials/controllers/material_controller.dart';
import '../../sellers/controllers/seller_sales_controller.dart';
import '../../sellers/data/models/seller_model.dart';
import '../ui/widgets/employee_commitment_chart.dart';

class BillProfitDashboardController extends GetxController with FloatingLauncher {
  Rx<RequestState> profitsBillsRequest = RequestState.initial.obs;

  @override
  void onInit() {
    super.onInit();
    initProfitChartData();
  }

  List<BillModel> billsAndProfitChartData = [];
  double totalMonthSales = 0;
  double totalMonthFees = 0;
  double minX = 0;
  double maxX = 0;
  double maxY = 0;
  List<FlSpot> profitSpots = [];
  List<FlSpot> totalSellsSpots = [];
  Rx<DateTime> profitMonth = DateTime.now().obs;
  Rx<bool> isTotalSalesVisible = true.obs;
  Rx<bool> isProfitVisible = true.obs;

  set setProfitMonth(DateTime setMonth) {
    profitMonth.value = setMonth;
  }

  changeProfitVisibility() {
    isProfitVisible.value = !isProfitVisible.value;
    generateDailyProfitData();
  }

  changeTotalVisibility() {
    isTotalSalesVisible.value = !isTotalSalesVisible.value;
    generateDailyProfitData();
  }

  void generateDailyProfitData() {
    Map<String, double> dailyProfits = {};
    Map<String, double> dailyTotal = {};
    totalMonthFees = 0;

    for (var bill in billsAndProfitChartData) {
      double totalProfit = calculateBillProfit(bill);

      // Convert bill date to a standardized key (yyyy-MM-dd)
      String dayKey = DateFormat('yyyy-MM-dd').format(
        DateTime.utc(
          bill.billDetails.billDate!.year,
          bill.billDetails.billDate!.month,
          bill.billDetails.billDate!.day,
        ),
      );

      // Update profits and total sales
      updateDailyData(dailyProfits, dayKey, totalProfit);
      updateDailyData(dailyTotal, dayKey, bill.billDetails.billTotal ?? 0);
    }

    // Convert map entries to FlSpot lists
    profitSpots = mapToFlSpotList(dailyProfits);
    totalSellsSpots = mapToFlSpotList(dailyTotal);
    totalMonthFees = dailyProfits.values.fold(
      0.0,
      (previousValue, element) => previousValue + element,
    );
    // Sorting & setting min/max values
    setChartBoundaries();

    update();
  }

  /// **Calculates the total profit for a given bill**
  double calculateBillProfit(BillModel bill) {
    double totalProfit = 0.0;

    for (final item in bill.items.itemList) {
      double itemCalcPrice = read<MaterialController>().getMaterialMinPriceById(item.itemGuid);

      if (item.itemSubTotalPrice != null) {
        totalProfit += item.itemSubTotalPrice! - itemCalcPrice;
      }
    }

    // totalMonthFees += totalProfit;
    return totalProfit;
  }

  /// **Updates daily data maps (profits & total sales)**
  void updateDailyData(Map<String, double> dataMap, String dayKey, double value) {
    if (dataMap.containsKey(dayKey)) {
      dataMap[dayKey] = dataMap[dayKey]! + value;
    } else {
      dataMap[dayKey] = value;
    }
  }

  /// **Converts a map of daily values into a sorted list of FlSpot**
  List<FlSpot> mapToFlSpotList(Map<String, double> dataMap) {
    return dataMap.entries.map((entry) {
      DateTime date = DateFormat('yyyy-MM-dd').parseUtc(entry.key);
      return FlSpot(date.millisecondsSinceEpoch.toDouble(), entry.value);
    }).toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  /// **Sets minX, maxX, and maxY for the chart**
  void setChartBoundaries() {
    minX = profitSpots.isNotEmpty ? profitSpots.first.x : 0;
    maxX = profitSpots.isNotEmpty ? profitSpots.last.x : 1;
    maxY = totalSellsSpots.isNotEmpty
        ? totalSellsSpots.map((e) => e.y).reduce((value, element) => value > element ? value : element) + 10000
        : 1;
  }

  initProfitChartData() async {
    await getProfitChartData();
    generateDailyProfitData();
  }

  void onProfitMothChange(DateTime date) async {
    setProfitMonth = date;
    await initProfitChartData();
    update();
  }

  void lunchBillScreen({required BuildContext context, int? index}) {
    if (index != null) {
      final bill = billsAndProfitChartData.groupBy((p0) => p0.billDetails.billDate!.toString().split(' ')[0]);

      read<AllBillsController>().lunchBillsScreen(bill[bill.keys.elementAt(index)]!, context);
    } else {
      read<AllBillsController>().lunchBillsScreen(billsAndProfitChartData, context);
    }
  }

  Future<void> getProfitChartData() async {
    profitsBillsRequest.value = RequestState.loading;
    billsAndProfitChartData = await read<AllBillsController>().fetchBillsByDate(
      BillType.sales.billTypeModel,
      DateFilter(
          dateFieldName: ApiConstants.billDate,
          range: DateTimeRange(
            start: DateTime(profitMonth.value.year, profitMonth.value.month, 1, 0, 0, 0),
            end: DateTime(profitMonth.value.year, profitMonth.value.month + 1, 0, 23, 59, 59),
          )),
    );

    totalMonthSales = billsAndProfitChartData.fold(
      0,
      (previousValue, element) => previousValue + element.billDetails.billTotal!,
    );
    profitsBillsRequest.value = RequestState.success;
    update();
  }

  List<SellerSalesData> usersDetails = [];

  getAllEmployeeCommitment() async {
    usersDetails = read<SellerSalesController>().getSellerCommitment(
        bills: await read<AllBillsController>().fetchBillsByDate(
      BillType.sales.billTypeModel,
      DateFilter(
        dateFieldName: ApiConstants.billDate,
        range: DateTimeRange(
          start: DateTime(profitMonth.value.year, profitMonth.value.month, 1, 0, 0, 0),
          end: DateTime(profitMonth.value.year, profitMonth.value.month + 1, 0, 23, 59, 59),
        ),
      ),
    ));

    update();
  }

  List<Employee> convertedUsersToEmployees() {
    return usersDetails.map((user) {
      return Employee(
        name: user.sellerName,
        accessoriesTarget: user.totalAccessorySales,
        mobilesTarget: user.totalMobileSales,
        absentDays: user.totalDayAttendance!,
        lateDays: user.totalDayLate!,
        taskCompletion: 0,
      );
    }).toList();
  }
}