import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_spacer.dart';

class BodyPatternWidget extends StatelessWidget {
  const BodyPatternWidget({super.key, required this.firstText, required this.secondText, this.visible});

  final String firstText, secondText;
  final bool? visible;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible ?? true,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 200,
                child: Text(
                  firstText,
                  style: AppTextStyles.headLineStyle3,
                ),
              ),
              SizedBox(
                width: 200,
                child: Text(
                  secondText,
                  style: AppTextStyles.headLineStyle3,
                ),
              ),
            ],
          ),
          VerticalSpace(5),
        ],
      ),
    );
  }
}