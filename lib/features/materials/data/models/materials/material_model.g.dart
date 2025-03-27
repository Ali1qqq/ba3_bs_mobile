// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialModelAdapter extends TypeAdapter<MaterialModel> {
  @override
  final int typeId = 0;

  @override
  MaterialModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialModel(
      id: fields[0] as String?,
      matLocalQuantity: fields[55] as int?,
      matFreeQuantity: fields[56] as int?,
      matCode: fields[1] as int?,
      matName: fields[2] as String?,
      matBarCode: fields[3] as String?,
      matGroupGuid: fields[4] as String?,
      matUnity: fields[5] as String?,
      matPriceType: fields[6] as int?,
      matBonus: fields[7] as int?,
      matBonusOne: fields[8] as int?,
      matCurrencyGuid: fields[9] as String?,
      matCurrencyVal: fields[10] as double?,
      matPictureGuid: fields[11] as String?,
      matType: fields[12] as int?,
      matSecurity: fields[13] as int?,
      matFlag: fields[14] as int?,
      matExpireFlag: fields[15] as int?,
      matProdFlag: fields[16] as int?,
      matUnit2FactFlag: fields[17] as int?,
      matUnit3FactFlag: fields[18] as int?,
      matSNFlag: fields[19] as int?,
      matForceInSN: fields[20] as int?,
      matForceOutSN: fields[21] as int?,
      matVAT: fields[22] as int?,
      matDefUnit: fields[23] as int?,
      matBranchMask: fields[24] as int?,
      matAss: fields[25] as int?,
      matOldGUID: fields[26] as String?,
      matNewGUID: fields[27] as String?,
      matCalPriceFromDetail: fields[28] as int?,
      matForceInExpire: fields[29] as int?,
      matForceOutExpire: fields[30] as int?,
      matCreateDate: fields[31] as DateTime?,
      matIsIntegerQuantity: fields[32] as int?,
      matClassFlag: fields[33] as int?,
      matForceInClass: fields[34] as int?,
      matForceOutClass: fields[35] as int?,
      matDisableLastPrice: fields[36] as int?,
      matLastPriceCurVal: fields[37] as double?,
      matPrevQty: fields[38] as String?,
      matFirstCostDate: fields[39] as DateTime?,
      matHasSegments: fields[40] as int?,
      matParent: fields[41] as String?,
      matIsCompositionUpdated: fields[42] as int?,
      matInheritsParentSpecs: fields[43] as int?,
      matCompositionName: fields[44] as String?,
      matCompositionLatinName: fields[45] as String?,
      movedComposite: fields[46] as int?,
      wholesalePrice: fields[47] as String?,
      retailPrice: fields[48] as String?,
      endUserPrice: fields[49] as String?,
      matVatGuid: fields[50] as String?,
      matExtraBarcode: (fields[51] as List?)?.cast<MatExtraBarcodeModel>(),
      matQuantity: fields[52] as int?,
      calcMinPrice: fields[53] as double?,
      serialNumbers: (fields[54] as Map?)?.cast<String, bool>(),
    );
  }

  @override
  void write(BinaryWriter writer, MaterialModel obj) {
    writer
      ..writeByte(57)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.matCode)
      ..writeByte(2)
      ..write(obj.matName)
      ..writeByte(3)
      ..write(obj.matBarCode)
      ..writeByte(4)
      ..write(obj.matGroupGuid)
      ..writeByte(5)
      ..write(obj.matUnity)
      ..writeByte(6)
      ..write(obj.matPriceType)
      ..writeByte(7)
      ..write(obj.matBonus)
      ..writeByte(8)
      ..write(obj.matBonusOne)
      ..writeByte(9)
      ..write(obj.matCurrencyGuid)
      ..writeByte(10)
      ..write(obj.matCurrencyVal)
      ..writeByte(11)
      ..write(obj.matPictureGuid)
      ..writeByte(12)
      ..write(obj.matType)
      ..writeByte(13)
      ..write(obj.matSecurity)
      ..writeByte(14)
      ..write(obj.matFlag)
      ..writeByte(15)
      ..write(obj.matExpireFlag)
      ..writeByte(16)
      ..write(obj.matProdFlag)
      ..writeByte(17)
      ..write(obj.matUnit2FactFlag)
      ..writeByte(18)
      ..write(obj.matUnit3FactFlag)
      ..writeByte(19)
      ..write(obj.matSNFlag)
      ..writeByte(20)
      ..write(obj.matForceInSN)
      ..writeByte(21)
      ..write(obj.matForceOutSN)
      ..writeByte(22)
      ..write(obj.matVAT)
      ..writeByte(23)
      ..write(obj.matDefUnit)
      ..writeByte(24)
      ..write(obj.matBranchMask)
      ..writeByte(25)
      ..write(obj.matAss)
      ..writeByte(26)
      ..write(obj.matOldGUID)
      ..writeByte(27)
      ..write(obj.matNewGUID)
      ..writeByte(28)
      ..write(obj.matCalPriceFromDetail)
      ..writeByte(29)
      ..write(obj.matForceInExpire)
      ..writeByte(30)
      ..write(obj.matForceOutExpire)
      ..writeByte(31)
      ..write(obj.matCreateDate)
      ..writeByte(32)
      ..write(obj.matIsIntegerQuantity)
      ..writeByte(33)
      ..write(obj.matClassFlag)
      ..writeByte(34)
      ..write(obj.matForceInClass)
      ..writeByte(35)
      ..write(obj.matForceOutClass)
      ..writeByte(36)
      ..write(obj.matDisableLastPrice)
      ..writeByte(37)
      ..write(obj.matLastPriceCurVal)
      ..writeByte(38)
      ..write(obj.matPrevQty)
      ..writeByte(39)
      ..write(obj.matFirstCostDate)
      ..writeByte(40)
      ..write(obj.matHasSegments)
      ..writeByte(41)
      ..write(obj.matParent)
      ..writeByte(42)
      ..write(obj.matIsCompositionUpdated)
      ..writeByte(43)
      ..write(obj.matInheritsParentSpecs)
      ..writeByte(44)
      ..write(obj.matCompositionName)
      ..writeByte(45)
      ..write(obj.matCompositionLatinName)
      ..writeByte(46)
      ..write(obj.movedComposite)
      ..writeByte(47)
      ..write(obj.wholesalePrice)
      ..writeByte(48)
      ..write(obj.retailPrice)
      ..writeByte(49)
      ..write(obj.endUserPrice)
      ..writeByte(50)
      ..write(obj.matVatGuid)
      ..writeByte(51)
      ..write(obj.matExtraBarcode)
      ..writeByte(52)
      ..write(obj.matQuantity)
      ..writeByte(53)
      ..write(obj.calcMinPrice)
      ..writeByte(54)
      ..write(obj.serialNumbers)
      ..writeByte(55)
      ..write(obj.matLocalQuantity)
      ..writeByte(56)
      ..write(obj.matFreeQuantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MatExtraBarcodeModelAdapter extends TypeAdapter<MatExtraBarcodeModel> {
  @override
  final int typeId = 1;

  @override
  MatExtraBarcodeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatExtraBarcodeModel(
      barcode: fields[0] as String?,
      description: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MatExtraBarcodeModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.barcode)
      ..writeByte(1)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatExtraBarcodeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
