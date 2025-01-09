import 'package:hive/hive.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../pluto/data/models/pluto_adaptable.dart';

part 'material_model.g.dart'; // This will be generated automatically by the build_runner

@HiveType(typeId: 0)
class MaterialModel extends HiveObject implements PlutoAdaptable {
  @HiveField(0)
  final String? id;

  @HiveField(1)
  final int? matCode;

  @HiveField(2)
  final String? matName;

  @HiveField(3)
  final String? matBarCode;

  @HiveField(4)
  final String? matGroupGuid;

  @HiveField(5)
  final String? matUnity;

  @HiveField(6)
  final int? matPriceType;

  @HiveField(7)
  final int? matBonus;

  @HiveField(8)
  final int? matBonusOne;

  @HiveField(9)
  final String? matCurrencyGuid;

  @HiveField(10)
  final double? matCurrencyVal;

  @HiveField(11)
  final String? matPictureGuid;

  @HiveField(12)
  final int? matType;

  @HiveField(13)
  final int? matSecurity;

  @HiveField(14)
  final int? matFlag;

  @HiveField(15)
  final int? matExpireFlag;

  @HiveField(16)
  final int? matProdFlag;

  @HiveField(17)
  final int? matUnit2FactFlag;

  @HiveField(18)
  final int? matUnit3FactFlag;

  @HiveField(19)
  final int? matSNFlag;

  @HiveField(20)
  final int? matForceInSN;

  @HiveField(21)
  final int? matForceOutSN;

  @HiveField(22)
  final int? matVAT;

  @HiveField(23)
  final int? matDefUnit;

  @HiveField(24)
  final int? matBranchMask;

  @HiveField(25)
  final int? matAss;

  @HiveField(26)
  final String? matOldGUID;

  @HiveField(27)
  final String? matNewGUID;

  @HiveField(28)
  final int? matCalPriceFromDetail;

  @HiveField(29)
  final int? matForceInExpire;

  @HiveField(30)
  final int? matForceOutExpire;

  @HiveField(31)
  final DateTime? matCreateDate;

  @HiveField(32)
  final int? matIsIntegerQuantity;

  @HiveField(33)
  final int? matClassFlag;

  @HiveField(34)
  final int? matForceInClass;

  @HiveField(35)
  final int? matForceOutClass;

  @HiveField(36)
  final int? matDisableLastPrice;

  @HiveField(37)
  final double? matLastPriceCurVal;

  @HiveField(38)
  final String? matPrevQty;

  @HiveField(39)
  final DateTime? matFirstCostDate;

  @HiveField(40)
  final int? matHasSegments;

  @HiveField(41)
  final String? matParent;

  @HiveField(42)
  final int? matIsCompositionUpdated;

  @HiveField(43)
  final int? matInheritsParentSpecs;

  @HiveField(44)
  final String? matCompositionName;

  @HiveField(45)
  final String? matCompositionLatinName;

  @HiveField(46)
  final int? movedComposite;

  @HiveField(47)
  final String? wholesalePrice;

  @HiveField(48)
  final String? retailPrice;

  @HiveField(49)
  final String? endUserPrice;

  @HiveField(50)
  final String? matVatGuid;

  @HiveField(51)
  final List<MatExtraBarcodeModel>? matExtraBarcode;

  MaterialModel({
    this.id,
    this.matCode,
    this.matName,
    this.matBarCode,
    this.matGroupGuid,
    this.matUnity,
    this.matPriceType,
    this.matBonus,
    this.matBonusOne,
    this.matCurrencyGuid,
    this.matCurrencyVal,
    this.matPictureGuid,
    this.matType,
    this.matSecurity,
    this.matFlag,
    this.matExpireFlag,
    this.matProdFlag,
    this.matUnit2FactFlag,
    this.matUnit3FactFlag,
    this.matSNFlag,
    this.matForceInSN,
    this.matForceOutSN,
    this.matVAT,
    this.matDefUnit,
    this.matBranchMask,
    this.matAss,
    this.matOldGUID,
    this.matNewGUID,
    this.matCalPriceFromDetail,
    this.matForceInExpire,
    this.matForceOutExpire,
    this.matCreateDate,
    this.matIsIntegerQuantity,
    this.matClassFlag,
    this.matForceInClass,
    this.matForceOutClass,
    this.matDisableLastPrice,
    this.matLastPriceCurVal,
    this.matPrevQty,
    this.matFirstCostDate,
    this.matHasSegments,
    this.matParent,
    this.matIsCompositionUpdated,
    this.matInheritsParentSpecs,
    this.matCompositionName,
    this.matCompositionLatinName,
    this.movedComposite,
    this.wholesalePrice,
    this.retailPrice,
    this.endUserPrice,
    this.matVatGuid,
    this.matExtraBarcode,
  });

