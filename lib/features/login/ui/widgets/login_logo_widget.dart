import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';

class LoginLogoWidget extends StatelessWidget {
  const LoginLogoWidget({
    super.key,
    this.text,
  });

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(
            AppAssets.loginLogo,
            width: 0.25.sw,
            height: 0.25.sw,
            fit: BoxFit.cover,
          ),
        ),
        if (text != null)
          AnimatedTextKit(
            isRepeatingAnimation: false,
            animatedTexts: [
              TyperAnimatedText(text!,
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontSize: 24.0.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  speed: const Duration(milliseconds: 100),
                  curve: Curves.easeIn),
            ],
          ),
      ],
    );
  }
}
