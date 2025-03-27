import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/features/floating_window/services/overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../controllers/pattern_controller.dart';

class PatternTypeDropdown extends StatelessWidget {
  const PatternTypeDropdown({super.key, required this.patternController});

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return TextAndExpandedChildField(
      label: AppStrings.billType.tr,
      child: Obx(() {
        return OverlayService.showDropdown<BillPatternType>(
          value: patternController.patternFormHandler.selectedBillPatternType.value ?? BillPatternType.values.first,
          items: BillPatternType.values,
          onChanged: patternController.patternFormHandler.onSelectedTypeChanged,
          itemLabelBuilder: (type) => type.label.tr,
          textStyle: const TextStyle(fontSize: 14),
          height: AppConstants.constHeightDropDown,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(5),
          ),
          onCloseCallback: () {
            log('BillPatternType Dropdown Overlay Closed.');
          },
        );
      }),
    );
  }
}