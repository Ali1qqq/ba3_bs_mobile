class SellerModel {
  final String? costGuid;
  final int? costCode;
  final String? costName;
  final String? costLatinName;
  final String? costParentGuid;
  final String? costNote;
  final String? costDebit;
  final String? costCredit;
  final int? costType;
  final int? costSecurity;
  final int? costRes1;
  final int? costRes2;
  final int? costBranchMask;
  final int? costIsChangeableRatio;

  SellerModel({
    this.costGuid,
    this.costCode,
    this.costName,
    this.costLatinName,
    this.costParentGuid,
    this.costNote,
    this.costDebit,
    this.costCredit,
    this.costType,
    this.costSecurity,
    this.costRes1,
    this.costRes2,
    this.costBranchMask,
    this.costIsChangeableRatio,
  });

  // copyWith method
  SellerModel copyWith({
    String? costGuid,
    int? costCode,
    String? costName,
    String? costLatinName,
    String? costParentGuid,
    String? costNote,
    String? costDebit,
    String? costCredit,
    int? costType,
    int? costSecurity,
    int? costRes1,
    int? costRes2,
    int? costBranchMask,
    int? costIsChangeableRatio,
  }) {
    return SellerModel(
      costGuid: costGuid ?? this.costGuid,
      costCode: costCode ?? this.costCode,
      costName: costName ?? this.costName,
      costLatinName: costLatinName ?? this.costLatinName,
      costParentGuid: costParentGuid ?? this.costParentGuid,
      costNote: costNote ?? this.costNote,
      costDebit: costDebit ?? this.costDebit,
      costCredit: costCredit ?? this.costCredit,
      costType: costType ?? this.costType,
      costSecurity: costSecurity ?? this.costSecurity,
      costRes1: costRes1 ?? this.costRes1,
      costRes2: costRes2 ?? this.costRes2,
      costBranchMask: costBranchMask ?? this.costBranchMask,
      costIsChangeableRatio: costIsChangeableRatio ?? this.costIsChangeableRatio,
    );
  }

  // Factory method to create a CostModel from JSON
  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      costGuid: json['CostGuid'],
      costCode: json['CostCode'],
      costName: json['CostName'],
      costLatinName: json['CostLatinName'],
      costParentGuid: json['CostParentGuid'],
      costNote: json['CostNote'],
      costDebit: json['CostDebit'].toString(),
      costCredit: json['CostCredit'].toString(),
      costType: json['CostType'],
      costSecurity: json['CostSecurity'],
      costRes1: json['CostRes1'],
      costRes2: json['CostRes2'],
      costBranchMask: json['CostBranchMask'],
      costIsChangeableRatio: json['CostIsChangeableRatio'],
    );
  }

  // Method to convert a CostModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'CostGuid': costGuid,
      'CostCode': costCode,
      'CostName': costName,
      'CostLatinName': costLatinName,
      'CostParentGuid': costParentGuid,
      'CostNote': costNote,
      'CostDebit': costDebit,
      'CostCredit': costCredit,
      'CostType': costType,
      'CostSecurity': costSecurity,
      'CostRes1': costRes1,
      'CostRes2': costRes2,
      'CostBranchMask': costBranchMask,
      'CostIsChangeableRatio': costIsChangeableRatio,
    };
  }
}
