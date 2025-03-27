import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:ba3_bs_mobile/core/widgets/custom_text_field_without_icon.dart';

import '../constants/app_constants.dart';

class MonthYearPicker extends StatelessWidget {
  final Function(DateTime) onMonthYearSelected;
  final String? initMonthYear;
  final Color? color;
  final Color? textColor;

  const MonthYearPicker({super.key, required this.onMonthYearSelected, this.initMonthYear, this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.constHeightTextField,
      child: GestureDetector(
        onTap: () {
          DatePicker.showPicker(
            context,
            showTitleActions: true,
            pickerModel: CustomMonthYearPicker(
              currentTime: DateTime.tryParse(initMonthYear ?? "") ?? DateTime.now(),
            ),
            locale: LocaleType.ar,
            onConfirm: (date) {
              onMonthYearSelected(date);
            },
          );
        },
        child: CustomTextFieldWithoutIcon(
          enabled: false,
          filedColor: color,
          textStyle: AppTextStyles.headLineStyle4.copyWith(color: textColor),
          textEditingController: TextEditingController()..text = '${initMonthYear!.split("-")[1]} / ${initMonthYear!.split("-")[0]}',
        ),
      ),
    );
  }
}

/// **كلاس مخصص لجعل منتقي التاريخ يعرض فقط الشهر والسنة**
class CustomMonthYearPicker extends DatePickerModel {
  CustomMonthYearPicker({DateTime? currentTime, super.locale}) : super(currentTime: currentTime ?? DateTime.now());

  @override
  List<int> layoutProportions() {
    return [1, 1, 0]; // يجعل العرض يركز على الشهر والسنة فقط
  }
}