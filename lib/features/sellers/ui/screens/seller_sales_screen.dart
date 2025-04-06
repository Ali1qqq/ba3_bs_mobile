import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../../../core/widgets/user_target/user_target.dart';
import '../../../bill/controllers/bill/all_bills_controller.dart';
import '../widgets/date_range_picker.dart';

class SellerSalesScreen extends StatelessWidget {
  const SellerSalesScreen({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<SellerSalesController>(
        builder: (controller) => PlutoGridWithAppBar(
          // title: '${AppStrings.bills.tr} ${controller.selectedSeller!.costName}',
          appBar: _buildAppBar(context, controller),
          onLoaded: (e) {},
          rightChild: SizedBox(width: 0.23.sw, child: UserTargets(salesController: controller)),
          onSelected: (event) {
            final billId = event.row?.cells[AppConstants.billIdFiled]?.value;
            // print( (billTypeName as Map<String,dynamic>));

            if (billId != null) {
              read<AllBillsController>()
                  .openFloatingBillDetailsById(billId: billId, context: context, bilTypeModel: BillType.sales.billTypeModel);
            }
          },
          isLoading: controller.isLoading,
          tableSourceModels: controller.sellerSales,
          bottomChild: _buildSummary(controller),
        ),
      );

  /// Builds the app bar with title, leading and action widgets.
  AppBar _buildAppBar(BuildContext context, SellerSalesController controller) {
    return AppBar(
      leadingWidth: 400,
      leading: _buildLeadingSection(controller, context),
      // title: Text('${AppStrings.salesRecord.tr} ${controller.selectedSeller?.costName}'),
      centerTitle: true,
      // actions: _buildActionButtons(controller),
    );
  }

  /// Creates the leading section containing back button and date range picker.
  Widget _buildLeadingSection(SellerSalesController controller, BuildContext context) {
    return Row(
      children: [
        const HorizontalSpace(20),
        DateRangePicker(
          onSubmit: () {
            controller.onSubmitDateRangePicker();
          },
          pickedDateRange: controller.dateRange,
          onSelectionChanged: controller.onSelectionChanged,
        ),
        const HorizontalSpace(20),
        IconButton(
          onPressed: controller.inFilterMode ? controller.clearFilter : null,
          icon: Icon(
            controller.inFilterMode ? Icons.filter_alt : Icons.filter_alt_off_outlined,
            color: Colors.blue.shade700,
          ),
          tooltip: '${AppStrings.empty.tr} ${AppStrings.filter.tr}',
        ),
      ],
    );
  }

  /// Generates action buttons in the app bar.
/*  List<Widget> _buildActionButtons(SellerSalesController controller) {
    return [
      const HorizontalSpace(10),
      AppButton(
        title: AppStrings.target.tr,
        width: 80,
        borderRadius: BorderRadius.circular(25),
        onPressed: () {
          controller
            ..calculateTotalAccessoriesMobiles()
            ..navigateToSellerTargetScreen();
        },
      ),
      const HorizontalSpace(20),
    ];
  }*/

  /// Builds the sales summary section showing the total sales.
  Widget _buildSummary(SellerSalesController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${AppStrings.total.tr} :',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 24),
              ),
              const HorizontalSpace(10),
              Text(
                AppUIUtils.formatDecimalNumberWithCommas(controller.totalSales),
                style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}