  // Factory constructor to create an instance from JSON
  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['docId']?.toString(),
      matCode: json['MatCode'],
      matName: json['MatName']?.toString(),
      matBarCode: json['MatBarCode']?.toString(),
      matGroupGuid: json['MatGroupGuid']?.toString(),
      matUnity: json['MatUnity']?.toString(),
      matPriceType: json['MatPriceType'],
      matBonus: json['MatBonus'],
      matBonusOne: json['MatBonusOne'],
      matCurrencyGuid: json['MatCurrencyGuid']?.toString(),
      matCurrencyVal: json['MatCurrencyVal']?.toDouble(),
      matPictureGuid: json['MatPictureGuid']?.toString(),
      matType: json['MatType'],
      matSecurity: json['MatSecurity'],
      matFlag: json['MatFlag'],
      matExpireFlag: json['MatExpireFlag'],
      matProdFlag: json['MatProdFlag'],
      matUnit2FactFlag: json['MatUnit2FactFlag'],
      matUnit3FactFlag: json['MatUnit3FactFlag'],
      matSNFlag: json['MatSNFlag'],
      matForceInSN: json['MatForceInSN'],
      matForceOutSN: json['MatForceOutSN'],
      matVAT: json['MatVAT'],
      matDefUnit: json['MatDefUnit'],
      matBranchMask: json['MatBranchMask'],
      matAss: json['MatAss'],
      matOldGUID: json['MatOldGUID']?.toString(),
      matNewGUID: json['MatNewGUID']?.toString(),
      matCalPriceFromDetail: json['MatCalPriceFromDetail'],
      matForceInExpire: json['MatForceInExpire'],
      matForceOutExpire: json['MatForceOutExpire'],
      matCreateDate: DateTime.tryParse(json['MatCreateDate'] ?? '') ?? DateTime.now(),
      matIsIntegerQuantity: json['MatIsIntegerQuantity'],
      matClassFlag: json['MatClassFlag'],
      matForceInClass: json['MatForceInClass'],
      matForceOutClass: json['MatForceOutClass'],
      matDisableLastPrice: json['MatDisableLastPrice'],
      matLastPriceCurVal: double.tryParse(json['MatLastPriceCurVal'].toString()) ?? 0.0,
      matPrevQty: json['MatPrevQty']?.toString(),
      matFirstCostDate: DateTime.now().copyWith(year: 1980, day: 1, month: 1, minute: 0, hour: 0, second: 0),
      matHasSegments: json['MatHasSegments'],
      matParent: json['MatParent']?.toString(),
      matIsCompositionUpdated: json['MatIsCompositionUpdated'],
      matInheritsParentSpecs: json['MatInheritsParentSpecs'],
      matCompositionName: json['MatCompositionName']?.toString(),
      matCompositionLatinName: json['MatCompositionLatinName']?.toString(),
      movedComposite: json['MovedComposite'],
      wholesalePrice: json['Whole2']?.toString(),
      retailPrice: json['retail2']?.toString(),
      endUserPrice: json['EndUser2']?.toString(),
      matVatGuid: json['matVatGuid']?.toString(),
      matExtraBarcode: List.from(json['matExtraBarcode'] ?? []),
    );
  }

  // toJson method
  Map<String, dynamic> toJson() => {
        'docId': id,
        'MatCode': matCode,
        'MatName': matName,
        'MatBarCode': matBarCode,
        'MatGroupGuid': matGroupGuid,
        'MatUnity': matUnity,
        'MatPriceType': matPriceType,
        'MatBonus': matBonus,
        'MatBonusOne': matBonusOne,
        'MatCurrencyGuid': matCurrencyGuid,
        'MatCurrencyVal': matCurrencyVal,
        'MatPictureGuid': matPictureGuid,
        'MatType': matType,
        'MatSecurity': matSecurity,
        'MatFlag': matFlag,
        'MatExpireFlag': matExpireFlag,
        'MatProdFlag': matProdFlag,
        'MatUnit2FactFlag': matUnit2FactFlag,
        'MatUnit3FactFlag': matUnit3FactFlag,
        'MatSNFlag': matSNFlag,
        'MatForceInSN': matForceInSN,
        'MatForceOutSN': matForceOutSN,
        'MatVAT': matVAT,
        'MatDefUnit': matDefUnit,
        'MatBranchMask': matBranchMask,
        'MatAss': matAss,
        'MatOldGUID': matOldGUID,
        'MatNewGUID': matNewGUID,
        'MatCalPriceFromDetail': matCalPriceFromDetail,
        'MatForceInExpire': matForceInExpire,
        'MatForceOutExpire': matForceOutExpire,
        'MatCreateDate': matCreateDate?.toIso8601String(),
        'MatIsIntegerQuantity': matIsIntegerQuantity,
        'MatClassFlag': matClassFlag,
        'MatForceInClass': matForceInClass,
        'MatForceOutClass': matForceOutClass,
        'MatDisableLastPrice': matDisableLastPrice,
        'MatLastPriceCurVal': matLastPriceCurVal,
        'MatPrevQty': matPrevQty,
        'MatFirstCostDate': matFirstCostDate?.toIso8601String(),
        'MatHasSegments': matHasSegments,
        'MatParent': matParent,
        'MatIsCompositionUpdated': matIsCompositionUpdated,
        'MatInheritsParentSpecs': matInheritsParentSpecs,
        'MatCompositionName': matCompositionName,
        'MatCompositionLatinName': matCompositionLatinName,
        'MovedComposite': movedComposite,
        'Whole2': wholesalePrice,
        'retail2': retailPrice,
        'EndUser2': endUserPrice,
        'matVatGuid': matVatGuid,
        'matExtraBarcode': matExtraBarcode,
      };

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    return {
      PlutoColumn(title: 'الرقم التعريفي', field: 'الرقم التعريفي', type: PlutoColumnType.text()): id,
      PlutoColumn(title: 'اسم المادة', field: 'اسم المادة', type: PlutoColumnType.text()): matName,
      PlutoColumn(title: 'رمز المادة', field: 'رمز المادة', type: PlutoColumnType.text()): matCode,
      PlutoColumn(title: 'الباركود', field: 'الباركود', type: PlutoColumnType.text()): matBarCode,
    };
  }

  // CopyWith method
  MaterialModel copyWith({
    String? id,
    int? matCode,
    String? matName,
    String? matBarCode,
    String? matGroupGuid,
    String? matUnity,
    int? matPriceType,
    int? matBonus,
    int? matBonusOne,
    String? matCurrencyGuid,
    double? matCurrencyVal,
    String? matPictureGuid,
    int? matType,
    int? matSecurity,
    int? matFlag,
    int? matExpireFlag,
    int? matProdFlag,
    int? matUnit2FactFlag,
    int? matUnit3FactFlag,
    int? matSNFlag,
    int? matForceInSN,
    int? matForceOutSN,
    int? matVAT,
    int? matDefUnit,
    int? matBranchMask,
    int? matAss,
    String? matOldGUID,
    String? matNewGUID,
    int? matCalPriceFromDetail,
    int? matForceInExpire,
    int? matForceOutExpire,
    DateTime? matCreateDate,
    int? matIsIntegerQuantity,
    int? matClassFlag,
    int? matForceInClass,
    int? matForceOutClass,
    int? matDisableLastPrice,
    double? matLastPriceCurVal,
    String? matPrevQty,
    DateTime? matFirstCostDate,
    int? matHasSegments,
    String? matParent,
    int? matIsCompositionUpdated,
    int? matInheritsParentSpecs,
    String? matCompositionName,
    String? matCompositionLatinName,
    int? movedComposite,
    String? wholesalePrice,
    String? retailPrice,
    String? endUserPrice,
    String? matVatGuid,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      matCode: matCode ?? this.matCode,
      matName: matName ?? this.matName,
      matBarCode: matBarCode ?? this.matBarCode,
      matGroupGuid: matGroupGuid ?? this.matGroupGuid,
      matUnity: matUnity ?? this.matUnity,
      matPriceType: matPriceType ?? this.matPriceType,
      matBonus: matBonus ?? this.matBonus,
      matBonusOne: matBonusOne ?? this.matBonusOne,
      matCurrencyGuid: matCurrencyGuid ?? this.matCurrencyGuid,
      matCurrencyVal: matCurrencyVal ?? this.matCurrencyVal,
      matPictureGuid: matPictureGuid ?? this.matPictureGuid,
      matType: matType ?? this.matType,
      matSecurity: matSecurity ?? this.matSecurity,
      matFlag: matFlag ?? this.matFlag,
      matExpireFlag: matExpireFlag ?? this.matExpireFlag,
      matProdFlag: matProdFlag ?? this.matProdFlag,
      matUnit2FactFlag: matUnit2FactFlag ?? this.matUnit2FactFlag,
      matUnit3FactFlag: matUnit3FactFlag ?? this.matUnit3FactFlag,
      matSNFlag: matSNFlag ?? this.matSNFlag,
      matForceInSN: matForceInSN ?? this.matForceInSN,
      matForceOutSN: matForceOutSN ?? this.matForceOutSN,
      matVAT: matVAT ?? this.matVAT,
      matDefUnit: matDefUnit ?? this.matDefUnit,
      matBranchMask: matBranchMask ?? this.matBranchMask,
      matAss: matAss ?? this.matAss,
      matOldGUID: matOldGUID ?? this.matOldGUID,
      matNewGUID: matNewGUID ?? this.matNewGUID,
      matCalPriceFromDetail: matCalPriceFromDetail ?? this.matCalPriceFromDetail,
      matForceInExpire: matForceInExpire ?? this.matForceInExpire,
      matForceOutExpire: matForceOutExpire ?? this.matForceOutExpire,
      matCreateDate: matCreateDate ?? this.matCreateDate,
      matIsIntegerQuantity: matIsIntegerQuantity ?? this.matIsIntegerQuantity,
      matClassFlag: matClassFlag ?? this.matClassFlag,
      matForceInClass: matForceInClass ?? this.matForceInClass,
      matForceOutClass: matForceOutClass ?? this.matForceOutClass,
      matDisableLastPrice: matDisableLastPrice ?? this.matDisableLastPrice,
      matLastPriceCurVal: matLastPriceCurVal ?? this.matLastPriceCurVal,
      matPrevQty: matPrevQty ?? this.matPrevQty,
      matFirstCostDate: matFirstCostDate ?? this.matFirstCostDate,
      matHasSegments: matHasSegments ?? this.matHasSegments,
      matParent: matParent ?? this.matParent,
      matIsCompositionUpdated: matIsCompositionUpdated ?? this.matIsCompositionUpdated,
      matInheritsParentSpecs: matInheritsParentSpecs ?? this.matInheritsParentSpecs,
      matCompositionName: matCompositionName ?? this.matCompositionName,
      matCompositionLatinName: matCompositionLatinName ?? this.matCompositionLatinName,
      movedComposite: movedComposite ?? this.movedComposite,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      retailPrice: retailPrice ?? this.retailPrice,
      endUserPrice: endUserPrice ?? this.endUserPrice,
      matVatGuid: matVatGuid ?? this.matVatGuid,
    );
  }
}

@HiveType(typeId: 1)
class MatExtraBarcodeModel {
  @HiveField(0)
  final String? barcode;

  @HiveField(1)
  final String? description;

  MatExtraBarcodeModel({
    this.barcode,
    this.description,
  });

  factory MatExtraBarcodeModel.fromJson(Map<String, dynamic> json) {
    return MatExtraBarcodeModel(
      barcode: json['barcode']?.toString(),
      description: json['description']?.toString(),
    );
  }
}
