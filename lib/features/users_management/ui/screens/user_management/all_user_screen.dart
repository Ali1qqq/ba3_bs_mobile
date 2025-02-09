import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/user_management_controller.dart';

class AllUserScreen extends StatelessWidget {
  const AllUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserManagementController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('المستخدمين'),
            actions: [
              AppButton(
                  title: 'إضافة',
                  onPressed: () {
                    controller.userNavigator.navigateToAddUserScreen();
                  },
                  iconData: Icons.add),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              SizedBox(
                width: 1.sw,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(
                    controller.allUsers.length,
                    (index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          controller.userNavigator.navigateToAddUserScreen(controller.allUsers[index]);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                          height: 140,
                          width: 160,
                          child: Text(
                            controller.allUsers[index].userName ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
