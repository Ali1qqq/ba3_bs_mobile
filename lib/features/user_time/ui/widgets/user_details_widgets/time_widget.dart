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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
        titleWidget: Center(
          child: Text(
            "سجل الحضور",
            style: AppTextStyles.headLineStyle2,
          ),
        ),
        bodyWidget: ListView.separated(
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: userDetailsController.selectedUserModel?.userTimeModel?.values.length ?? 0,
          separatorBuilder: (context, index) => VerticalSpace(),
          itemBuilder: (context, index) {
            final userTimeModel = userDetailsController.selectedUserModel?.userTimeModel?.values.toList()[index];

            return Column(
              children: [
                _buildDayHeader(userTimeModel?.dayName ?? ''),
                VerticalSpace(),
                _buildLogTimes(userTimeModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDayHeader(String dayName) {
    return Container(
      decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Colors.red))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Text("اليوم :", style: AppTextStyles.headLineStyle2),
          Text(dayName, style: AppTextStyles.headLineStyle2),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildLogTimes(UserTimeModel? userTimeModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLogList("دخول :", userTimeModel?.logInDateList),
        _buildLogList("خروج :", userTimeModel?.logOutDateList),
      ],
    );
  }

  Widget _buildLogList(String label, List<DateTime>? logList) {
    return SizedBox(
      width: 0.45.sw,
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
