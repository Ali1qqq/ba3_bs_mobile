import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';

class SellerModel {
  final String? costGuid;

  // final String? docId;
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
    // this.docId,
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
    String? docId,
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
      // docId: docId ?? this.docId,
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
  factory SellerModel.fromLocalImport(Map<String, dynamic> json) {
    return SellerModel(
      costGuid: json['costGuid'],
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

  factory SellerModel.fromJson(Map<String, dynamic> json) {
    return SellerModel(
      costGuid: json['docId'],
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
      'costGuid': costGuid,
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

class SellerSalesData {
  final String sellerName;
  final double totalMobileSales;
  final double totalAccessorySales;
  final double totalFess;
  final List<BillModel> bills;
  final int? totalDayAttendance;
  final int? totalDayLate;
  final int? totalFiledTasks;

  SellerSalesData({
    required this.sellerName,
    required this.totalMobileSales,
    required this.totalAccessorySales,
    required this.totalFess,
    required this.bills,
    this.totalDayAttendance,
    this.totalDayLate,
    this.totalFiledTasks,
  });
}