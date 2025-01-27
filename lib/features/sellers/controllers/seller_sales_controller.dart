import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/models/date_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import 'package:ba3_bs_mobile/features/pluto/controllers/pluto_controller.dart';
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

  bool get inFilterMode => dateRange != null;

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

  Future<void> onSubmitDateRangePicker(PickerDateRange pickedDateRange) async {
    isLoading = true;
    update();

    dateRange = pickedDateRange;
    await fetchSellerBillsByDate(
      sellerModel: selectedSeller!,
      dateTimeRange: DateTimeRange(start: pickedDateRange.startDate!, end: pickedDateRange.endDate!),
    );

    isLoading = false;
    update();
  }

  void clearFilter() {
    dateRange = null;
    read<PlutoController>().updatePlutoKey();

    update();
  }

  // Sets the selected seller and fetches their bills
  Future<void> onSelectSeller(SellerModel sellerModel) async {
    setSelectedSeller = sellerModel;
    await fetchSellerBillsByDate(sellerModel: sellerModel);
    navigateToSellerSalesScreen();
  }

  Future<void> fetchSellerBillsByDate({required SellerModel sellerModel, DateTimeRange? dateTimeRange}) async {
    final currentDate = DateTime.now();
    final startOfDay = currentDate.subtract(Duration(days: 30));
    final endOfDay = currentDate;

    final result = await _billsFirebaseRepo.fetchWhere(
      itemTypeModel: BillType.sales.billTypeModel,
      field: ApiConstants.billSellerId,
      value: sellerModel.costGuid,
      dateFilter: DateFilter(dateFieldName: ApiConstants.billDate, range: dateTimeRange ?? DateTimeRange(start: startOfDay, end: endOfDay)),
    );
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (bills) => _handleGetSellerBillsStatusSuccess(bills),
    );
  }

  _handleGetSellerBillsStatusSuccess(List<BillModel> bills) {
    if (inFilterMode) {
      filteredBills.assignAll(bills);
    } else {
      sellerBills.assignAll(bills);
    }
  }

  // Method to calculate the total sales
  double calculateTotalSales(List<BillModel> bills) => bills.fold(0.0, (sum, bill) => sum + (bill.billDetails.billTotal ?? 0));

  void calculateTotalAccessoriesMobiles() {
    // Reset totals
    totalAccessoriesSales = 0;
    totalMobilesSales = 0;

    // Iterate through all bills
    for (final bill in sellerBills) {
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

  void navigateToAllSellersScreen() => to(AppRoutes.allSellersScreen);

  void navigateToSellerSalesScreen() => to(AppRoutes.sellerSalesScreen);

  void navigateToSellerTargetScreen() => to(AppRoutes.sellerTargetScreen);
}
