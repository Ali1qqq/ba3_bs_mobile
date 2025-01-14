import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_menu_item.dart';
import '../../../users_management/data/models/role_model.dart';

class SellersLayout extends StatelessWidget {
  const SellersLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final SellerSalesController sellerSalesController = read<SellerSalesController>();
    return Scaffold(
      body: Column(
        children: [
          if (RoleItemType.viewSellers.hasAdminPermission)
            AppMenuItem(
                text: 'إضافة بائع',
                onTap: () {
                  sellerSalesController.navigateToAddSellerScreen();
                }),
          AppMenuItem(
              text: 'معاينة البائعون',
              onTap: () {
                sellerSalesController.navigateToAllSellersScreen();
              }),
        ],
      ),
    );
  }
}
