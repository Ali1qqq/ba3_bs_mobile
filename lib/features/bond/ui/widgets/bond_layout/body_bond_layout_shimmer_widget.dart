import 'package:ba3_bs_mobile/core/styling/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/constants/app_strings.dart';

class BodyBondLayoutShimmerWidget extends StatelessWidget {
  const BodyBondLayoutShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: SizedBox(
            child: Text(
              AppStrings.from.tr,
              style: AppTextStyles.headLineStyle3,
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: SizedBox(
            child: Text(
              AppStrings.to.tr,
              style: AppTextStyles.headLineStyle3,
            ),
          ),
        ),
      ],
    );
  }
}