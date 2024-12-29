import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';

class RoleService {
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
}
