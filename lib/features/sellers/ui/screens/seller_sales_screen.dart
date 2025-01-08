import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../../bill/controllers/bill/all_bills_controller.dart';
import '../widgets/date_range_picker.dart';

class SellerSalesScreen extends StatelessWidget {
  const SellerSalesScreen({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<SellerSalesController>(
        builder: (controller) => PlutoGridWithAppBar(
          title: 'فواتير ${controller.selectedSeller!.costName}',
          appBar: _buildAppBar(context, controller),
          onLoaded: (e) {},
          onSelected: (event) {
            final billId = event.row?.cells['billId']?.value;

            // print( (billTypeName as Map<String,dynamic>));

            if (billId != null) {
              read<AllBillsController>().openFloatingBillDetailsById(billId, context, BillType.sales.billTypeModel);
            }
          },
          isLoading: controller.isLoading,
          tableSourceModels: controller.sellerSales,
          child: _buildSummary(controller),
        ),
      );

  /// Builds the app bar with title, leading and action widgets.
  AppBar _buildAppBar(BuildContext context, SellerSalesController controller) {
    return AppBar(
      leadingWidth: 400,
      leading: _buildLeadingSection(controller),
      title: Text('سجل مبيعات ${controller.selectedSeller?.costName}'),
      centerTitle: true,
      actions: _buildActionButtons(),
    );
  }

  /// Creates the leading section containing back button and date range picker.
  Widget _buildLeadingSection(SellerSalesController controller) {
    return Row(
      children: [
        const BackButton(),
        const HorizontalSpace(20),
        DateRangePicker(onSubmit: controller.onSubmitDateRangePicker),
        const HorizontalSpace(20),
        IconButton(
          onPressed: controller.inFilterMode ? controller.clearFilter : null,
          icon: Icon(
            controller.inFilterMode ? Icons.filter_alt : Icons.filter_alt_off_outlined,
            color: Colors.blue.shade700,
          ),
          tooltip: 'افراغ الفلتر',
        ),
      ],
    );
  }

  /// Generates action buttons in the app bar.
  List<Widget> _buildActionButtons() {
    return [
      AppButton(
        title: 'تعديل',
        borderRadius: BorderRadius.circular(25),
        onPressed: () {
          // TODO: Add navigation logic for editing
        },
      ),
      const HorizontalSpace(20),
      AppButton(
        title: 'التارغيت',
        borderRadius: BorderRadius.circular(25),
        onPressed: () {
          // TODO: Add navigation logic for target page
        },
      ),
      const HorizontalSpace(20),
    ];
  }

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
              const Text(
                'المجموع :',
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
