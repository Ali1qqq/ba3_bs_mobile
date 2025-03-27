import 'package:flutter/material.dart';

import '../styling/app_colors.dart';

class CustomIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final bool disabled;

  const CustomIconButton({super.key, required this.icon, required this.onPressed, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: disabled ? AppColors.grayColor : Colors.blue.shade700,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: disabled ? () {} : onPressed,
      icon: icon,
    );
  }
}
