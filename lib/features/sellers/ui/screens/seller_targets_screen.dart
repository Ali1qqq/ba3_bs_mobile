import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/widgets/user_target/user_target.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerTargetScreen extends StatelessWidget {
  const SellerTargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SellerSalesController salesController = Get.find<SellerSalesController>();
    return Column(
      children: [
        Expanded(
          child: Scaffold(
            appBar: AppBar(
              actions: const [],
              title: Text(
                AppStrings.achievementsPanel.tr,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            body: UserTargets(salesController: salesController),
          ),
        ),
      ],
    );
  }
}