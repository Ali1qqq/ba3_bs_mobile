import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ProfileInfoRowShimmerWidget extends StatelessWidget {
  final double width;

  const ProfileInfoRowShimmerWidget({
    super.key,
    this.width = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(15.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white), color: Colors.white.withAlpha(70)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildShimmerBox(width: width),
            HorizontalSpace(),
            _buildShimmerBox(width: width),
          ],
        ),
      ),
    );
  }
}

// Shimmer box method for individual elements
Widget _buildShimmerBox({required double width, double borderRadius = 4}) => Shimmer.fromColors(
      baseColor: Colors.red,
      highlightColor: Colors.red,
      child: Container(
        width: (width.w / 1.5),
        height: 10.h,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );