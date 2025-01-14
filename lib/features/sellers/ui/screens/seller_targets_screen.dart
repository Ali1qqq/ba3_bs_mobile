import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/target_pointer_widget.dart';

class SellerTargetScreen extends StatelessWidget {
  const SellerTargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SellerSalesController salesController = Get.find<SellerSalesController>();
    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                actions: const [],
                title: const Text(
                  'لوحة الانجازات',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              body: ListView(
                children: [
                  Column(
                    children: [
                      const Text(
                        'تارغيت الجوالات ',
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: 500,
                          child: TargetPointerWidget(
                            key: salesController.mobilesKey,
                            value: salesController.totalMobilesSales,
                          )),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'تارغيت الاكسسوارات ',
                        style: TextStyle(fontSize: 22),
                      ),
                      SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: 500,
                          child: TargetPointerWidget(
                            key: salesController.accessoriesKey,
                            value: salesController.totalAccessoriesSales,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
