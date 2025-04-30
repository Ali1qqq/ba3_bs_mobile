// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillPatternTypeAdapter extends TypeAdapter<BillPatternType> {
  @override
  final int typeId = 8;

  @override
  BillPatternType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillPatternType.purchase;
      case 1:
        return BillPatternType.sales;
      case 2:
        return BillPatternType.buyReturn;
      case 3:
        return BillPatternType.salesReturn;
      case 4:
        return BillPatternType.add;
      case 5:
        return BillPatternType.remove;
      case 6:
        return BillPatternType.firstPeriodInventory;
      case 7:
        return BillPatternType.transferOut;
      case 8:
        return BillPatternType.salesService;
      case 9:
        return BillPatternType.transferIn;
      default:
        return BillPatternType.purchase;
    }
  }

  @override
  void write(BinaryWriter writer, BillPatternType obj) {
    switch (obj) {
      case BillPatternType.purchase:
        writer.writeByte(0);
        break;
      case BillPatternType.sales:
        writer.writeByte(1);
        break;
      case BillPatternType.buyReturn:
        writer.writeByte(2);
        break;
      case BillPatternType.salesReturn:
        writer.writeByte(3);
        break;
      case BillPatternType.add:
        writer.writeByte(4);
        break;
      case BillPatternType.remove:
        writer.writeByte(5);
        break;
      case BillPatternType.firstPeriodInventory:
        writer.writeByte(6);
        break;
      case BillPatternType.transferOut:
        writer.writeByte(7);
        break;
      case BillPatternType.salesService:
        writer.writeByte(8);
        break;
      case BillPatternType.transferIn:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillPatternTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatusAdapter extends TypeAdapter<Status> {
  @override
  final int typeId = 9;

  @override
  Status read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Status.approved;
      case 1:
        return Status.canceled;
      case 2:
        return Status.pending;
      default:
        return Status.approved;
    }
  }

  @override
  void write(BinaryWriter writer, Status obj) {
    switch (obj) {
      case Status.approved:
        writer.writeByte(0);
        break;
      case Status.canceled:
        writer.writeByte(1);
        break;
      case Status.pending:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BondTypeAdapter extends TypeAdapter<BondType> {
  @override
  final int typeId = 16;

  @override
  BondType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BondType.openingEntry;
      case 1:
        return BondType.receiptVoucher;
      case 2:
        return BondType.paymentVoucher;
      case 3:
        return BondType.journalVoucher;
      default:
        return BondType.openingEntry;
    }
  }

  @override
  void write(BinaryWriter writer, BondType obj) {
    switch (obj) {
      case BondType.openingEntry:
        writer.writeByte(0);
        break;
      case BondType.receiptVoucher:
        writer.writeByte(1);
        break;
      case BondType.paymentVoucher:
        writer.writeByte(2);
        break;
      case BondType.journalVoucher:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BondTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillAccountsAdapter extends TypeAdapter<BillAccounts> {
  @override
  final int typeId = 12;

  @override
  BillAccounts read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillAccounts.materials;
      case 1:
        return BillAccounts.discounts;
      case 2:
        return BillAccounts.additions;
      case 3:
        return BillAccounts.caches;
      case 4:
        return BillAccounts.gifts;
      case 5:
        return BillAccounts.exchangeForGifts;
      case 6:
        return BillAccounts.store;
      default:
        return BillAccounts.materials;
    }
  }

  @override
  void write(BinaryWriter writer, BillAccounts obj) {
    switch (obj) {
      case BillAccounts.materials:
        writer.writeByte(0);
        break;
      case BillAccounts.discounts:
        writer.writeByte(1);
        break;
      case BillAccounts.additions:
        writer.writeByte(2);
        break;
      case BillAccounts.caches:
        writer.writeByte(3);
        break;
      case BillAccounts.gifts:
        writer.writeByte(4);
        break;
      case BillAccounts.exchangeForGifts:
        writer.writeByte(5);
        break;
      case BillAccounts.store:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillAccountsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
