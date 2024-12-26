import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountStatementDetail extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const AccountStatementDetail({
    required this.label,
    required this.value,
    required this.valueColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 14.sp),
        ),
        Text(
          value,
          style: TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: 18.sp),
        ),
      ],
    );
  }
}
