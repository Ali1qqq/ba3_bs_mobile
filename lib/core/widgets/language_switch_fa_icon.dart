import 'package:ba3_bs_mobile/core/services/translation/translation_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../styling/app_colors.dart';

class LanguageSwitchFaIcon extends StatelessWidget {
  final IconData iconData;
  final double size;
  final Color? color;
  final VoidCallback onPressed;
  final bool disabled;

  const LanguageSwitchFaIcon(
      {super.key, required this.iconData, this.size = 20.0, this.color, required this.onPressed, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? () {} : onPressed,
      child: GetBuilder<TranslationController>(builder: (controller) {
        return Transform.scale(
          alignment: Alignment.center,
          scaleX: !(controller.currentLocaleIsRtl) ? -1.0 : 1.0,
          child: FaIcon(
            iconData,
            size: size,
            color: disabled ? AppColors.grayColor : Colors.blue.shade700,
          ),
        );
      }),
    );
  }
}