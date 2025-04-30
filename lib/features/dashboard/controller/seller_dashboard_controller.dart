import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/models/date_filter.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/styling/app_colors.dart';
import '../../../core/styling/app_text_style.dart';
import '../../bill/controllers/bill/all_bills_controller.dart';
import '../../bill/data/models/bill_model.dart';
import '../../sellers/controllers/seller_sales_controller.dart';
import '../../sellers/data/models/seller_model.dart';
import '../../sellers/ui/screens/all_sellers_screen.dart';

class SellerDashboardController extends GetxController with FloatingLauncher {
  @override
  void onInit() {
    super.onInit();
    getSellersBillsByDate();
  }

  Rx<RequestState> sellerBillsRequest = RequestState.initial.obs;

  List<SellerSalesData> sellerChartData = [];
  List<BarChartGroupData> sellerBarGroups = [];

  double sellerMaxY = 0;

  double totalSellerSales = 0;
  double totalSellerSalesAccessory = 0;
  double totalSellerSalesMobile = 0;
  double totalSellerFees = 0;
  CrossFadeState crossSellerFadeState = CrossFadeState.showFirst;
  bool sellerTotalFees = true;
  bool isSellerMobileTargetVisible = true;
  bool isSellerAccessoryTargetVisible = true;
  List<BillModel> allSellerBillsThisMonth = [];
  PickerDateRange dateRange = PickerDateRange(DateTime.now(), DateTime.now());
  final now = DateTime.now();

  List<PieChartSectionData> getSellerPieChartSections() {
    return List.generate(sellerChartData.length, (index) {
      final seller = sellerChartData[index];
      final totalSales = seller.totalAccessorySales + seller.totalMobileSales;

      return PieChartSectionData(
        value: totalSales.toDouble(),
        title: "${seller.sellerName}\n${totalSales.toString().formatNumber()}",
        radius: 170,
        borderSide: BorderSide(color: Colors.black),
        titlePositionPercentageOffset: index.isEven ? 0.6 : 0.3,
        titleStyle: AppTextStyles.headLineStyle4.copyWith(color: Colors.white),
        color: generateSellerPieChartColor(index),
      );
    });
  }

  Color generateSellerPieChartColor(int index) {
    double hue = 180 + (index * 20) % 50;
    return HSVColor.fromAHSV(0.9, hue, 0.8, 0.85).toColor();
  }

  lunchSellerScree(BuildContext context, int index) {
    read<SellerSalesController>().launchToSellerSalesScreen(sellerChartData[index].bills, context, dateRange);
  }

  getSellersBillsByDate() async {
    sellerBillsRequest.value = RequestState.loading;
    allSellerBillsThisMonth = await read<AllBillsController>().fetchBillsByDate(
      BillType.sales.billTypeModel,
      DateFilter(
        dateFieldName: ApiConstants.billDate,
        range: DateTimeRange(start: dateRange.startDate ?? now, end: dateRange.endDate ?? now),
      ),
    );

    log('getSellersBillsByDate ${allSellerBillsThisMonth.length}');
    getSellerChartData();
    update();
    sellerBillsRequest.value = RequestState.success;
  }

  Future<void> onSubmitDateRangePicker() async {
    if (!isValidDateRange()) return;

    log('onSubmitDateRangePicker ${dateRange.startDate}, ${dateRange.endDate}');
    getSellersBillsByDate();
  }

  bool isValidDateRange() {
    final startDate = dateRange.startDate;
    final endDate = dateRange.endDate;

    if (endDate == null && startDate != null) {
      log('dateRange!.endDate == null');

      /// Last day of the month
      ///
      /// setting the day to 0 in the DateTime constructor rolls back to the last day of the previous month.
      final lastDayOfMonth = DateTime(startDate.year, startDate.month + 1, 0);
      setDateRange = PickerDateRange(startDate, lastDayOfMonth);
      update();
    } else if (startDate == null && endDate != null) {
      log('dateRange!.startDate == null');
      final startDay = DateTime(endDate.year, endDate.month, 1); // First day of the month
      setDateRange = PickerDateRange(startDay, endDate);
      update();
    }

    return true;
  }

  set setDateRange(PickerDateRange newValue) {
    dateRange = newValue;
  }

  void onSelectionChanged(dateRangePickerSelectionChangedArgs) {
    setDateRange = dateRangePickerSelectionChangedArgs.value;
  }

  swapSellerCrossFadeState() {
    if (crossSellerFadeState == CrossFadeState.showFirst) {
      crossSellerFadeState = CrossFadeState.showSecond;
    } else if (crossSellerFadeState == CrossFadeState.showSecond) {
      crossSellerFadeState = CrossFadeState.showFirst;
    }
    update();
  }

  getSellerChartData() {
    sellerChartData = read<SellerSalesController>().aggregateSalesBySeller(bills: allSellerBillsThisMonth);
    totalSellerSales = sellerChartData.fold(
      0,
      (previousValue, element) => previousValue + element.totalAccessorySales + element.totalMobileSales,
    );
    totalSellerSalesAccessory = sellerChartData.fold(
      0,
      (previousValue, element) => previousValue + element.totalAccessorySales,
    );
    totalSellerSalesMobile = sellerChartData.fold(
      0,
      (previousValue, element) => previousValue + element.totalMobileSales,
    );
    totalSellerFees = sellerChartData.fold(
      0,
      (previousValue, element) => previousValue + element.totalFess,
    );
    _getBarGroups();
  }

  changeSellerTotalFees() {
    sellerTotalFees = !sellerTotalFees;
    _getBarGroups();
    update();
  }

  _getBarGroups() {
    sellerBarGroups.clear();
    for (int i = 0; i < sellerChartData.length; i++) {
      sellerBarGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            if (isSellerMobileTargetVisible)
              BarChartRodData(
                toY: sellerChartData[i].totalMobileSales,
                width: 20,
                color: AppColors.mobileSaleColor,
                borderRadius: BorderRadius.circular(3),
              ),
            if (isSellerAccessoryTargetVisible)
              BarChartRodData(
                toY: sellerChartData[i].totalAccessorySales,
                width: 20,
                color: AppColors.accessorySaleColor,
                borderRadius: BorderRadius.circular(3),
              ),
            if (sellerTotalFees)
              BarChartRodData(
                toY: sellerChartData[i].totalFess < 0 ? 0 : sellerChartData[i].totalFess,
                width: 20,
                color: AppColors.feesSaleColor,
                borderRadius: BorderRadius.circular(3),
              ),
          ],
        ),
      );
    }

    sellerMaxY = sellerChartData.isNotEmpty ? sellerChartData.map((d) => d.totalMobileSales).reduce((a, b) => a > b ? a : b) : 0;
    sellerMaxY *= 2;
  }

  void changeSellerTotalMobileTarget() {
    isSellerMobileTargetVisible = !isSellerMobileTargetVisible;
    _getBarGroups();
    update();
  }

  void changeSellerAccessoryTarget() {
    isSellerAccessoryTargetVisible = !isSellerAccessoryTargetVisible;
    _getBarGroups();
    update();
  }

  openAllSellersSales(BuildContext context) {
    launchFloatingWindow(context: context, floatingScreen: AllSellersScreen());
  }
}