import 'dart:developer';

import 'package:ba3_bs_mobile/core/widgets/custom_text_field_without_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../features/floating_window/services/overlay_service.dart';
import '../constants/app_constants.dart';

class DatePicker extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  final String? initDate;
  final Color? color;

  const DatePicker({super.key, required this.onDateSelected, this.initDate, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.constHeightTextField,
      child: GestureDetector(
        onTap: () {
          OverlayService.showDialog(
            context: context,
            height: .6.sh,
            width: .5.sw,
            title: 'أختر يوم',
            content: Column(
              children: [
                Expanded(
                  child: SfDateRangePicker(
                    initialDisplayDate: DateTime.tryParse(initDate ?? ""),
                    enableMultiView: true,
                    backgroundColor: Colors.transparent,
                    headerStyle: const DateRangePickerHeaderStyle(backgroundColor: Colors.transparent),
                    navigationDirection: DateRangePickerNavigationDirection.vertical,
                    selectionMode: DateRangePickerSelectionMode.single,
                    monthViewSettings: const DateRangePickerMonthViewSettings(enableSwipeSelection: false),
                    showNavigationArrow: true,
                    navigationMode: DateRangePickerNavigationMode.scroll,
                    onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                      DateTime selectedDate = dateRangePickerSelectionChangedArgs.value as DateTime;
                      onDateSelected(selectedDate);
                      OverlayService.back();
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    OverlayService.back();
                  },
                  child: const Text("إلغاء"),
                ),
              ],
            ),
            onCloseCallback: () {
              log('DatePicker Dialog Closed.');
            },
          );
        },
        child: CustomTextFieldWithoutIcon(
          enabled: false,
          filedColor: color,
          textEditingController: TextEditingController()..text = initDate ?? '',
        ),
      ),
    );
  }
}