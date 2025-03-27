import 'package:ba3_bs_mobile/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CustomDatePickerDialog extends StatelessWidget {
  const CustomDatePickerDialog({super.key, this.onTimeSelect, required this.onClose});

  final Function(DateRangePickerSelectionChangedArgs)? onTimeSelect;

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0.4.sh,
      width: 0.4.sw,
      child: Column(
        children: [
          Expanded(
            child: SfDateRangePicker(
                initialDisplayDate: DateTime.now(),
                enableMultiView: false,
                backgroundColor: Colors.transparent,
                headerStyle: const DateRangePickerHeaderStyle(backgroundColor: Colors.transparent),
                navigationDirection: DateRangePickerNavigationDirection.vertical,
                selectionMode: DateRangePickerSelectionMode.multiple,
                monthViewSettings: const DateRangePickerMonthViewSettings(enableSwipeSelection: false),
                showNavigationArrow: true,
                navigationMode: DateRangePickerNavigationMode.scroll,
                onSelectionChanged: onTimeSelect),
          ),
          AppButton(title: 'تم', onPressed: onClose)
        ],
      ),
    );
  }
}