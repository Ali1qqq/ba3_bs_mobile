import 'package:ba3_bs_mobile/features/users_management/controllers/user_details_controller.dart';
import 'package:flutter/material.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/utils/app_service_utils.dart';
import '../../../../../core/widgets/organized_widget.dart';

class AllHolidaysWidget extends StatelessWidget {
  const AllHolidaysWidget({
    super.key,
    required this.userDetailsController,
  });

  final UserDetailsController userDetailsController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
          titleWidget: Center(
              child: Text(
            'ايام العطل',
            style: AppTextStyles.headLineStyle2,
          )),
          bodyWidget: Column(
            children: [
              ListView.separated(
                separatorBuilder: (context, index) => Divider(),
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: userDetailsController.userFormHandler.userHolidaysLength,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userDetailsController.userFormHandler.userHolidays.elementAt(index),
                      style: AppTextStyles.headLineStyle3,
                    ),
                    Text(
                      AppServiceUtils.getDayNameAndMonthName(userDetailsController.userFormHandler.userHolidays.elementAt(index)),
                      style: AppTextStyles.headLineStyle3,
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
