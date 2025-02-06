import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

class AllAttendanceScreen extends StatelessWidget {
  const AllAttendanceScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("لوحة تحكم المستخدمين"),
      ),
      body: GetBuilder<UserManagementController>(builder: (userManagementController) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
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
                  width: 225,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.userName!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (user.loginDelay == "لم يسجل بعد" && user.logoutDelay == "لم يسجل بعد")
                        Text("لم يسجل بعد", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                      else ...[
                        Text("تأخير الدخول: ${user.loginDelay ?? 'لا يوجد'}"),
                        Text("الخروج مبكرا: ${user.logoutDelay ?? 'لا يوجد'}"),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }
}
