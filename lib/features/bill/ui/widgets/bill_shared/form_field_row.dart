import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_spacer.dart';

class FormFieldRow extends StatelessWidget {
  const FormFieldRow({super.key, required this.firstItem, required this.secondItem});

  final Widget firstItem;
  final Widget secondItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: firstItem),
        const HorizontalSpace(20),
        Expanded(child: secondItem),
      ],
    );
  }
}
