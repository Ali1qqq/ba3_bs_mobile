import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../sellers/ui/widgets/date_range_picker.dart';
import '../../../controller/seller_dashboard_controller.dart';

class SellerDateFilterHeader extends StatelessWidget {
  final SellerDashboardController controller;

  const SellerDateFilterHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                GestureDetector(
                  onTap: () => controller.openAllSellersSales(context),
                  child: Text(
                    AppStrings.sellers,
                    style: AppTextStyles.headLineStyle1,
                  ),
                ),
                Spacer(),
                InkWell(
                  // tooltip: AppStrings.swap.tr,
                  onTap: controller.swapSellerCrossFadeState,
                  // tooltip: AppStrings.swap.tr,
                  child: Icon(
                    size: 16,
                    controller.crossSellerFadeState == CrossFadeState.showFirst ? FontAwesomeIcons.chartPie : FontAwesomeIcons.chartSimple,
                    color: AppColors.lightBlueColor,
                  ),
                ),
                HorizontalSpace(),
                InkWell(
                  onTap: controller.getSellersBillsByDate,
                  child: Icon(
                    FontAwesomeIcons.arrowsRotate,
                    color: AppColors.lightBlueColor,
                    size: 16,
                  ),
                ),
              ],
            ),
            VerticalSpace(),
            DateRangePicker(
              onSubmit: controller.onSubmitDateRangePicker,
              pickedDateRange: controller.dateRange,
              onSelectionChanged: controller.onSelectionChanged,
            ),
          ],
        ),
      ),
    );
  }
}