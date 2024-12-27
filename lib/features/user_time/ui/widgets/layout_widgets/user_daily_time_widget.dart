import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/organized_widget.dart';

class UserDailyTimeWidget extends StatelessWidget {
  const UserDailyTimeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
          titleWidget: Center(
              child: Text(
            'اوقات العمل',
            style: AppTextStyles.headLineStyle2,
          )),
          bodyWidget: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: 1,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: 0.3.sw,
                        child: Text(
                          "12:00 AM",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headLineStyle4,
                        )),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.grayColor,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.grayColor,
                          )
                          // Text(">"),
                        ],
                      ),
                    ),
                    SizedBox(
                        width: 0.3.sw,
                        child: Text(
                          "08:00 AM",
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headLineStyle4,
                        )),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
