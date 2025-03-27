import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            DateRangePicker(
              onSubmit: controller.onSubmitDateRangePicker,
              pickedDateRange: controller.dateRange,
              onSelectionChanged: controller.onSelectionChanged,
            ),
            Spacer(),
            GestureDetector(
              onTap:()=>controller.openAllSellersSales(context) ,
              child: Text(
                AppStrings.sellers,
                style: AppTextStyles.headLineStyle1,
              ),
            ),
            Spacer(),
            IconButton(
              tooltip: AppStrings.swap.tr,
              icon: Icon(
                controller.crossSellerFadeState == CrossFadeState.showFirst?   FontAwesomeIcons.chartPie: FontAwesomeIcons.chartSimple,
                color: AppColors.lightBlueColor,
              ),
              onPressed: controller.swapSellerCrossFadeState,
            ),
            IconButton(
              tooltip: AppStrings.refresh.tr,
              icon: Icon(
                FontAwesomeIcons.refresh,
                color: AppColors.lightBlueColor,
              ),
              onPressed: controller.getSellersBillsByDate,
            ),
          ],
        ),
      ),
    );
  }
}