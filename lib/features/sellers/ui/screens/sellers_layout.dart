import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_menu_item.dart';
import '../../../users_management/data/models/role_model.dart';

class SellersLayout extends StatelessWidget {
  const SellersLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final SellerSalesController sellerSalesController = read<SellerSalesController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.sellers.tr),
        actions: [
          if (RoleItemType.administrator.hasReadPermission)
            Padding(
              padding: EdgeInsets.all(5),
              child: AppButton(title: AppStrings.downloadSellers.tr, onPressed: () => read<SellersController>().fetchAllSellersFromLocal()),
            )
        ],
      ),
      body: Column(
        children: [
          AppMenuItem(
              text: AppStrings.addSellers.tr,
              onTap: () {
                sellerSalesController.navigateToAddSellerScreen(context: context);
              }),
          AppMenuItem(
              text: AppStrings.viewSellers.tr,
              onTap: () {
                sellerSalesController.navigateToAllSellersScreen(context);
              }),
        ],
      ),
    );
  }
}