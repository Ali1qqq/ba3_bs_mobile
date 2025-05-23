import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalculationCard extends StatelessWidget {
  final Color color;
  final String value;
  final String label;
  final double? width;
  final double? height;
  final bool? visible;

  const CalculationCard({
    super.key,
    required this.color,
    required this.value,
    required this.label,
    this.visible,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible ?? true,
      child: Container(
        width: width ?? 50.0.w,
        height: height ?? 65.h,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Center(
              child: Text(
                value,
                style: TextStyle(fontSize: 20.sp, color: Colors.white),
              ),
            ),
            Spacer(),
            FittedBox(
              child: Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 12.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}