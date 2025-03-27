import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/custom_text_field_without_icon.dart';

class TextFieldWithLabel extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;
  final FormFieldValidator<String> validator;
  final TextStyle? textStyle;
  final bool visible;

  const TextFieldWithLabel({
    super.key,
    required this.label,
    required this.textEditingController,
    required this.validator,
    this.textStyle,
    this.visible=true,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible:visible ,
      child: SizedBox(
        width: Get.width * 0.45,
        child: Row(
          children: [
            SizedBox(width: 150, child: Text(label)),
            Expanded(
              child: CustomTextFieldWithoutIcon(
                textEditingController: textEditingController,
                validator: visible ? validator : null,
                textStyle: textStyle ?? const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
