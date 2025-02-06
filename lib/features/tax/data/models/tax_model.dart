class TaxModel {
  final String? taxGuid;
  final double? taxRatio;
  final String? taxName;
  final String? taxAccountGuid;

  TaxModel({
    this.taxGuid,
    this.taxRatio,
    this.taxName,
    this.taxAccountGuid,
  });

  // Convert RoleModel object to JSON
  Map<String, dynamic> toJson() {
    return {
      'docId': taxGuid,
      'taxRatio': taxRatio,
      'taxName': taxName,
      'taxAccountGuid': taxAccountGuid,
    };
  }

  // Create RoleModel object from JSON
  factory TaxModel.fromJson(Map<String, dynamic> json) {
    return TaxModel(
      taxGuid: json['docId'],
      taxRatio: json['taxRatio'],
      taxName: json['taxName'],
      taxAccountGuid: json['taxAccountGuid'],
    );
  }

  // CopyWith method to create a new RoleModel with specific changes
  TaxModel copyWith({
    String? taxGuid,
    String? taxName,
    String? taxAccountGuid,
    double? taxRatio,
  }) {
    return TaxModel(
      taxGuid: taxGuid ?? this.taxGuid,
      taxName: taxName ?? this.taxName,
      taxAccountGuid: taxName ?? this.taxAccountGuid,
      taxRatio: taxRatio ?? this.taxRatio,
    );
  }
}
