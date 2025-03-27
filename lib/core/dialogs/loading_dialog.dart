import 'dart:math';

import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingDialog extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final double? fontSize;

  const LoadingDialog({
    super.key,
    required this.isLoading,
    this.fontSize,
    this.message,
  });

  @override
  Widget build(BuildContext context) => Visibility(
        visible: isLoading,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Opacity(
              opacity: 0.4,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
            SizedBox(
              width: max(.22.sw, 330),
              child: Dialog(
                backgroundColor: AppColors.whiteColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ' جاري تحميل $message',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: fontSize,
                            ),
                      ),
                      HorizontalSpace(6.w),
                      SizedBox(width: 20, height: 20, child: const CircularProgressIndicator()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}