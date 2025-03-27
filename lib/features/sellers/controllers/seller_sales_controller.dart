import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/task_status_extension.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs_mobile/core/models/date_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/features/pluto/controllers/pluto_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/add_seller_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/data/models/seller_model.dart';
import 'package:ba3_bs_mobile/features/sellers/ui/screens/add_seller_screen.dart';
import 'package:ba3_bs_mobile/features/sellers/ui/screens/all_sellers_screen.dart';
import 'package:ba3_bs_mobile/features/sellers/ui/screens/seller_sales_screen.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../bill/data/models/bill_model.dart';
import '../../materials/controllers/material_controller.dart';
import '../../patterns/data/models/bill_type_model.dart';
import '../ui/widgets/target_pointer_widget.dart';

class SellerSalesController extends GetxController with AppNavigator, FloatingLauncher {
  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;

  SellerSalesController(this._billsFirebaseRepo);

  // List of bills for the seller
  final List<BillModel> sellerBills = [];
  final List<BillModel> filteredBills = [];

  bool isLoading = false;

  SellerModel? selectedSeller;

  PickerDateRange? dateRange;

  Rx<RequestState> profileScreenState = RequestState.initial.obs;

  final GlobalKey<TargetPointerWidgetState> accessoriesKey = GlobalKey<TargetPointerWidgetState>();
  final GlobalKey<TargetPointerWidgetState> mobilesKey = GlobalKey<TargetPointerWidgetState>();

  bool inFilterMode = false;

  List<BillModel> get sellerSales => inFilterMode ? filteredBills : sellerBills;

  double get totalSales => calculateTotalSales(sellerSales);

  double totalAccessoriesSales = 0.0;
  double totalMobilesSales = 0.0;
  double totalFees = 0.0;

  set setSelectedSeller(SellerModel sellerModel) {
    selectedSeller = sellerModel;
  }

  set setInFilterMode(bool newValue) {
    inFilterMode = newValue;
  }

  set setDateRange(PickerDateRange newValue) {
    dateRange = newValue;
  }

