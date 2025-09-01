import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';
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
    final now = DateTime.now();
    final isBefore29 = now.day < 29;
    final mobilesTargetShow = !(salesController.totalMobilesSales > 150000 && isBefore29) || RoleItemType.administrator.hasAdminPermission;
    final accessoriesTargetShow =
        !(salesController.totalAccessoriesSales > 75000 && isBefore29) || RoleItemType.administrator.hasAdminPermission;
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
              if (mobilesTargetShow)
                Container(
                  color: Colors.red,
                  width: 1.sw,
                  height: height ?? 400,
                  child: TargetPointerWidget(
                    maxValue: 350000,
                    midValue: 250000,
                    minValue: 150000,
                    value: salesController.totalMobilesSales,
                  ),
                )
              else
                TargetDisabeld(height: height),
            ],
          ),
          Column(
            spacing: 10,
            children: [
              Text(
                AppStrings.accessoriesTarget.tr,
                style: TextStyle(fontSize: 22),
              ),
              if (accessoriesTargetShow)
                SizedBox(
                    width: 1.sw,
                    height: height ?? 400,
                    child: TargetPointerWidget(
                      maxValue: 200000,
                      midValue: 150000,
                      minValue: 75000,
                      value: salesController.totalAccessoriesSales,
                    ))
              else
                TargetDisabeld(height: height),
              /*       if (salesController.loggedInUserModel!.hasGroupTarget)
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
                ),*/
            ],
          ),
        ],
      ),
    );
  }
}

class TargetDisabeld extends StatelessWidget {
  const TargetDisabeld({
    super.key,
    required this.height,
  });

  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.sw,
      height: height ?? 400,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_clock, size: 60, color: Colors.blue.shade600),
          const SizedBox(height: 12),
          Text(
            "سيظهر المؤشر بتاريخ 29 من هذا الشهر",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}