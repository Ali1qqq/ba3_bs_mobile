import 'package:ba3_bs_mobile/core/helper/extensions/basic/date_time_extensions.dart';
import 'package:flutter/material.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/organized_widget.dart';
import '../../../controller/user_time_controller.dart';

class JetourDaysWidget extends StatelessWidget {
  const JetourDaysWidget({
    super.key,
    required this.userTimeController,
  });

  final UserTimeController userTimeController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
          titleWidget: Center(
              child: Text(
            'الدوام ضمن محل الجيتور',
            style: AppTextStyles.headLineStyle2,
          )),
          bodyWidget: ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: userTimeController.userJetourLength,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: userTimeController.userJetourDays!.elementAt(index) == DateTime.now().dayMonthYear
                      ? Colors.red.shade300
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      userTimeController.userJetourDays!.elementAt(index),
                      style: AppTextStyles.headLineStyle3,
                    ),
                    HorizontalSpace(),
                    Text(
                      userTimeController.userJetourWorkWithDay!.elementAt(index),
                      style: AppTextStyles.headLineStyle3,
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }
}