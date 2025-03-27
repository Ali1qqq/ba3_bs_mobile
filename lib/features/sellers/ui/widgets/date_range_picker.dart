import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateRangePicker extends StatelessWidget {
  final Function() onSubmit;
  final PickerDateRange? pickedDateRange;
  final Function(DateRangePickerSelectionChangedArgs)? onSelectionChanged;

  const DateRangePicker({super.key, required this.onSubmit, required this.onSelectionChanged, this.pickedDateRange});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all()),
      width: 250,
      height: 40,
      child: InkWell(
          onTap: () {
            Get.defaultDialog(
                title: AppStrings.selectATimePeriod.tr,
                content: SizedBox(
                  height: MediaQuery.sizeOf(context).height / 1.6,
                  width: MediaQuery.sizeOf(context).height / 1,
                  child: SfDateRangePicker(
                    enableMultiView: true,
                    backgroundColor: Colors.transparent,
                    headerStyle: const DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent,
                    ),
                    navigationDirection: DateRangePickerNavigationDirection.vertical,
                    selectionMode: DateRangePickerSelectionMode.range,
                    monthViewSettings: const DateRangePickerMonthViewSettings(
                        enableSwipeSelection: false, viewHeaderStyle: DateRangePickerViewHeaderStyle(backgroundColor: Colors.transparent)),
                    showNavigationArrow: true,
                    navigationMode: DateRangePickerNavigationMode.scroll,
                    onSelectionChanged: onSelectionChanged,
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        onSubmit();
                        Get.back();
                      },
                      child: Text(AppStrings.select.tr)),
                  ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(AppStrings.cancel.tr))
                ]);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  pickedDateRange == null ? AppStrings.selectATimePeriod.tr : date,
                ),
                const Spacer(),
                const Icon(Icons.date_range)
              ],
            ),
          )),
    );
  }

  String get date =>
      '${pickedDateRange?.startDate.toString().split(' ').first}  -->  ${pickedDateRange?.endDate.toString().split(' ').first}';
}