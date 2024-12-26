import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/styling/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_spacer.dart';
import '../../../../core/widgets/organized_widget.dart';
import '../../controllers/pattern_controller.dart';
import '../widgets/pattern_layout/pattern_type_item_widget.dart';

class PatternLayout extends StatelessWidget {
  const PatternLayout({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: OrganizedWidget(
            // titleWidget: Align(
            //   child: Text(
            //     'انماط الفواتير',
            //     style: AppTextStyles.headLineStyle2.copyWith(color: AppColors.blueColor),
            //   ),
            // ),
            bodyWidget: GetBuilder<PatternController>(
                builder: (patternController) => SizedBox(
                      width: 1.sw,
                      child: Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              ...patternController.billsTypes.map((billTypeModel) => PatternTypeItemWidget(
                                    billTypeModel: billTypeModel,
                                    color: Color(billTypeModel.color!),
                                    onTap: () {
                                      patternController.navigateToAddPatternScreen(billTypeModel);
                                    },
                                  )),
                            ],
                          ),
                          VerticalSpace(),
                          Center(
                            child: AppButton(
                              title: 'إضافة نمط',
                              fontSize: 13.sp,
                              color: AppColors.grayColor,
                              onPressed: () {
                                patternController.navigateToAddPatternScreen();
                              },
                              iconData: Icons.view_list_outlined,
                              width: max(45.w, 140),
                              // width: 40.w,
                            ),
                          ),
                        ],
                      ),
                    )),
          ),
        ),
      );
}
