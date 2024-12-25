import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:flutter/material.dart';

class BodyPatternWidget extends StatelessWidget {
  const BodyPatternWidget({super.key, required this.firstText, required this.secondText});

  final String firstText, secondText;

  @override
  Widget build(BuildContext context) {
    return Row(

      children: [
        SizedBox(
          width: 100,
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
    );
  }
}
