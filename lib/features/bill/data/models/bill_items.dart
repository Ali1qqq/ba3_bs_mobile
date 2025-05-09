import 'package:equatable/equatable.dart';

import 'invoice_record_model.dart';

class BillItems extends Equatable {
  final List<BillItem> itemList;

  const BillItems({required this.itemList});

  factory BillItems.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['Item'] as List<dynamic>;
    List<BillItem> itemList = itemsJson.map((item) => BillItem.fromJson(item)).toList();
    return BillItems(itemList: itemList);
  }

  factory BillItems.fromBillRecords(List<InvoiceRecordModel> invoiceRecords) {
    final itemList = invoiceRecords.map(
          (invoiceRecord) {
        return BillItem(
          itemGuid: invoiceRecord.invRecId!,
          itemName: invoiceRecord.invRecProduct!,
          itemQuantity: invoiceRecord.invRecQuantity!,
          itemTotalPrice: invoiceRecord.invRecTotal.toString(),
          itemSubTotalPrice: invoiceRecord.invRecSubTotal,
          itemVatPrice: invoiceRecord.invRecVat,
          itemGiftsPrice: invoiceRecord.invRecGiftTotal,
          itemGiftsNumber: invoiceRecord.invRecGift,
          soldSerialNumber: invoiceRecord.invRecProductSoldSerial,
          itemSerialNumbers: invoiceRecord.invRecProductSerialNumbers,
        );
      },
    ).toList();

    return BillItems(itemList: itemList);
  }

  Map<String, dynamic> toJson() =>
      {
        'Item': itemList.map((item) => item.toJson()).toList(),
      };

  BillItems copyWith({List<BillItem>? itemList}) =>
      BillItems(
        itemList: itemList ?? this.itemList,
      );

  List<InvoiceRecordModel> get getMaterialRecords {
    if (itemList.isEmpty) {
      return [];
    } else {
      return _materialRecords;
    }
  }

  List<InvoiceRecordModel> get _materialRecords => itemList.map((item) => InvoiceRecordModel.fromBillItem(item)).toList();

  @override
  List<Object?> get props => [itemList];
}

class BillItem extends Equatable {
  final String itemGuid;
  final String? itemName;
  final int itemQuantity;
  final String itemTotalPrice;
  final double? itemSubTotalPrice;
  final double? itemVatPrice;
  final int? itemGiftsNumber;
  final double? itemGiftsPrice;

  final String? soldSerialNumber;
  final List<String>? itemSerialNumbers;

  const BillItem({
    required this.itemGuid,
    this.itemName,
    required this.itemQuantity,
    required this.itemTotalPrice,
    this.itemSubTotalPrice,
    this.itemVatPrice,
    this.itemGiftsNumber,
    this.itemGiftsPrice,
    this.soldSerialNumber,
    this.itemSerialNumbers,
  });

  factory BillItem.fromBillRecord(InvoiceRecordModel invoiceRecord) {
    return BillItem(
      itemGuid: invoiceRecord.invRecId!,
      itemName: invoiceRecord.invRecProduct!,
      itemQuantity: invoiceRecord.invRecQuantity!,
      itemTotalPrice: invoiceRecord.invRecTotal.toString(),
      itemSubTotalPrice: invoiceRecord.invRecSubTotal,
      itemVatPrice: invoiceRecord.invRecVat,
      itemGiftsPrice: invoiceRecord.invRecGiftTotal,
      itemGiftsNumber: invoiceRecord.invRecGift,
      soldSerialNumber: invoiceRecord.invRecProductSoldSerial,
      itemSerialNumbers: invoiceRecord.invRecProductSerialNumbers,
    );
  }

  factory BillItem.fromJson(Map<String, dynamic> json) =>
      BillItem(
        itemGuid: json['ItemGuid'],
        itemName: json['ItemName'],
        itemQuantity: json['ItemQuantity'],
        itemTotalPrice: json['itemTotalPrice'],
        itemSubTotalPrice: json['itemSubTotalPrice'],
        itemVatPrice: json['itemVatPrice'],
        itemGiftsNumber: json['itemGiftsNumber'],
        itemGiftsPrice: json['itemGiftsPrice'],
        soldSerialNumber: json.containsKey('soldSerialNumber') ? json['soldSerialNumber'] as String? : null,
        itemSerialNumbers: (json['itemSerialNumbers'] is List) ? List<String>.from(json['itemSerialNumbers'] as List) : null,
      );

  Map<String, dynamic> toJson() =>
      {
        'ItemGuid': itemGuid,
        if (itemName != null) 'ItemName': itemName,
        'ItemQuantity': itemQuantity,
        'itemTotalPrice': itemTotalPrice,
        if (itemSubTotalPrice != null) 'itemSubTotalPrice': itemSubTotalPrice,
        if (itemVatPrice != null) 'itemVatPrice': itemVatPrice,
        if (itemGiftsNumber != null) 'itemGiftsNumber': itemGiftsNumber,
        if (itemGiftsPrice != null) 'itemGiftsPrice': itemGiftsPrice,
        if (soldSerialNumber != null && soldSerialNumber!.isNotEmpty) 'soldSerialNumber': soldSerialNumber,
        if (itemSerialNumbers != null && itemSerialNumbers!.isNotEmpty) 'itemSerialNumbers': itemSerialNumbers,
      };

  BillItem copyWith({
    final String? itemGuid,
    final String? itemName,
    final int? itemQuantity,
    final String? itemTotalPrice,
    final double? itemSubTotalPrice,
    final double? itemVatPrice,
    final int? itemGiftsNumber,
    final double? itemGiftsPrice,
    final String? soldSerialNumber,
    final List<String>? itemSerialNumbers,
  }) =>
      BillItem(
        itemGuid: itemGuid ?? this.itemGuid,
        itemName: itemName ?? this.itemName,
        itemQuantity: itemQuantity ?? this.itemQuantity,
        itemTotalPrice: itemTotalPrice ?? this.itemTotalPrice,
        itemSubTotalPrice: itemSubTotalPrice ?? this.itemSubTotalPrice,
        itemVatPrice: itemVatPrice ?? this.itemVatPrice,
        itemGiftsNumber: itemGiftsNumber ?? this.itemGiftsNumber,
        itemGiftsPrice: itemGiftsPrice ?? this.itemGiftsPrice,
        soldSerialNumber: soldSerialNumber ?? this.soldSerialNumber,
        itemSerialNumbers: itemSerialNumbers ?? this.itemSerialNumbers,
      );

  @override
  List<Object?> get props =>
      [
        itemGuid,
        itemName,
        itemQuantity,
        itemTotalPrice,
        itemSubTotalPrice,
        itemVatPrice,
        itemGiftsNumber,
        itemGiftsPrice,
        soldSerialNumber,
        itemSerialNumbers,
      ];
}
