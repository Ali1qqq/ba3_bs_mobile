import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/custom_text_field_without_icon.dart';

class TextFieldWithLabel extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;
  final FormFieldValidator<String> validator;
  final TextStyle? textStyle;

  const TextFieldWithLabel({
    super.key,
    required this.label,
    required this.textEditingController,
    required this.validator,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1.sw,
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: CustomTextFieldWithoutIcon(
              textEditingController: textEditingController,
              validator: validator,
              textStyle: textStyle ?? const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
