
import 'package:flutter/material.dart';

import '../../../../../core/styling/app_text_style.dart';

class BodyPatternWidget extends StatelessWidget {
  const BodyPatternWidget({super.key, required this.firstText, required this.secondText});

  final String firstText, secondText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              firstText,
              style: AppTextStyles.headLineStyle3,
            ),
          ),
          Expanded(
            child: Text(
              secondText,
              textAlign: TextAlign.start,
              style: AppTextStyles.headLineStyle3,
            ),
          ),
        ],
      ),
    );
  }
}
