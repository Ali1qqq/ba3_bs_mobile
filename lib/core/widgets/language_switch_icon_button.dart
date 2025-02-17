import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/services/translation/translation_controller.dart';
import 'package:flutter/material.dart';

import '../styling/app_colors.dart';

class LanguageSwitchIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final bool disabled;

  const LanguageSwitchIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // يتم عكس الأيقونة إذا كانت لغة التطبيق من اليمين لليسار
    final Widget displayedIcon = Transform.scale(
      scaleX: read<TranslationController>().currentLocaleIsRtl ? -1 : 1,
      child: icon,
    );

    return IconButton(
      color: disabled ? AppColors.grayColor : Colors.blue.shade700,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: disabled ? () {} : onPressed,
      icon: displayedIcon,
    );
  }
}