// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dash_account_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DashAccountModelAdapter extends TypeAdapter<DashAccountModel> {
  @override
  final int typeId = 2;

  @override
  DashAccountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DashAccountModel(
      id: fields[0] as String?,
      name: fields[1] as String?,
      balance: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DashAccountModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.balance);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashAccountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
