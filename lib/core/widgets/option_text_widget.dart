import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_text_field_with_icon.dart';

class OptionTextWidget extends StatelessWidget {
  const OptionTextWidget(
      {required this.title,
      super.key,
      required this.controller,
      required this.onSubmitted});

  final String title;
  final TextEditingController controller;
  final void Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 100, child: Text(title)),
          SizedBox(
            width: Get.width / 3,
            child: CustomTextFieldWithIcon(
                textEditingController: controller, onSubmitted: onSubmitted),
          ),
        ],
      ),
    );
  }
}

class OptionTextWithoutIconWidget extends StatelessWidget {
  const OptionTextWithoutIconWidget(
      {required this.title,
      super.key,
      required this.controller,
      required this.onSubmitted});

  final String title;
  final TextEditingController controller;
  final void Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 100, child: Text(title)),
          SizedBox(
            width: Get.width / 3,
            child: CustomTextFieldWithIcon(
              textEditingController: controller,
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
