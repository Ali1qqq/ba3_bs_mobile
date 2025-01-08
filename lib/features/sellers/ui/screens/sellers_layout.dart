import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_menu_item.dart';

class SellersLayout extends StatelessWidget {
  const SellersLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final SellerSalesController sellerSalesController = read<SellerSalesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('البائعون')),
      body: Column(
        children: [
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
