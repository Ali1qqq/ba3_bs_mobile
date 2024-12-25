import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.iconData,
    this.color,
    this.width,
    this.height,
    this.fontSize,
    this.iconSize,
  });

  final String title;
  final Color? color;
  final IconData iconData;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(color),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
          ),
        ),
        onPressed: onPressed,
        child: SizedBox(
          width: width ?? 110,
          height: height ?? 35,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: fontSize ?? 15),
                ),
                Icon(iconData, size: iconSize ?? 18, color: Colors.white),
              ],
            ),
          ),
        ));
  }
}
