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
    return InkWell(
      onTap:onPressed ,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
                color: color?? Colors.blue.shade700
        ),
        width: width ?? 110,
        height: height ?? 30,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: fontSize ?? 15,color: Colors.white),
              ),
              Icon(iconData, size: iconSize ?? 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
