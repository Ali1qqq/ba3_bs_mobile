class OldRoleModel {
  String? roleId, roleName;
  Map<String, List<String>> roles = {};

  OldRoleModel({this.roleId, this.roleName, required this.roles});

  // Convert RoleModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'roleId': roleId,
      'roleName': roleName,
      'roles': roles,
    };
  }

  // Create RoleModel object from JSON
  factory OldRoleModel.fromJson(Map<String, dynamic> json) {
    return OldRoleModel(
      roleId: json['roleId'],
      roleName: json['roleName'],
      roles: json['roles'] == null
          ? {}
          : (json['roles'] as Map<String, dynamic>).map((key, value) {
              return MapEntry(key, List<String>.from(value));
            }),
    );
  }
}
