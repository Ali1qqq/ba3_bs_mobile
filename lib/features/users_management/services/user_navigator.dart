import 'package:ba3_bs_mobile/features/users_management/controllers/user_details_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/services/role_form_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/get_x/shared_preferences_service.dart';
import '../controllers/user_management_controller.dart';
import '../data/models/role_model.dart';
import '../data/models/user_model.dart';

class UserNavigator with AppNavigator {
  final RoleFormHandler _roleFormHandler;
  final SharedPreferencesService _sharedPreferencesService;

  UserManagementController get _userController => read<UserManagementController>();

  UserDetailsController get _userDetailsController => read<UserDetailsController>();

  UserNavigator(this._roleFormHandler, this._sharedPreferencesService);

  void navigateToAddRoleScreen([RoleModel? role]) {
    _roleFormHandler.init(role);
    to(AppRoutes.addRoleScreen);
  }

  void navigateToAddUserScreen([UserModel? user]) {
    _userDetailsController.initUserFormHandler(user);

    to(AppRoutes.addUserScreen);
    // log(user!.toJson().toString());
    // Get.to(() => AllAttendanceScreen());
  }

  void navigateToAllUsersScreen() => to(AppRoutes.showAllUsersScreen);

  void navigateToUserTimeListScreen() => to(AppRoutes.showUserTimeListScreen);

  void navigateToLAllPermissionsScreen() {
    to(AppRoutes.showAllPermissionsScreen);
  }

  void navigateToUserDetails(String? userId) {
    if (userId != null) _userDetailsController.getUserById(userId);

    to(AppRoutes.showUserDetails);
  }

  void navigateToLogin() async {
    if (_sharedPreferencesService.getString(AppConstants.userIdKey) == null) {
      offAll(AppRoutes.loginScreen);
    } else {
      _userController.fetchAndHandleUser(_sharedPreferencesService.getString(AppConstants.userIdKey)!);
    }
  }
}