  bool isValidDateRange() {
    if (dateRange == null) {
      return false;
    }

    final startDate = dateRange!.startDate;
    final endDate = dateRange!.endDate;

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

  Future<void> onSubmitDateRangePicker() async {
    if (!isValidDateRange()) return;

    log('onSubmitDateRangePicker ${dateRange!.startDate}, ${dateRange!.endDate}');
    isLoading = true;
    update();

    setInFilterMode = true;

    await fetchSellerBillsByDate(
      sellerModel: selectedSeller!,
      dateTimeRange: DateTimeRange(start: dateRange!.startDate!, end: dateRange!.endDate!),
    );

    isLoading = false;
    update();
  }

  void onSelectionChanged(dateRangePickerSelectionChangedArgs) {
    setDateRange = dateRangePickerSelectionChangedArgs.value;
  }

  PickerDateRange get defaultDateRange {
    final currentDate = DateTime.now();
    final startDay = DateTime(currentDate.year, currentDate.month, 1);

    return PickerDateRange(startDay, currentDate);
  }

  void clearFilter() {
    setDateRange = defaultDateRange;

    setInFilterMode = false;
    filteredBills.assignAll([]);

    read<PlutoController>().updatePlutoKey();
    update();
  }

  // Sets the selected seller and fetches their bills
  Future<void> onSelectSeller({SellerModel? sellerModel, String? sellerId}) async {
    if (sellerModel == null && sellerId == null) return;
    profileScreenState.value = RequestState.loading;
    sellerModel ??= read<SellersController>().getSellerById(sellerId!);
    setDateRange = defaultDateRange;

    setSelectedSeller = sellerModel;

    await fetchSellerBillsByDate(
      sellerModel: sellerModel,
      dateTimeRange: DateTimeRange(start: defaultDateRange.startDate!, end: defaultDateRange.endDate!),
    );
  }

  Future<int> getSellerMaterialsSales({required String sellerId, required DateTimeRange dateTimeRange, required String materialId}) async {
    int matQuantity = 0;
    log(sellerId);
    final result = await _billsFirebaseRepo.fetchWhere(
      itemIdentifier: BillType.sales.billTypeModel,
      field: ApiConstants.billSellerId,
      value: sellerId,
      dateFilter: DateFilter(
        dateFieldName: ApiConstants.billDate,
        range: dateTimeRange,
      ),
    );

    result.fold(
      (failure) {},
      (bills) => matQuantity = _handleGetSellerMaterialsSalesSuccess(bills, materialId),
    );

    return matQuantity;
  }

  Future<void> fetchSellerBillsByDate({required SellerModel sellerModel, required DateTimeRange dateTimeRange}) async {
    final result = await _billsFirebaseRepo.fetchWhere(
      itemIdentifier: BillType.sales.billTypeModel,
      field: ApiConstants.billSellerId,
      value: sellerModel.costGuid,
      dateFilter: DateFilter(
        dateFieldName: ApiConstants.billDate,
        range: dateTimeRange,
      ),
    );

    result.fold(
      (failure) {
        if (inFilterMode) {
          AppUIUtils.onFailure(' لا توجد أي فواتير مسجلة لـ ${sellerModel.costName} في هذا التاريخ❌ ');
          totalAccessoriesSales = 0;
          totalMobilesSales = 0;
          clearFilter();
        }
        sellerBills.clear();
      },
      (bills) => _handleGetSellerBillsStatusSuccess(bills),
    );
  }

  _handleGetSellerBillsStatusSuccess(List<BillModel> bills) {
    if (inFilterMode) {
      filteredBills.assignAll(bills);
    } else {
      sellerBills.assignAll(bills);
    }
    calculateTotalAccessoriesMobiles();
  }

  int _handleGetSellerMaterialsSalesSuccess(List<BillModel> bills, String materialId) {
    // log("all bills ${bills.length}");
    // log("all bills ${bills.map((bill) => bill.billDetails.billDate)}");
    int matQuantity = 0;
    log('material in task $materialId');
    for (final bill in bills) {
      for (final item in bill.items.itemList) {
        log('material in bill ${read<MaterialController>().getMaterialNameById(item.itemGuid)}');
        if (item.itemGuid == materialId) {
          log((item.itemGuid == materialId).toString());
          matQuantity += item.itemQuantity;
        }
      }
    }
    return matQuantity;
  }

  // Method to calculate the total sales
  double calculateTotalSales(List<BillModel> bills) => bills.fold(0.0, (sum, bill) => sum + (bill.billDetails.billTotal ?? 0));

  void calculateTotalAccessoriesMobiles() {
    // Reset totals
    totalAccessoriesSales = 0;
    totalMobilesSales = 0;
    totalFees = 0;

    final bills = inFilterMode ? filteredBills : sellerBills;
    log("calculateTotalAccessoriesMobiles ${bills.length}");
    // Iterate through all bills
    for (final bill in bills) {
      // Iterate through all items in each bill
      for (final item in bill.items.itemList) {
        double itemCalcPrice = read<MaterialController>().getMaterialMinPriceById(item.itemGuid);

        if (item.itemSubTotalPrice != null) {
          totalFees += item.itemSubTotalPrice! - itemCalcPrice;
          double itemTotal = item.itemTotalPrice.toDouble;

          if (item.itemSubTotalPrice! < 1000) {
            totalAccessoriesSales += itemTotal;
          } else {
            totalMobilesSales += itemTotal;
          }
        }
      }
    }
    profileScreenState.value = RequestState.success;

    safeUpdateUI();
  }

  void safeUpdateUI() => WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then(
        (value) {
          update();
        },
      );

  void navigateToAddSellerScreen({SellerModel? seller, required BuildContext context}) {
    read<AddSellerController>().init(seller);
    launchFloatingWindow(context: context, floatingScreen: AddSellerScreen(), defaultHeight: 100.h, defaultWidth: 200.w);

    // to(AppRoutes.addSellerScreen);
  }

  void navigateToAllSellersScreen(BuildContext context) async {
    launchFloatingWindow(context: context, floatingScreen: AllSellersScreen());

    // to(AppRoutes.allSellersScreen);
  }

  void navigateToSellerSalesScreen(SellerModel sellerModel, BuildContext context) async {
    sellerBills.clear();
    await onSelectSeller(sellerModel: sellerModel);
    if (!context.mounted) return;
    if (sellerBills.isNotEmpty) {
      launchFloatingWindow(context: context, floatingScreen: SellerSalesScreen());
    } else {
      AppUIUtils.onFailure(' لا توجد فواتير مسجلة لـ ${sellerModel.costName} في هذا التاريخ❌ ');
    }
  }

  void launchToSellerSalesScreen(List<BillModel> bills, BuildContext context, PickerDateRange dashDateRange) async {
    dateRange = dashDateRange;
    _handleGetSellerBillsStatusSuccess(bills);

    launchFloatingWindow(context: context, floatingScreen: SellerSalesScreen());
    // await onSelectSeller(sellerModel: sellerModel);
  }

  void navigateToSellerTargetScreen() => to(AppRoutes.sellerTargetScreen);

  List<SellerSalesData> getSellerCommitment({
    required List<BillModel> bills,
  }) {
    final Map<String, List<BillModel>> salesMap = {};
    DateTime startDay = bills.first.billDetails.billDate!;
    DateTime endDay = bills.first.billDetails.billDate!;
    for (final bill in bills) {
      if (bill.billDetails.billDate!.isAfter(endDay)) {
        endDay = bill.billDetails.billDate!;
      }
      if (bill.billDetails.billDate!.isBefore(startDay)) {
        startDay = bill.billDetails.billDate!;
      }
      final sellerId = bill.billDetails.billSellerId ?? 'unknown';
      if (read<SellersController>().getSellerNameById(sellerId) == '') {
        if (salesMap['8c0uymE4qoesqsKWDlqx'] != null) {
          salesMap['8c0uymE4qoesqsKWDlqx']!.add(bill);
        } else {
          salesMap['8c0uymE4qoesqsKWDlqx'] = [bill];
        }
        continue;
      }
      if (salesMap[sellerId] != null) {
        salesMap[sellerId]!.add(bill);
      } else {
        salesMap[sellerId] = [bill];
      }
    }

    return salesMap.entries.map((entry) {
      final sellerName = read<SellersController>().getSellerNameById(entry.key);
      final userModel = read<UserManagementController>().getUserBySellerId(entry.key);
      _handleGetSellerBillsStatusSuccess(entry.value);
      return SellerSalesData(
          sellerName: sellerName,
          totalMobileSales: totalMobilesSales,
          totalAccessorySales: totalAccessoriesSales,
          totalFess: totalFees,
          totalFiledTasks: userModel == null
              ? 0
              : userModel.userTaskList
                      ?.where(
                        (task) => task.status.isFailed,
                      )
                      .length ??
                  0,
          totalDayAttendance: userModel == null
              ? 0
              : getUserAttendanceStats(
                      userTime: userModel.userTimeModel!, userHolidays: userModel.userHolidays!, startDate: startDay, endDate: endDay)
                  .totalAbsents,
          totalDayLate: userModel == null
              ? 0
              : getUserAttendanceStats(
                      userTime: userModel.userTimeModel!, userHolidays: userModel.userHolidays!, startDate: startDay, endDate: endDay)
                  .totalAbsents,
          bills: entry.value);
    }).toList();
  }

  AttendanceStats getUserAttendanceStats({
    required Map<String, UserTimeModel> userTime,
    required List<String> userHolidays,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    int absentDays = 0;
    int totalDelays = 0;

    final dateFormat = DateFormat('yyyy-MM-dd');

    for (DateTime date = startDate; !date.isAfter(endDate); date = date.add(Duration(days: 1))) {
      final dateStr = dateFormat.format(date);
      if (userHolidays.contains(dateStr)) continue;
      if (userTime.containsKey(dateStr)) {
        final dayData = userTime[dateStr];
        final delay = dayData?.totalLogInDelay ?? 0;
        totalDelays += delay;
      } else {
        absentDays++;
      }
    }

    return AttendanceStats(
      totalAbsents: absentDays,
      totalDelays: totalDelays,
    );
  }

  List<SellerSalesData> aggregateSalesBySeller({
    required List<BillModel> bills,
  }) {
    final Map<String, List<BillModel>> salesMap = {};
    for (final bill in bills) {
      final sellerId = bill.billDetails.billSellerId ?? 'unknown';
      if (read<SellersController>().getSellerNameById(sellerId) == '') {
        if (salesMap['8c0uymE4qoesqsKWDlqx'] != null) {
          salesMap['8c0uymE4qoesqsKWDlqx']!.add(bill);
        } else {
          salesMap['8c0uymE4qoesqsKWDlqx'] = [bill];
        }
        continue;
      }
      if (salesMap[sellerId] != null) {
        salesMap[sellerId]!.add(bill);
      } else {
        salesMap[sellerId] = [bill];
      }
    }

    return salesMap.entries.map((entry) {
      final sellerName = read<SellersController>().getSellerNameById(entry.key);
      _handleGetSellerBillsStatusSuccess(entry.value);
      return SellerSalesData(
          sellerName: sellerName,
          totalMobileSales: totalMobilesSales,
          totalAccessorySales: totalAccessoriesSales,
          totalFess: totalFees,
          bills: entry.value);
    }).toList();
  }
}

class AttendanceStats {
  final int totalAbsents;
  final int totalDelays;

  AttendanceStats({
    required this.totalAbsents,
    required this.totalDelays,
  });
}