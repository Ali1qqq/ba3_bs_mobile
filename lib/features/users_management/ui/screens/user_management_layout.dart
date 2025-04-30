import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_menu_item.dart';
import '../../data/models/role_model.dart';

class UserManagementLayout extends StatelessWidget {
  const UserManagementLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final UserManagementController userManagementController = read<UserManagementController>();
    userManagementController.getAllUsers();

    log('UserManagementLayout build');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        appBar: AppBar(title: Text(AppStrings.usersManagement.tr)),
        body: RefreshIndicator(
          onRefresh: () => userManagementController.getAllUsers(),
          backgroundColor: Colors.white,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
            children: [
              buildAppMenuItem(
                icon: Icons.supervised_user_circle,
                title: '${AppStrings.administration.tr} ${AppStrings.users.tr}',
                onTap: () {
                  userManagementController.userNavigator.navigateToAllUsersScreen();
                },
              ),
              if (RoleItemType.administrator.hasReadPermission)
                buildAppMenuItem(
                  icon: Icons.security,
                  title: '${AppStrings.administration.tr} ${AppStrings.roles.tr}',
                  onTap: () {
                    userManagementController.userNavigator.navigateToLAllPermissionsScreen();
                  },
                ),
              buildAppMenuItem(
                icon: Icons.access_time_filled,
                title: AppStrings.attendanceRecord.tr,
                onTap: () {
                  userManagementController.userNavigator.navigateToUserTimeListScreen();
                },
              ),
              buildAppMenuItem(
                icon: Icons.task_alt,
                title: AppStrings.tasks.tr,
                onTap: () {
                  userManagementController.userNavigator.lunchAllTaskScreen(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}