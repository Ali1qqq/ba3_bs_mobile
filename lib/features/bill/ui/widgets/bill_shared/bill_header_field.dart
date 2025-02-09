import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TextAndExpandedChildField extends StatelessWidget {
  final String label;
  final Widget child;
  final double? width;
  final double? height;
  final double? textWidth;

  const TextAndExpandedChildField({super.key, required this.label, required this.child, this.width, this.textWidth, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? Get.width * 0.45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: textWidth ?? 100,
            child: Text(label, style: const TextStyle()),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
