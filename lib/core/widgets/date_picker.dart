import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../features/floating_window/services/overlay_service.dart';
import '../constants/app_constants.dart';

class DatePicker extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  final String? initDate;

  const DatePicker({super.key, required this.onDateSelected, this.initDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.constHeightTextField,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: const Border.symmetric(vertical: BorderSide(width: 1))),
      child: InkWell(
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
          // Get.defaultDialog(
          //   title: "اختر يوم",
          //   content: SizedBox(
          //     height: MediaQuery.sizeOf(context).height / 1.6,
          //     width: MediaQuery.sizeOf(context).height / 1,
          //     child: SfDateRangePicker(
          //       initialDisplayDate: DateTime.tryParse(initDate ?? ""),
          //       enableMultiView: true,
          //       backgroundColor: Colors.transparent,
          //       headerStyle: const DateRangePickerHeaderStyle(backgroundColor: Colors.transparent),
          //       navigationDirection: DateRangePickerNavigationDirection.vertical,
          //       selectionMode: DateRangePickerSelectionMode.single,
          //       monthViewSettings: const DateRangePickerMonthViewSettings(enableSwipeSelection: false),
          //       showNavigationArrow: true,
          //       navigationMode: DateRangePickerNavigationMode.scroll,
          //       onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
          //         DateTime selectedDate = dateRangePickerSelectionChangedArgs.value as DateTime;
          //         onDateSelected(selectedDate);
          //         Get.back();
          //       },
          //     ),
          //   ),
          //   actions: [
          //     ElevatedButton(
          //       onPressed: () {
          //         Get.back();
          //       },
          //       child: const Text("إلغاء"),
          //     ),
          //   ],
          // );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  initDate ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const Icon(Icons.date_range,color: Colors.blue,size: 18,),
            ],
          ),
        ),
      ),
    );
  }
}
