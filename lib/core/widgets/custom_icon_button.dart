import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final bool disabled;

  const CustomIconButton({super.key, required this.icon, required this.onPressed, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // color: disabled ? AppColors.grayColor : Colors.blue.shade700,
      // padding: EdgeInsets.zero,

      // no inner padding
      // constraints: const BoxConstraints(),
      // no min/max size constraints
      onTap: disabled ? () {} : onPressed,
      child: icon,
    );
  }
}