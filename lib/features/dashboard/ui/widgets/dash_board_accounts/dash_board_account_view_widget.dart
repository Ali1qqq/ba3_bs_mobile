import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/dialogs/account_dashboard_dialog.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_icon_button.dart';
import '../../../../../core/widgets/language_switch_fa_icon.dart';
import '../../../controller/dashboard_layout_controller.dart';
import 'dashboard_accounts_list.dart';

class DashBoardAccountViewWidget extends StatelessWidget {
  const DashBoardAccountViewWidget({super.key, required this.controller});

  final DashboardLayoutController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      height: 120.h,
      width: 1.sw,
      child: Column(
        children: [
          Row(
            children: [
              Spacer(),
              Text(AppStrings.mainUsers.tr, style: AppTextStyles.headLineStyle2),
              Spacer(),
              CustomIconButton(
                onPressed: () {
                  controller.refreshDashBoardAccounts();
                },
                icon: LanguageSwitchFaIcon(
                  iconData: FontAwesomeIcons.arrowsRotate,
                  size: 13,
                ),
              ),
              HorizontalSpace(),
              CustomIconButton(
                onPressed: () {
                  showDialog<String>(context: Get.context!, builder: (BuildContext context) => showDashboardAccountDialog(context));
                },
                icon: LanguageSwitchFaIcon(
                  iconData: FontAwesomeIcons.plus,
                  size: 13,
                ),
              ),
              HorizontalSpace(),
            ],
          ),
          Divider(),
          Expanded(
            child: DashboardAccountsList(controller: controller),
          ),
        ],
      ),
    );
  }
}