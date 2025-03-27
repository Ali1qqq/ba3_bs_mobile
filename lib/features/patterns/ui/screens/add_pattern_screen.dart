import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_spacer.dart';
import '../../controllers/pattern_controller.dart';
import '../widgets/add_pattern/add_pattern_bottom_buttons.dart';
import '../widgets/add_pattern/add_pattern_form.dart';
import '../widgets/add_pattern/colors_picker.dart';

class AddPatternScreen extends StatelessWidget {
  const AddPatternScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(AppStrings.addPattern.tr),
              ),
              body: GetBuilder<PatternController>(
                builder: (patternController) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: ListView(
                      children: [
                        const VerticalSpace(20),
                        AddPatternForm(patternController: patternController),
                        const VerticalSpace(40),
                        ColorsPicker(patternController: patternController),
                        const VerticalSpace(40),
                        AddPatternBottomButtons(patternController: patternController),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}