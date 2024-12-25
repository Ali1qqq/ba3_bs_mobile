class ChequesEntryRelationModel {
  final String erGUID;
  final String erEntryGUID;
  final String erParentGUID;
  // final int erParentType;
  // final int erParentNumber;

  const ChequesEntryRelationModel({
    required this.erGUID,
    required this.erEntryGUID,
    required this.erParentGUID,
    // required this.erParentType,
    // required this.erParentNumber,
  });

  factory ChequesEntryRelationModel.fromJson(Map<String, dynamic> json) {
    return ChequesEntryRelationModel(
      erGUID: json['ErGUID'] as String,
      erEntryGUID: json['ErEntryGUID'] as String,
      erParentGUID: json['ErParentGUID'] as String,
      // erParentType: json['ErParentType'] as int,
      // erParentNumber: json['ErParentNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ErGUID': erGUID,
      'ErEntryGUID': erEntryGUID,
      'ErParentGUID': erParentGUID,
      // 'ErParentType': erParentType,
      // 'ErParentNumber': erParentNumber,
    };
  }

  ChequesEntryRelationModel copyWith({
    String? erGUID,
    String? erEntryGUID,
    String? erParentGUID,
    // int? erParentType,
    // int? erParentNumber,
  }) {
    return ChequesEntryRelationModel(
      erGUID: erGUID ?? this.erGUID,
      erEntryGUID: erEntryGUID ?? this.erEntryGUID,
      erParentGUID: erParentGUID ?? this.erParentGUID,
      // erParentType: erParentType ?? this.erParentType,
      // erParentNumber: erParentNumber ?? this.erParentNumber,
    );
  }
}