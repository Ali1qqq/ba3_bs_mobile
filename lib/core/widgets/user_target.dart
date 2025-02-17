import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../features/sellers/controllers/seller_sales_controller.dart';
import '../../features/sellers/ui/widgets/target_pointer_widget.dart';
import '../constants/app_strings.dart';

class UserTargets extends StatelessWidget {
  const UserTargets({
    super.key,
    required this.salesController,
  });

  final SellerSalesController salesController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            AppStrings.mobileTarget.tr,
            style: TextStyle(fontSize: 22),
          ),
          SizedBox(
              width: 1.sw,
              height: 400,
              child: TargetPointerWidget(
                maxValue: 350000,
                midValue: 250000,
                minValue: 150000,
                key: salesController.mobilesKey,
                value: salesController.totalMobilesSales,
              )),
          Column(
            children: [
              Text(
                AppStrings.accessoriesTarget.tr,
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(
                  width: 1.sw,
                  height: 400,
                  child: TargetPointerWidget(
                    maxValue: 200000,
                    midValue: 150000,
                    minValue: 75000,
                    key: salesController.accessoriesKey,
                    value: salesController.totalAccessoriesSales,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}