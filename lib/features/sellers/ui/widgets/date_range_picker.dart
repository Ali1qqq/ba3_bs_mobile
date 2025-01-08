import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateRangePicker extends StatefulWidget {
  final Function(PickerDateRange) onSubmit;
  final String? initDate;

  const DateRangePicker({super.key, required this.onSubmit, this.initDate});

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  PickerDateRange? pickedDateRange;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all()),
      width: 250,
      height: 40,
      child: InkWell(
          onTap: () {
            Get.defaultDialog(
                title: 'اختر فترة زمنية',
                content: SizedBox(
                  height: MediaQuery.sizeOf(context).height / 1.6,
                  width: MediaQuery.sizeOf(context).height / 1,
                  child: SfDateRangePicker(
                    initialDisplayDate: DateTime.tryParse(widget.initDate ?? ""),
                    enableMultiView: true,
                    backgroundColor: Colors.transparent,
                    headerStyle: const DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent,
                    ),
                    navigationDirection: DateRangePickerNavigationDirection.vertical,
                    selectionMode: DateRangePickerSelectionMode.range,
                    monthViewSettings: const DateRangePickerMonthViewSettings(
                        enableSwipeSelection: false,
                        viewHeaderStyle: DateRangePickerViewHeaderStyle(backgroundColor: Colors.transparent)),
                    showNavigationArrow: true,
                    navigationMode: DateRangePickerNavigationMode.scroll,
                    onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                      pickedDateRange = dateRangePickerSelectionChangedArgs.value;
                    },
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        if (pickedDateRange != null) {
                          widget.onSubmit(pickedDateRange!);
                        }
                        Get.back();
                        setState(() {});
                      },
                      child: const Text('اختر')),
                  ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text('الغاء'))
                ]);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(widget.initDate != null
                    ? widget.initDate!
                    : pickedDateRange == null
                        ? 'اختر فترة زمنية'
                        : gettext()),
                const Spacer(),
                const Icon(Icons.date_range)
              ],
            ),
          )),
    );
  }

  String gettext() =>
      '${pickedDateRange?.startDate.toString().split(' ').first}  -->  ${pickedDateRange?.endDate.toString().split(' ').first}';
}
