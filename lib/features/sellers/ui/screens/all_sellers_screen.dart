import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../controllers/sellers_controller.dart';

class AllSellersScreen extends StatelessWidget {
  const AllSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = read<SellersController>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(AppStrings.allSellers.tr)),
        body: Obx(() {
          if (controller.sellers.isEmpty) {
            return Center(child: Text(AppStrings.thereAreNoSellersYet.tr));
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 1.sw,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(
                      controller.sellers.length,
                      (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () => read<SellerSalesController>().navigateToSellerSalesScreen(controller.sellers[index], context),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                                height: 100.h,
                                width: 40.w,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.sellers[index].costCode?.toString() ?? '',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        controller.sellers[index].costName ?? '',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () async {
                                            if (await AppUIUtils.confirm(context)) {
                                              controller.deleteSeller(controller.sellers[index].costGuid!);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.solidPenToSquare,
                                            size: 18,
                                          ),
                                          color: AppColors.lightBlueColor,
                                          onPressed: () {
                                            read<SellerSalesController>()
                                                .navigateToAddSellerScreen(seller: controller.sellers[index], context: context);
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )),
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}