import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:flutter/material.dart';

class BodyBondLayoutWidget extends StatelessWidget {
  const BodyBondLayoutWidget({super.key, required this.firstText, required this.secondText});

  final String firstText, secondText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          child: Text(
            firstText,
            style: AppTextStyles.headLineStyle3,
          ),
        ),
        SizedBox(
          child: Text(
            secondText,
            style: AppTextStyles.headLineStyle3,
          ),
        ),
      ],
    );
  }
}