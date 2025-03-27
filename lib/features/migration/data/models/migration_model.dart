class MigrationModel {
  final String? id;
  final String? currentVersion;
  final List<String>? migrationVersions;

  MigrationModel({
    this.id,
    this.currentVersion,
    this.migrationVersions,
  });

  /// 🔹 Convert JSON to `MigrationModel`
  factory MigrationModel.fromJson(Map<String, dynamic> json) {
    return MigrationModel(
      id: json['docId'] as String?,
      currentVersion: json['currentVersion'] as String?,
      migrationVersions: List<String>.from(json['migrationVersions'] ?? []),
    );
  }

  /// 🔹 Convert `MigrationModel` to JSON
  Map<String, dynamic> toJson() {
    return {
      'docId': id,
      'currentVersion': currentVersion,
      'migrationVersions': migrationVersions,
    };
  }

  /// 🔹 `copyWith` method to create a modified copy of `MigrationModel`
  MigrationModel copyWith({
    String? id,
    String? currentVersion,
    List<String>? migrationVersions,
  }) {
    return MigrationModel(
      id: id ?? this.id,
      currentVersion: currentVersion ?? this.currentVersion,
      migrationVersions: migrationVersions ?? this.migrationVersions,
    );
  }
}
