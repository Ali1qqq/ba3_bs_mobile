class VatModel {
  final String? vatGuid;
  final double? vatRatio;
  final String? vatName;

  VatModel({
    this.vatGuid,
    this.vatRatio,
    this.vatName,
  });

  // Convert RoleModel object to JSON
  Map<String, dynamic> toJson() {
    return {'vatGuid': vatGuid, 'vatRatio': vatRatio, 'vatName': vatName};
  }

  // Create RoleModel object from JSON
  factory VatModel.fromJson(Map<String, dynamic> json) {
    return VatModel(
      vatGuid: json['vatGuid'],
      vatRatio: json['vatRatio'],
      vatName: json['vatName'],
    );
  }

  // CopyWith method to create a new RoleModel with specific changes
  VatModel copyWith({
    String? vatGuid,
    String? vatName,
    double? vatRatio,
  }) {
    return VatModel(
      vatGuid: vatGuid ?? this.vatGuid,
      vatName: vatName ?? this.vatName,
      vatRatio: vatRatio ?? this.vatRatio,
    );
  }
}

enum VatEnums {
  withVat(vatGuid: '1', vatName: 'الاساسي', vatRatio: 0.05),
  withOutVat(vatGuid: '2', vatName: 'معفى', vatRatio: 0);

  final String? vatGuid;
  final String? vatName;
  final double? vatRatio;

  const VatEnums({
    required this.vatGuid,
    required this.vatName,
    required this.vatRatio,
  });

// Factory constructor with error handling for unmatched labels
  factory VatEnums.byName(String label) {
    return VatEnums.values.firstWhere(
      (type) => type.vatName == label,
      orElse: () => throw ArgumentError('No matching Vat for label: $label'),
    );
  }

  factory VatEnums.byGuid(String guid) {
    return VatEnums.values.firstWhere(
      (type) => type.vatGuid == guid,
      orElse: () => throw ArgumentError('No matching Vat for guid: $guid'),
    );
  }
}


VatModel withVat = VatModel(
  vatGuid: '1',
  vatRatio: 5.0,
  vatName: 'ضريبة القيمة المضافة في رأس الخيمة',
);
VatModel withOutVat = VatModel(
  vatGuid: '2',
  vatRatio: 0,
  vatName: 'معفى',
);
