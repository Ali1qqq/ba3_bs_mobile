import 'package:flutter/material.dart';

class FormFieldRow extends StatelessWidget {
  const FormFieldRow({
    super.key,
    required this.firstItem,
    required this.secondItem,
    this.visible,
    this.spacing = 20,
  });

  final Widget firstItem;
  final Widget secondItem;

  final bool? visible;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return (visible ?? true)
        ? Row(
            spacing: spacing,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: firstItem),
              Expanded(child: secondItem),
            ],
          )
        : SizedBox();
  }
}