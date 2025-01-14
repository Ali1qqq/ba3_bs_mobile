import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/sellers_controller.dart';

class AllSellersScreen extends StatelessWidget {
  const AllSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('جميع البائعون')),
        body: GetBuilder<SellersController>(builder: (controller) {
          if (controller.isLoading) {
            return AppUIUtils.showLoadingIndicator();
          } else {
            if (controller.allSellers.isEmpty) {
              return const Center(child: Text('لا يوجد بائعون بعد'));
            } else {
              return SingleChildScrollView(
                child: SizedBox(
                  width: 0.9.sw,
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: List.generate(
                        controller.allSellers.length,
                        (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () => read<SellerSalesController>().onSelectSeller(
                                  controller.allSellers[index],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: Colors.grey.withAlpha(127), borderRadius: BorderRadius.circular(10)),
                                  height: 140,
                                  width: 140,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        controller.allSellers[index].costCode?.toString() ?? '',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      Text(
                                        controller.allSellers[index].costName ?? '',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                  ),
                ),
              );
            }
          }
        }),
      ),
    );
  }
}
