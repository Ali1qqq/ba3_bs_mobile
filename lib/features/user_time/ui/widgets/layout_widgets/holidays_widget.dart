import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/utils/app_service_utils.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/organized_widget.dart';
import '../../../controller/user_time_controller.dart';

class HolidaysWidget extends StatelessWidget {
  const HolidaysWidget({
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
            'ايام العطل لهذا الشهر',
            style: AppTextStyles.headLineStyle2,
          )),
          bodyWidget: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                itemCount: userTimeController.userHolidaysLength,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        userTimeController.userHolidays!.elementAt(index),
                        style: AppTextStyles.headLineStyle3,
                      ),
                      HorizontalSpace(),
                      Text(
                        userTimeController.userHolidaysWithDay!.elementAt(index),
                        style: AppTextStyles.headLineStyle3,
                      ),
                    ],
                  );
                },
              ),
            ],
          )),
    );
  }
}

final List<String> holidays = List.generate(
  2,
  (index) => "2024-${(index + 1).toString().padLeft(2, "0")}-${(Random().nextInt(30) + 1).toString().padLeft(2, "0")}",
);
final List<String> holidaysName = holidays
    .map(
      (e) => AppServiceUtils.getDayNameAndMonthName(e),
    )
    .toList();
