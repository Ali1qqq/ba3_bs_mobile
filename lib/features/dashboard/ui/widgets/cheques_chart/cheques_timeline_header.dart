import 'package:ba3_bs_mobile/features/dashboard/controller/cheques_timeline_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';

class ChequesTimelineHeader extends StatelessWidget {
  final ChequesTimelineController controller;

  const ChequesTimelineHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Spacer(),
            GestureDetector(
              onTap: () => controller.openChequesDuesScreen(context),
              child: Text(
                AppStrings.chequesDues.tr,
                style: AppTextStyles.headLineStyle1,
              ),
            ),
            Spacer(),
            IconButton(
              tooltip: AppStrings.refresh.tr,
              icon: Icon(
                FontAwesomeIcons.refresh,
                color: AppColors.lightBlueColor,
              ),
              onPressed: controller.getAllDuesCheques,
            ),
          ],
        ),
      ),
    );
  }
}