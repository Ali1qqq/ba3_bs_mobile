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
    final itemList = invoiceRecords.map((invoiceRecord) {
      return BillItem(
        itemGuid: invoiceRecord.invRecId!,
        itemName: invoiceRecord.invRecProduct!,
        itemQuantity: invoiceRecord.invRecQuantity!,
        itemTotalPrice: invoiceRecord.invRecTotal.toString(),
        itemSubTotalPrice: invoiceRecord.invRecSubTotal,
        itemVatPrice: invoiceRecord.invRecVat,
        itemGiftsPrice: invoiceRecord.invRecGiftTotal,
        itemGiftsNumber: invoiceRecord.invRecGift,
      );
    }).toList();

    return BillItems(itemList: itemList);
  }

  Map<String, dynamic> toJson() => {
        'Item': itemList.map((item) => item.toJson()).toList(),
      };

  BillItems copyWith({List<BillItem>? itemList}) => BillItems(
        itemList: itemList ?? this.itemList,
      );

  List<InvoiceRecordModel> get getMaterialRecords {
    if (itemList.isEmpty) {
      return [];
    } else {
      return _materialRecords;
    }
  }

  List<InvoiceRecordModel> get _materialRecords =>
      itemList.map((item) => InvoiceRecordModel.fromBillItem(item)).toList();

  @override
  List<Object?> get props => [itemList];

}

class BillItem  extends Equatable{
  final String itemGuid;
  final String itemName;
  final int itemQuantity;
  final String itemTotalPrice;
  final double? itemSubTotalPrice;
  final double? itemVatPrice;
  final int? itemGiftsNumber;
  final double? itemGiftsPrice;

  const BillItem({
    required this.itemGuid,
    required this.itemName,
    required this.itemQuantity,
    required this.itemTotalPrice,
    this.itemSubTotalPrice,
    this.itemVatPrice,
    this.itemGiftsNumber,
    this.itemGiftsPrice,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        itemGuid: json['ItemGuid'],
        itemName: json['ItemName'],
        itemQuantity: json['ItemQuantity'],
        itemTotalPrice: json['itemTotalPrice'],
        itemSubTotalPrice: json['itemSubTotalPrice'],
        itemVatPrice: json['itemVatPrice'],
        itemGiftsNumber: json['itemGiftsNumber'],
        itemGiftsPrice: json['itemGiftsPrice'],
      );

  Map<String, dynamic> toJson() => {
        'ItemGuid': itemGuid,
        'ItemName': itemName,
        'ItemQuantity': itemQuantity,
        'itemTotalPrice': itemTotalPrice,
        'itemSubTotalPrice': itemSubTotalPrice,
        'itemVatPrice': itemVatPrice,
        'itemGiftsNumber': itemGiftsNumber,
        'itemGiftsPrice': itemGiftsPrice,
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
      );
  @override
  List<Object?> get props => [
    itemGuid,
    itemName,
    itemQuantity,
    itemTotalPrice,
    itemSubTotalPrice,
    itemVatPrice,
    itemGiftsNumber,
    itemGiftsPrice,
  ];

}
