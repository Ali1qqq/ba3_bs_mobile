import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_text_field_with_icon.dart';

class SearchableMaterialField extends StatelessWidget {
  final String label;
  final Function(String text) onSubmitted;
  final FormFieldValidator<String>? validator;
  final double? height;
  final TextEditingController textController;
  final double? width;
  final bool readOnly;

  const SearchableMaterialField({
    super.key,
    required this.label,
    required this.textController,
    required this.onSubmitted,
    this.validator,
    this.height,
    this.width,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? Get.width * 0.45,
      height: 34,
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label)),
          Expanded(
            child: CustomTextFieldWithIcon(
              readOnly: readOnly,

              textEditingController: textController,
              validator: validator,
              onSubmitted: onSubmitted
            ),
          ),
        ],
      ),
    );
  }
}
