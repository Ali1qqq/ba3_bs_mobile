import 'package:ba3_bs_mobile/core/constants/app_assets.dart';
import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginHeaderText extends StatelessWidget {
  const LoginHeaderText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0), // تحديد درجة التقويس
          child: Image.asset(
            AppAssets.loginLogo,
            width: 0.5.sw,
            height: 0.2.sh,
            fit: BoxFit.cover, // لضبط حجم الصورة
          ),
        ),
        VerticalSpace(),
        Text(
          "Ba3 Business Solutions",
          textAlign: TextAlign.center,
          style: AppTextStyles.headLineStyle1,
        ),
      ],
    );
  }
}
