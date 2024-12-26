
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/core/widgets/organized_widget.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/bill_layout/bill_type_item_widget.dart';

class BillLayout extends StatelessWidget {
  const BillLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child:  Container(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: OrganizedWidget(
                titleWidget: Align(
                  child: Text(
                    'الفواتير',
                    style: AppTextStyles.headLineStyle2.copyWith(color: AppColors.blueColor),
                  ),
                ),
                bodyWidget: GetBuilder<AllBillsController>(
                    builder: (controller) => Column(
                          spacing: 10,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: controller.billsTypes.map((billTypeModel) => BillTypeItemWidget(
                                      text: billTypeModel.fullName!,
                                      color: Color(billTypeModel.color!),
                                      onTap: () {
                                        controller
                                          ..fetchAllBills()
                                          ..openFloatingBillDetails(context, billTypeModel);
                                      },
                                    )).toList(),

                            ),
                            VerticalSpace(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AppButton(
                                  title: 'عرض جميع الفواتير',
                                  fontSize: 13.sp,
                                  color: AppColors.grayColor,
                                  onPressed: () {
                                    read<AllBillsController>()
                                      ..fetchAllBills()
                                      ..navigateToAllBillsScreen();
                                  },
                                  iconData: Icons.view_list_outlined,
                                  width: 150.w,
                                  // width: 40.w,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0.r),
                                  child: AppButton(
                                    title: 'عرض الفواتير المعلقة',
                                    fontSize: 13.sp,

                                    color: AppColors.grayColor,
                                    onPressed: () {
                                      read<AllBillsController>()
                                        ..fetchPendingBills()
                                        ..navigateToPendingBillsScreen();
                                    },
                                    iconData: Icons.view_list_outlined,
                                    width: 170.w,
                                    // width: 40.w,
                                  ),
                                )
                              ],
                            ),
                          ],
                        )),
              ),
            ),
          ),
    );
  }
}
