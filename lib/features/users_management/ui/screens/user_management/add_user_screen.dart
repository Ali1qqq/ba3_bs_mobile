import 'package:ba3_bs_mobile/features/users_management/controllers/user_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../sellers/controllers/sellers_controller.dart';
import '../../widgets/user_management/user_all_holidays.dart';
import '../../widgets/user_management/user_all_working_hours.dart';
import '../../widgets/user_management/user_details_form_widget.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SellersController sellerViewController = read<SellersController>();
    return GetBuilder<UserDetailsController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(controller.selectedUserModel?.userName ?? 'مستخدم جديد'),
          actions: [],
        ),
        body: Center(
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              UserDetailsForm(
                userDetailsController: controller,
                sellerController: sellerViewController,
              ),
              UserAllWorkingHour(
                userDetailsController: controller,
              ),
              UserAllHolidays(
                userDetailsController: controller,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: .15.sh),
                  child: AppButton(
                    title: controller.selectedUserModel?.userId == null ? 'إضافة' : 'تعديل',
                    onPressed: () {
                      controller.saveOrUpdateUser();
                    },
                    iconData: controller.selectedUserModel?.userId == null ? Icons.add : Icons.edit,
                    color: controller.selectedUserModel?.userId == null ? null : Colors.green,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
