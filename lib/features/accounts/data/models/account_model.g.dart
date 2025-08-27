// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountModelAdapter extends TypeAdapter<AccountModel> {
  @override
  final int typeId = 10;

  @override
  AccountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountModel(
      id: fields[0] as String?,
      accName: fields[1] as String?,
      accLatinName: fields[2] as String?,
      accCode: fields[3] as String?,
      accCDate: fields[4] as DateTime?,
      accCheckDate: fields[5] as DateTime?,
      accParentGuid: fields[6] as String?,
      accFinalGuid: fields[8] as String?,
      accAccNSons: fields[9] as int?,
      accInitDebit: fields[10] as double?,
      accInitCredit: fields[11] as double?,
      maxDebit: fields[12] as double?,
      accWarn: fields[13] as int?,
      note: fields[14] as String?,
      accCurVal: fields[15] as int?,
      accCurGuid: fields[16] as String?,
      accSecurity: fields[17] as int?,
      accDebitOrCredit: fields[18] as int?,
      accType: fields[19] as int?,
      accState: fields[20] as int?,
      accIsChangableRatio: fields[21] as int?,
      accBranchGuid: fields[22] as String?,
      accNumber: fields[23] as int?,
      accBranchMask: fields[24] as int?,
      accParentName: fields[7] as String?,
      accCustomer: (fields[25] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AccountModel obj) {
    writer
      ..writeByte(26)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.accName)
      ..writeByte(2)
      ..write(obj.accLatinName)
      ..writeByte(3)
      ..write(obj.accCode)
      ..writeByte(4)
      ..write(obj.accCDate)
      ..writeByte(5)
      ..write(obj.accCheckDate)
      ..writeByte(6)
      ..write(obj.accParentGuid)
      ..writeByte(7)
      ..write(obj.accParentName)
      ..writeByte(8)
      ..write(obj.accFinalGuid)
      ..writeByte(9)
      ..write(obj.accAccNSons)
      ..writeByte(10)
      ..write(obj.accInitDebit)
      ..writeByte(11)
      ..write(obj.accInitCredit)
      ..writeByte(12)
      ..write(obj.maxDebit)
      ..writeByte(13)
      ..write(obj.accWarn)
      ..writeByte(14)
      ..write(obj.note)
      ..writeByte(15)
      ..write(obj.accCurVal)
      ..writeByte(16)
      ..write(obj.accCurGuid)
      ..writeByte(17)
      ..write(obj.accSecurity)
      ..writeByte(18)
      ..write(obj.accDebitOrCredit)
      ..writeByte(19)
      ..write(obj.accType)
      ..writeByte(20)
      ..write(obj.accState)
      ..writeByte(21)
      ..write(obj.accIsChangableRatio)
      ..writeByte(22)
      ..write(obj.accBranchGuid)
      ..writeByte(23)
      ..write(obj.accNumber)
      ..writeByte(24)
      ..write(obj.accBranchMask)
      ..writeByte(25)
      ..write(obj.accCustomer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
