import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_details_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/organized_widget.dart';

class TimeWidget extends StatelessWidget {
  const TimeWidget({
    super.key,
    required this.userDetailsController,
  });

  final UserDetailsController userDetailsController;

  @override
  Widget build(BuildContext context) {
    return OrganizedWidget(
      titleWidget: Center(
        child: Text(
          AppStrings.attendanceRecord,
          style: AppTextStyles.headLineStyle2,
        ),
      ),
      bodyWidget: ListView.separated(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: userDetailsController.userFormHandler.userTimeAtMonthLength,
        separatorBuilder: (context, index) => VerticalSpace(),
        itemBuilder: (context, index) {
          final userTimeModel = userDetailsController.userFormHandler.userTimeModelAtMonth.values.toList()[index];

          return Column(
            children: [
              _buildDayHeader(userTimeModel.dayName ?? ''),
              VerticalSpace(),
              _buildLogTimes(userTimeModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayHeader(String dayName) {
    return Container(
      width: 1.sw,
      decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: AppColors.grayColor))),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("اليوم :", style: AppTextStyles.headLineStyle2),
              Text(dayName, style: AppTextStyles.headLineStyle2),
            ],
          ),
          Container(
            decoration: BoxDecoration(border: Border.symmetric(vertical: BorderSide(color: Colors.red))),
            padding: EdgeInsets.all(8),
            child: Wrap(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("التأخير :", style: AppTextStyles.headLineStyle4.copyWith(color: Colors.red)),
                    Text(userDetailsController.userDelay(dayName), style: AppTextStyles.headLineStyle4),
                  ],
                ),
                // VerticalSpace(),
                VerticalDivider(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("الخروج المبكر :", style: AppTextStyles.headLineStyle4.copyWith(color: Colors.red)),
                    Text(userDetailsController.userEarlier(dayName), style: AppTextStyles.headLineStyle4),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLogTimes(UserTimeModel? userTimeModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogList("دخول :", userTimeModel?.logInDateList),
        Container(
          color: AppColors.grayColor,
          width: 1,
          height: 50,
        ),
        _buildLogList("خروج :", userTimeModel?.logOutDateList),
      ],
    );
  }

  Widget _buildLogList(String label, List<DateTime>? logList) {
    return SizedBox(
      width: 0.3.sw,
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: logList?.length ?? 0,
        separatorBuilder: (context, index) => VerticalSpace(),
        itemBuilder: (context, index) {
          final logTime = logList?.elementAt(index);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              Text(AppServiceUtils.extractTimeFromDateTime(logTime)),
            ],
          );
        },
      ),
    );
  }
}