import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:pluto_grid/pluto_grid.dart';

class MaterialModel implements PlutoAdaptable {
  final String? id;
  final int? matCode;
  final String? matName;
  final String? matBarCode;
  final String? matGroupGuid;
  final String? matUnity;
  final int? matPriceType;
  final int? matBonus;
  final int? matBonusOne;
  final String? matCurrencyGuid;
  final double? matCurrencyVal;
  final String? matPictureGuid;
  final int? matType;
  final int? matSecurity;
  final int? matFlag;
  final int? matExpireFlag;
  final int? matProdFlag;
  final int? matUnit2FactFlag;
  final int? matUnit3FactFlag;
  final int? matSNFlag;
  final int? matForceInSN;
  final int? matForceOutSN;
  final int? matVAT;
  final int? matDefUnit;
  final int? matBranchMask;
  final int? matAss;
  final String? matOldGUID;
  final String? matNewGUID;
  final int? matCalPriceFromDetail;
  final int? matForceInExpire;
  final int? matForceOutExpire;
  final DateTime? matCreateDate;
  final int? matIsIntegerQuantity;
  final int? matClassFlag;
  final int? matForceInClass;
  final int? matForceOutClass;
  final int? matDisableLastPrice;
  final double? matLastPriceCurVal;
  final String? matPrevQty;
  final DateTime? matFirstCostDate;
  final int? matHasSegments;
  final String? matParent;
  final int? matIsCompositionUpdated;
  final int? matInheritsParentSpecs;
  final String? matCompositionName;
  final String? matCompositionLatinName;
  final int? movedComposite;
  final String? wholesalePrice;
  final String? retailPrice;
  final String? endUserPrice;
  final String? matVatGuid;
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

class MatExtraBarcodeModel {
  double? matUnit;
  String? barCode;
  bool? isDefault;

  MatExtraBarcodeModel({this.matUnit, this.barCode, this.isDefault});

  // Convert a MatExtraBarcodeModel into a Map. The keys must correspond to the names of the JSON attributes.
  Map<String, dynamic> toJson() {
    return {
      'matUnit': matUnit,
      'barCode': barCode,
      'isDefault': isDefault,
    };
  }

  // A method that converts a Map into a MatExtraBarcodeModel.
  factory MatExtraBarcodeModel.fromJson(Map<String, dynamic> json) {
    return MatExtraBarcodeModel(
      matUnit: json['matUnit'],
      barCode: json['barCode'],
      isDefault: json['isDefault'],
    );
  }

  // A method that creates a copy of the MatExtraBarcodeModel with the given fields replaced with new values.
  MatExtraBarcodeModel copyWith({double? matUnit, String? barCode, bool? isDefault}) {
    return MatExtraBarcodeModel(
      matUnit: matUnit ?? this.matUnit,
      barCode: barCode ?? this.barCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
