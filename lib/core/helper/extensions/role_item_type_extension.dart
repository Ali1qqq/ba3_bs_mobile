import 'dart:developer';

import '../../../features/users_management/controllers/user_management_controller.dart';
import '../../../features/users_management/data/models/role_model.dart';
import '../enums/enums.dart';
import 'getx_controller_extensions.dart';

extension RoleItemTypeExtension on RoleItemType {
  /// Returns the [Status] based on the current [RoleItemType].
  Status get status {
    final permissionStatus = _checkPermissionStatus;

    // Log the role type and permission for debugging purposes
    log('RoleItemType: $this, hasPermission: $permissionStatus');

    return permissionStatus ? Status.approved : Status.pending;
  }

  /// Returns whether the current [RoleItemType] has permission.
  bool get hasPermission => _checkPermissionStatus;

  bool get _checkPermissionStatus => read<UserManagementController>().hasPermission(this);
}
