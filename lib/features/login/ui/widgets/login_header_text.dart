import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_constants.dart';

class LoginHeaderText extends StatelessWidget {
  const LoginHeaderText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
         Text(
          "Ba3 Business Solutions",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 60.sp, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
        ),
        Text(
          "تسجيل الدخول الى ${AppConstants.dataName}",
          style:  TextStyle(fontSize: 23.sp, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
