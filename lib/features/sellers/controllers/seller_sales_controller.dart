import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/models/date_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import 'package:ba3_bs_mobile/features/pluto/controllers/pluto_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/data/models/seller_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../bill/data/models/bill_model.dart';
import '../../patterns/data/models/bill_type_model.dart';
import '../ui/widgets/target_pointer_widget.dart';
import 'add_seller_controller.dart';

class SellerSalesController extends GetxController with AppNavigator {
  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;
  final BulkSavableDatasourceRepository<SellerModel> _sellersFirebaseRepo;

  SellerSalesController(this._billsFirebaseRepo, this._sellersFirebaseRepo);

  // List of bills for the seller
  final List<BillModel> sellerBills = [];
  final List<BillModel> filteredBills = [];

  bool isLoading = false;

  SellerModel? selectedSeller;

  PickerDateRange? dateRange;

  final GlobalKey<TargetPointerWidgetState> accessoriesKey = GlobalKey<TargetPointerWidgetState>();
  final GlobalKey<TargetPointerWidgetState> mobilesKey = GlobalKey<TargetPointerWidgetState>();

  bool inFilterMode = false;

  List<BillModel> get sellerSales => inFilterMode ? filteredBills : sellerBills;

  double get totalSales => calculateTotalSales(sellerSales);

  double totalAccessoriesSales = 0.0;
  double totalMobilesSales = 0.0;

  Future<void> addSeller(SellerModel seller) async {
    final result = await _sellersFirebaseRepo.save(seller);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedSellers) {},
    );
  }

  Future<void> addSellers(List<SellerModel> sellers) async {
    final result = await _sellersFirebaseRepo.saveAll(sellers);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedSellers) {},
    );
  }

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
  void onSelectSeller(SellerModel sellerModel) {
    setDateRange = defaultDateRange;

    setSelectedSeller = sellerModel;

    fetchSellerBillsByDate(
      sellerModel: sellerModel,
      dateTimeRange: DateTimeRange(start: defaultDateRange.startDate!, end: defaultDateRange.endDate!),
    );
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
        if (!inFilterMode) {
          AppUIUtils.onFailure('لا توجد فواتير مسجلة ل${sellerModel.costName} ❌');
        } else {
          AppUIUtils.onFailure(' لا توجد أي فواتير مسجلة لـ ${sellerModel.costName} في هذا التاريخ❌ ');

          clearFilter();
        }
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
    navigateToSellerSalesScreen();
  }

  // Method to calculate the total sales
  double calculateTotalSales(List<BillModel> bills) => bills.fold(0.0, (sum, bill) => sum + (bill.billDetails.billTotal ?? 0));

  void calculateTotalAccessoriesMobiles() {
    // Reset totals
    totalAccessoriesSales = 0;
    totalMobilesSales = 0;

    final bills = inFilterMode ? filteredBills : sellerBills;

    // Iterate through all bills
    for (final bill in bills) {
      // Iterate through all items in each bill
      for (final item in bill.items.itemList) {
        if (item.itemSubTotalPrice != null) {
          double itemTotal = item.itemTotalPrice.toDouble;

          if (item.itemSubTotalPrice! < 1000) {
            log('${item.itemName} total price = $itemTotal');
            totalAccessoriesSales += itemTotal;
          } else {
            totalMobilesSales += itemTotal;
          }
        }
      }
    }

    log('totalAccessoriesSales = $totalAccessoriesSales');
    log('totalMobilesSales = $totalMobilesSales');
  }

  void navigateToAddSellerScreen([SellerModel? seller]) {
    read<AddSellerController>().init(seller);
    to(AppRoutes.addSellerScreen);
  }

  void navigateToAllSellersScreen() async {
    await read<SellersController>().fetchProbabilitySellers();
    to(AppRoutes.allSellersScreen);
  }

  void navigateToSellerSalesScreen() => to(AppRoutes.sellerSalesScreen);

  void navigateToSellerTargetScreen() => to(AppRoutes.sellerTargetScreen);
}
