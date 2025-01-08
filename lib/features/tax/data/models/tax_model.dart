

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

enum VatEnums {
  withVat(
      taxGuid: 'xtc33mNeCZYR98i96pd8',
      taxName: 'الاساسي',
      taxRatio: 0.05,
      taxAccountGuid: 'a5c04527-63e8-4373-92e8-68d8f88bdb16'),
  withOutVat(
      taxGuid: 'kCfkUHwNyRbxTlD71uXV',
      taxName: 'معفى',
      taxRatio: 0,
      taxAccountGuid: 'a5c04527-63e8-4373-92e8-68d8f88bdb16');

  final String? taxGuid;
  final String? taxName;
  final String? taxAccountGuid;
  final double? taxRatio;

  const VatEnums({
    required this.taxGuid,
    required this.taxName,
    required this.taxRatio,
    required this.taxAccountGuid,
  });

// Factory constructor with error handling for unmatched labels
  factory VatEnums.byName(String label) {
    return VatEnums.values.firstWhere(
      (type) => type.taxName == label,
      orElse: () => throw ArgumentError('No matching Vat for label: $label'),
    );
  }

  factory VatEnums.byGuid(String guid) {
    return VatEnums.values.firstWhere(
      (type) => type.taxGuid == guid,
      orElse: () => throw ArgumentError('No matching Vat for guid: $guid'),
    );
  }
}


