import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.iconData,
    this.color,
    this.isLoading = false,
    this.width,
    this.height,
    this.fontSize,
    this.iconSize,
  });

  final String title;
  final Color? color;
  final IconData? iconData;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? iconSize;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), color: color ?? Colors.blue.shade700),
        width: width ?? 110,
        height: height ?? 30,
        child: Center(
          child: Row(
            mainAxisAlignment: iconData != null ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
            children: [
              isLoading
                  ? AppUIUtils.showLoadingIndicator(width: 16, height: 16)
                  : Text(
                      title,
                      maxLines: 1,
                      // textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: fontSize ?? 15, color: Colors.white),
                    ),
              if (iconData != null) Icon(iconData, size: iconSize ?? 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
