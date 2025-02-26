import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/organized_widget.dart';

class AllHolidaysWidget extends StatelessWidget {
  const AllHolidaysWidget({
    super.key,
    required this.userDetailsController,
  });

  final UserDetailsController userDetailsController;

  @override
  Widget build(BuildContext context) {
    return OrganizedWidget(
        titleWidget: Center(
            child: Text(
          AppStrings.holidays.tr,
          style: AppTextStyles.headLineStyle2,
        )),
        bodyWidget: Column(
          children: [
            ListView.separated(
              separatorBuilder: (context, index) => Divider(),
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: userDetailsController.userFormHandler.userHolidaysLengthAtMonth,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userDetailsController.userFormHandler.userHolidaysAtMoth.elementAt(index),
                    style: AppTextStyles.headLineStyle3,
                  ),
                  Text(
                    userDetailsController.userFormHandler.userHolidaysWithDayAtMoth!.elementAt(index),
                    style: AppTextStyles.headLineStyle3,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}