import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/styling/app_text_style.dart';

class BoxOrganizeWidget extends StatelessWidget {
  const BoxOrganizeWidget(
      {super.key, required this.titleText, required this.childWidget, required this.primaryColor, required this.secondaryColor});

  final String titleText;
  final Widget childWidget;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 110.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            primaryColor,
            secondaryColor,
          ],
          begin: Alignment.topRight,
          end: Alignment.topLeft,
        ),
      ),
      child: Stack(
        children: [

          Positioned(
            top: -40.h,
            left: -30.w,
            child: Container(
              width: 70.w,
              height: 170.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(30),
              ),
            ),
          ),
          Positioned(
            bottom: 30.h,
            right: -12.w,
            child: Container(
              width: 25.w,
              height: 45.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(40),
              ),
            ),
          ),
          Positioned(
            bottom: -30.h,
            right: -15.w,
            child: Container(
              width: 35.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(40),
              ),
            ),
          ),
          Positioned(
            top: 10,
            bottom: 10,
            left: 10,
            right: 10,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text(titleText, style: AppTextStyles.headLineStyle2.copyWith(color: Colors.white))),
                  Divider(color: Colors.grey.shade300,),
                  SizedBox(
                    height:60.h ,
                    child: childWidget,
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}