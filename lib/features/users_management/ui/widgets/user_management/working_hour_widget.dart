import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../data/models/user_model.dart';

class WorkingHoursItem extends StatelessWidget {
  const WorkingHoursItem({super.key, required this.userWorkingHours, required this.onEnterTimeChange, required this.onOutTimeChange, required this.onDelete});

  final UserWorkingHours userWorkingHours;
  final void Function(Time) onEnterTimeChange;
  final void Function(Time) onOutTimeChange;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Text(
              'توقيت الدخول',
              style: AppTextStyles.headLineStyle3,
            ),
            HorizontalSpace(),
            InkWell(
              onTap: () async {
                Navigator.of(context).push(
                  showPicker(

                    context: context,
                    value: Time(hour: 4, minute: 30),
                    sunrise: TimeOfDay(hour: 6, minute: 0),
                    sunset: TimeOfDay(hour: 18, minute: 0),
                    duskSpanInMinutes: 120,
                    onChange: onEnterTimeChange,
                  ),
                );
              },
              child: Container(
                height: 30,
                width: 100,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey, width: 2)),
                child: Center(
                  child: Text(
                    userWorkingHours.enterTime ?? '',
                    style: AppTextStyles.headLineStyle3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              'توقيت الخروج',
              style: AppTextStyles.headLineStyle3,
            ),
            HorizontalSpace(),
            InkWell(
              onTap: () async {
                Navigator.of(context).push(
                  showPicker(
                    context: context,
                    value: Time(hour: 4, minute: 30),
                    sunrise: TimeOfDay(hour: 6, minute: 0),
                    sunset: TimeOfDay(hour: 18, minute: 0),
                    duskSpanInMinutes: 120,
                    onChange: onOutTimeChange,
                  ),
                );
              },
              child: Container(
                height: 30,
                width: 100,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all(color: Colors.grey, width: 2)),
                child: Center(
                  child: Text(
                    userWorkingHours.outTime ?? '',
                    style: AppTextStyles.headLineStyle3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),

        IconButton(onPressed: onDelete, icon: Icon(Icons.delete))
      ],
    );
  }
}