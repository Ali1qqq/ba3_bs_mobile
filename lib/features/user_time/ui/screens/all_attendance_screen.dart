import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';

class AllAttendanceScreen extends StatelessWidget {
  const AllAttendanceScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<UserManagementController>(builder: (userManagementController) {
        return ListView(
          padding: EdgeInsets.symmetric(vertical: 10),
          children: [
            SizedBox(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: userManagementController.filteredUsersWithDetails.map((user) {
                  return Container(
                    padding: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withAlpha(125), spreadRadius: 2, blurRadius: 5),
                      ],
                    ),
                    height: 130,
                    width: 180,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(user.userName!,
                            textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if (user.loginDelay == AppStrings.notLoggedToday.tr && user.logoutDelay == AppStrings.notLoggedToday.tr)
                          Text(AppStrings.notLoggedToday.tr, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                        else ...[
                          Text("${AppStrings.delayedEntry.tr}: ${user.loginDelay ?? AppStrings.nothing.tr}"),
                          Text("${AppStrings.leaveEarly.tr}: ${user.logoutDelay ?? AppStrings.nothing.tr}"),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }),
    );
  }
}