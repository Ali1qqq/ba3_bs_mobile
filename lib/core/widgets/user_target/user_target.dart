import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../features/sellers/controllers/seller_sales_controller.dart';
import '../../constants/app_strings.dart';
import 'target_pointer_widget.dart';

class UserTargets extends StatelessWidget {
  const UserTargets({
    super.key,
    required this.salesController,
    this.height,
  });

  final SellerSalesController salesController;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 25,
        children: [
          Column(
            spacing: 10,
            children: [
              Text(
                AppStrings.mobileTarget.tr,
                style: TextStyle(fontSize: 22),
              ),
              Container(
                  color: Colors.red,
                  width: 1.sw,
                  height: height ?? 400,
                  child: TargetPointerWidget(
                    maxValue: 350000,
                    midValue: 250000,
                    minValue: 150000,
                    value: salesController.totalMobilesSales,
                  )),
            ],
          ),
          Column(
            spacing: 10,
            children: [
              Text(
                AppStrings.accessoriesTarget.tr,
                style: TextStyle(fontSize: 22),
              ),
              SizedBox(
                  width: 1.sw,
                  height: height ?? 400,
                  child: TargetPointerWidget(
                    maxValue: 200000,
                    midValue: 150000,
                    minValue: 75000,
                    value: salesController.totalAccessoriesSales,
                  )),
              if (salesController.loggedInUserModel!.hasGroupTarget)
                Column(
                  spacing: 10,
                  children: [
                    Text(
                      AppStrings.groupForTarget.tr,
                      style: TextStyle(fontSize: 22),
                    ),
                    SizedBox(
                        width: 1.sw,
                        height: height ?? 400,
                        child: TargetPointerWidget(
                          maxValue: 60000,
                          midValue: 45000,
                          minValue: 30000,
                          value: salesController.totalGroupSales,
                        )),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}