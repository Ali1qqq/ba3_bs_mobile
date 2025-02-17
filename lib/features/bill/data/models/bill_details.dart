import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class _CopyWithSentinel {}

class BillDetails with EquatableMixin {
  final String? billGuid;
  final int? billPayType;
  final int? billNumber;

  /// The number of the previous bill
  final int? previous;

  /// The number of the next bill
  final int? next;
  final DateTime? billDate;
  final String? billNote;
  final String? billSellerId;
  final String? billCustomerId;
  final double? billTotal;
  final double? billVatTotal;
  final double? billBeforeVatTotal;
  final double? billGiftsTotal;
  final double? billDiscountsTotal;
  final double? billAdditionsTotal;
  final double? billFirstPay;

  BillDetails({
    this.billGuid,
    this.billPayType,
    this.billNumber,
    this.previous,
    this.next,
    this.billDate,
    this.billNote,
    this.billCustomerId,
    this.billTotal,
    this.billVatTotal,
    this.billBeforeVatTotal,
    this.billSellerId,
    this.billGiftsTotal,
    this.billDiscountsTotal,
    this.billAdditionsTotal,
    this.billFirstPay,
  });

  factory BillDetails.fromJson(Map<String, dynamic> json) => BillDetails(
        billGuid: json['billGuid'],
        billPayType: json['billPayType'],
        billNumber: json['billNumber'],
        previous: json['previous'],
        next: json['next'],
        billDate: (json['billDate'] as Timestamp).toDate(),
        billNote: json['billNote'],
        billCustomerId: json['billCustomerId'],
        billSellerId: json['billSellerId'],
        billTotal: json['billTotal'],
        billVatTotal: json['billVatTotal'],
        billBeforeVatTotal: json['billWithoutVatTotal'],
        billGiftsTotal: json['billGiftsTotal'],
        billDiscountsTotal: json['billDiscountsTotal'],
        billAdditionsTotal: json['billAdditionsTotal'],
        billFirstPay: json['billFirstPay'],
      );

  factory BillDetails.fromBillData({
    BillDetails? existingDetails,
    String? billNote,
    required String billCustomerId,
    required String billSellerId,
    required int billPayType,
    required DateTime billDate,
    required double billTotal,
    required double billVatTotal,
    required double billWithoutVatTotal,
    required double billGiftsTotal,
    required double billDiscountsTotal,
    required double billAdditionsTotal,
    required double billFirstPay,
  }) =>
      BillDetails(
        billGuid: existingDetails?.billGuid,
        billNumber: existingDetails?.billNumber,
        previous: existingDetails?.previous,
        next: existingDetails?.next,
        billNote: billNote,
        billFirstPay: billFirstPay,
        billCustomerId: billCustomerId,
        billSellerId: billSellerId,
        billPayType: billPayType,
        billDate: billDate,
        billTotal: billTotal,
        billVatTotal: billVatTotal,
        billBeforeVatTotal: billWithoutVatTotal,
        billGiftsTotal: billGiftsTotal,
        billDiscountsTotal: billDiscountsTotal,
        billAdditionsTotal: billAdditionsTotal,
      );

  Map<String, dynamic> toJson() => {
        'billGuid': billGuid,
        'billPayType': billPayType,
        'billNumber': billNumber,
        'previous': previous,
        'next': next,
        'billDate': Timestamp.fromDate(billDate!),
        'billNote': billNote,
        'billCustomerId': billCustomerId,
        'billTotal': billTotal,
        'billWithoutVatTotal': billBeforeVatTotal,
        'billVatTotal': billVatTotal,
        'billSellerId': billSellerId,
        'billGiftsTotal': billGiftsTotal,
        'billDiscountsTotal': billDiscountsTotal,
        'billAdditionsTotal': billAdditionsTotal,
        'billFirstPay': billFirstPay,
      };

  // The magic: each field is an Object? that defaults to _CopyWithSentinel,
  // so we know whether the user passed a new value, or not.
  BillDetails copyWith({
    Object? billGuid = _CopyWithSentinel,
    Object? billPayType = _CopyWithSentinel,
    Object? billNumber = _CopyWithSentinel,
    Object? previous = _CopyWithSentinel,
    Object? next = _CopyWithSentinel,
    Object? billDate = _CopyWithSentinel,
    Object? billNote = _CopyWithSentinel,
    Object? billSellerId = _CopyWithSentinel,
    Object? billCustomerId = _CopyWithSentinel,
    Object? billTotal = _CopyWithSentinel,
    Object? billVatTotal = _CopyWithSentinel,
    Object? billBeforeVatTotal = _CopyWithSentinel,
    Object? billGiftsTotal = _CopyWithSentinel,
    Object? billDiscountsTotal = _CopyWithSentinel,
    Object? billAdditionsTotal = _CopyWithSentinel,
    Object? billFirstPay = _CopyWithSentinel,
  }) {
    return BillDetails(
      billGuid: billGuid == _CopyWithSentinel ? this.billGuid : billGuid as String?,
      billPayType: billPayType == _CopyWithSentinel ? this.billPayType : billPayType as int?,
      billNumber: billNumber == _CopyWithSentinel ? this.billNumber : billNumber as int?,
      previous: previous == _CopyWithSentinel ? this.previous : previous as int?,
      next: next == _CopyWithSentinel ? this.next : next as int?,
      // Now if next is passed as null, it will become null
      billDate: billDate == _CopyWithSentinel ? this.billDate : billDate as DateTime?,
      billNote: billNote == _CopyWithSentinel ? this.billNote : billNote as String?,
      billSellerId: billSellerId == _CopyWithSentinel ? this.billSellerId : billSellerId as String?,
      billCustomerId: billCustomerId == _CopyWithSentinel ? this.billCustomerId : billCustomerId as String?,
      billTotal: billTotal == _CopyWithSentinel ? this.billTotal : billTotal as double?,
      billVatTotal: billVatTotal == _CopyWithSentinel ? this.billVatTotal : billVatTotal as double?,
      billBeforeVatTotal: billBeforeVatTotal == _CopyWithSentinel ? this.billBeforeVatTotal : billBeforeVatTotal as double?,
      billGiftsTotal: billGiftsTotal == _CopyWithSentinel ? this.billGiftsTotal : billGiftsTotal as double?,
      billDiscountsTotal: billDiscountsTotal == _CopyWithSentinel ? this.billDiscountsTotal : billDiscountsTotal as double?,
      billAdditionsTotal: billAdditionsTotal == _CopyWithSentinel ? this.billAdditionsTotal : billAdditionsTotal as double?,
      billFirstPay: billFirstPay == _CopyWithSentinel ? this.billFirstPay : billFirstPay as double?,
    );
  }

  @override
  List<Object?> get props => [
        billGuid,
        billPayType,
        billNumber,
        previous,
        next,
        billDate,
        billNote,
        billCustomerId,
        billSellerId,
        billTotal,
        billVatTotal,
        billBeforeVatTotal,
        billGiftsTotal,
        billDiscountsTotal,
        billAdditionsTotal,
        billFirstPay,
      ];
}