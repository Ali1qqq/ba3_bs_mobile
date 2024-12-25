import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemWidget extends StatelessWidget {
  const ItemWidget({super.key, required this.onTap, required this.text,this.color=Colors.white});

  final VoidCallback onTap;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          width: 1.sw,
          height: 100.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color)
          ),

          child: Text(
                      text,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textDirection: TextDirection.rtl,
                    )),
    );
  }
}
