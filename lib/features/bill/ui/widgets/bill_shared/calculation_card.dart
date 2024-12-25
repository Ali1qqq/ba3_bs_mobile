import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalculationCard extends StatelessWidget {
  final Color color;
  final String value;
  final String label;
  final double? width;
  final double? height;

  const CalculationCard({
    super.key,
    required this.color,
    required this.value,
    required this.label,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 50.0.w,
      height: height ?? 80.h,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: Text(
              value,
              style: TextStyle(fontSize: 20.sp, color: Colors.white),
            ),
          ),
          Expanded(
            child: FittedBox(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
