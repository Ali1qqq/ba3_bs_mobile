import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_text_field_with_icon.dart';

class SearchableAccountCustomerField extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;
  final Function(String text) onSubmitted;
  final FormFieldValidator<String>? validator;
  final double? height;
  final double? width;

  final bool readOnly;

  const SearchableAccountCustomerField({
    super.key,
    required this.label,
    required this.textEditingController,
    required this.onSubmitted,
    this.height,
    this.width,
    this.readOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? Get.width * 0.45,
      height: height,
      child: Row(
        children: [
          SizedBox(width: 150, child: Text(label)),
          Expanded(
            child: CustomTextFieldWithIcon(
              readOnly: readOnly,
              textEditingController: textEditingController,
              validator: validator,
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}