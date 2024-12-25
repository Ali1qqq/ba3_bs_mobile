import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../controllers/user_management_controller.dart';

class RoleService {
  UserManagementController get userManagementController => read<UserManagementController>();

  RoleModel? createRoleModel({
    RoleModel? roleModel,
    required Map<RoleItemType, List<RoleItem>> roles,
    required String roleName,
  }) {
    if (roles.isEmpty) {
      return null;
    }
    final RoleModel newRoleModel;

    if (roleModel == null) {
      newRoleModel = RoleModel(roles: roles, roleName: roleName);
    } else {
      newRoleModel = roleModel.copyWith(roles: roles, roleName: roleName);
    }
    return newRoleModel;
  }

  UserModel? createUserModel({
    UserModel? userModel,
    required String userName,
    required String userPassword,
    String? userRoleId,
    String? userSellerId,
  }) {
    if (userRoleId == null || userSellerId == null) {
      return null;
    }

    final UserModel newUserModel;

    if (userModel == null) {
      newUserModel = UserModel(
        userName: userName,
        userPassword: userPassword,
        userRoleId: userRoleId,
        userSellerId: userSellerId,
      );
    } else {
      newUserModel = userModel.copyWith(
        userName: userName,
        userPassword: userPassword,
        userRoleId: userRoleId,
        userSellerId: userSellerId,
      );
    }
    return newUserModel;
  }

  bool hasPermission(RoleItemType roleItemType) {
    final UserModel? userModel = userManagementController.loggedInUserModel;
    // Return false if userModel or userRoleId is null
    if (userModel == null || userModel.userRoleId == null) {
      return false;
    }

    // Retrieve the RoleModel based on the user's role ID
    final roleModel = userManagementController.getRoleById(userModel.userRoleId!);

    // Get the list of RoleItems for the given RoleItemType
    List<RoleItem>? roleItems = roleModel.roles[roleItemType];

    // Check if the list contains RoleItem.userAdmin
    if (roleItems?.contains(RoleItem.userAdmin) ?? false) {
      return true; // Return true if the user has the permission
    }

    // Default to false if no match is found
    return false;
  }
}
