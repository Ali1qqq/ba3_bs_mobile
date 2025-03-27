import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../controller/bill_profit_dashboard_controller.dart';

class EmployeeDateMonthHeader extends StatelessWidget {

  const EmployeeDateMonthHeader({super.key});

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
              onTap: () {},
              child: Text(
                AppStrings.employeeCommitment.tr,
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
              onPressed: (){
                read<BillProfitDashboardController>().getAllEmployeeCommitment();

              },
            ),
          ],
        ),
      ),
    );
  }
}