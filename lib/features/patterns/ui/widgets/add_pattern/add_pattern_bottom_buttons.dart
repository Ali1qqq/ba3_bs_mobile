import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/pattern_controller.dart';

class AddPatternBottomButtons extends StatelessWidget {
  const AddPatternBottomButtons({super.key, required this.patternController});

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AppButton(
          title: patternController.patternFormHandler.selectedBillPatternType.value == null ? AppStrings.add.tr : AppStrings.edit.tr,
          onPressed: () {
            patternController.addNewPattern();
          },
          iconData: Icons.add,
        ),
      ],
    );
  }
}