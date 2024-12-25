import 'package:flutter/material.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../controllers/user_management_controller.dart';
import '../data/models/role_model.dart';

class RoleFormHandler with AppValidator {
  final formKey = GlobalKey<FormState>();
  final roleNameController = TextEditingController();
  Map<RoleItemType, List<RoleItem>> rolesMap = {};

  UserManagementController get userManagementController => read<UserManagementController>();

  void init(RoleModel? role) {
    if (role != null) {
      userManagementController.roleModel = role;
      rolesMap = role.roles;

      roleNameController.text = role.roleName ?? '';
    } else {
      userManagementController.roleModel = null;

      clear();
    }
  }

  void clear() {
    roleNameController.clear();
    rolesMap.clear();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  void dispose() {
    roleNameController.dispose();
  }

  String? defaultValidator(String? value, String fieldName) => isFieldValid(value, fieldName);
}
