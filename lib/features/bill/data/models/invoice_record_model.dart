import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../../core/utils/utils.dart';
import 'bill_items.dart';

class InvoiceRecordModel {
  String? invRecId;
  String? invRecProduct;
  String? prodChoosePriceMethod;
  int? invRecQuantity;
  int? invRecGift;
  double? invRecSubTotal;
  double? invRecTotal;
  double? invRecVat;
  double? invRecGiftTotal;
  bool? invRecIsLocal;
  String? invRecProductSoldSerial;
  List<String>? invRecProductSerialNumbers;

  InvoiceRecordModel({
    this.invRecId,
    this.invRecProduct,
    this.invRecQuantity,
    this.invRecSubTotal,
    this.invRecTotal,
    this.invRecVat,
    this.prodChoosePriceMethod,
    this.invRecIsLocal,
    this.invRecGift,
    this.invRecGiftTotal,
    this.invRecProductSoldSerial,
    this.invRecProductSerialNumbers,
  });

  /// Factory method to create an InvoiceRecordModel from a BillItem.
  factory InvoiceRecordModel.fromBillItem(BillItem billItem) => InvoiceRecordModel(
        invRecId: billItem.itemGuid,
        invRecProduct: billItem.itemName,
        invRecQuantity: billItem.itemQuantity,
        invRecSubTotal: billItem.itemSubTotalPrice,
        invRecTotal: double.tryParse(billItem.itemTotalPrice),
        invRecVat: billItem.itemVatPrice,
        invRecGift: billItem.itemGiftsNumber,
        invRecGiftTotal: billItem.itemGiftsPrice,
        invRecProductSoldSerial: billItem.soldSerialNumber,
        invRecProductSerialNumbers: billItem.itemSerialNumbers,
      );

  factory InvoiceRecordModel.fromJson(Map<dynamic, dynamic> map) => InvoiceRecordModel(
        invRecId: map[AppConstants.invRecId],
        invRecProduct: map[AppConstants.invRecProduct],
        invRecQuantity: int.tryParse(map[AppConstants.invRecQuantity].toString()),
        invRecSubTotal: double.tryParse(map[AppConstants.invRecSubTotal].toString()),
        invRecTotal: double.tryParse(map[AppConstants.invRecTotal].toString()),
        invRecVat: double.tryParse((map[AppConstants.invRecVat]).toString()),
        invRecIsLocal: map[AppConstants.invRecIsLocal],
        invRecGift: int.tryParse(map[AppConstants.invRecGift].toString()),
        invRecGiftTotal: (map[AppConstants.invRecGiftTotal] ?? 0) * 1.0,
      );

  Map<String, dynamic> toJson() => {
        AppConstants.invRecId: invRecId,
        AppConstants.invRecProduct: invRecProduct,
        AppConstants.invRecQuantity: invRecQuantity,
        AppConstants.invRecSubTotal: invRecSubTotal,
        AppConstants.invRecTotal: invRecTotal,
        AppConstants.invRecVat: invRecVat,
        AppConstants.invRecIsLocal: invRecIsLocal,
        AppConstants.invRecGift: invRecGift,
        AppConstants.invRecGiftTotal: invRecGiftTotal,
      };

  factory InvoiceRecordModel.fromJsonPluto(String matId, Map<dynamic, dynamic> map, double vatRatio) {
    final int quantity = _parseInteger(map[AppConstants.invRecQuantity]) ?? 1;
    final double total = _parseDouble(map[AppConstants.invRecTotal]) ?? 0;
    final subTotal = (total / (quantity * (1 + vatRatio)));
    final vat = subTotal * vatRatio;
    final int? giftsNumber = _parseInteger(map[AppConstants.invRecGift]);

    final String? prodName = map[AppConstants.invRecProduct];

    final String? productSoldSerial = map[AppConstants.invRecProductSoldSerial];
    final List<String>? productSerialNumbers = (map[AppConstants.invRecProductSerialNumbers] is List)
        ? List<String>.from(map[AppConstants.invRecProductSerialNumbers] as List)
        : null;

    // final double? subTotal = _parseDouble(map[AppConstants.invRecSubTotal]);
    // final double? vat = _parseDouble(map[AppConstants.invRecVat]);

    // Calculate gift total
    final double effectiveVat = vat;
    final double effectiveSubTotal = subTotal;

    final double? giftTotal = (giftsNumber != null) ? giftsNumber * (effectiveVat + effectiveSubTotal) : null;

    return InvoiceRecordModel(
      invRecId: matId,
      invRecProduct: prodName,
      invRecQuantity: quantity,
      invRecSubTotal: AppServiceUtils.toFixedDouble(subTotal),
      invRecTotal: total,
      invRecVat: AppServiceUtils.toFixedDouble(vat),
      invRecIsLocal: map[AppConstants.invRecIsLocal],
      invRecGift: giftsNumber,
      invRecGiftTotal: giftTotal,
      invRecProductSoldSerial: productSoldSerial,
      invRecProductSerialNumbers: productSerialNumbers,
    );
  }

  // Helper method to parse integers, handling Arabic numerals
  static int? _parseInteger(dynamic value) {
    if (value == null) return null;
    return int.tryParse(AppServiceUtils.replaceArabicNumbersWithEnglish(value.toString()));
  }

  // Helper method to parse doubles, handling Arabic numerals
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(AppServiceUtils.replaceArabicNumbersWithEnglish(value.toString()));
  }

  @override
  int get hashCode => invRecId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is InvoiceRecordModel && runtimeType == other.runtimeType && invRecId == other.invRecId;

  Map<String, Map<String, dynamic>> getChanges(InvoiceRecordModel other) {
    Map<String, dynamic> newChanges = {};
    Map<String, dynamic> oldChanges = {};

    if (invRecProduct != other.invRecProduct) {
      newChanges['invRecProduct'] = other.invRecProduct;
      oldChanges['invRecProduct'] = invRecProduct;
    }

    if (invRecQuantity != other.invRecQuantity) {
      newChanges['invRecQuantity'] = other.invRecQuantity;
      oldChanges['invRecQuantity'] = invRecQuantity;
    }

    if (invRecSubTotal != other.invRecSubTotal) {
      newChanges['invRecSubTotal'] = other.invRecSubTotal;
      oldChanges['invRecSubTotal'] = invRecSubTotal;
    }

    if (invRecTotal != other.invRecTotal) {
      newChanges['invRecTotal'] = other.invRecTotal;
      oldChanges['invRecTotal'] = invRecTotal;
    }

    if (invRecVat != other.invRecVat) {
      newChanges['invRecVat'] = other.invRecVat;
      oldChanges['invRecVat'] = invRecVat;
    }

    if (invRecIsLocal != other.invRecIsLocal) {
      newChanges['invRecIsLocal'] = other.invRecIsLocal;
      oldChanges['invRecIsLocal'] = invRecIsLocal;
    }
    if (invRecGift != other.invRecGift) {
      newChanges['invRecGift'] = other.invRecGift;
      oldChanges['invRecGift'] = invRecGift;
    }
    if (invRecGiftTotal != other.invRecGiftTotal) {
      newChanges['invRecGiftTotal'] = other.invRecGiftTotal;
      oldChanges['invRecGiftTotal'] = invRecGiftTotal;
    }

    if (newChanges.isNotEmpty) newChanges['invRecId'] = other.invRecId;
    if (oldChanges.isNotEmpty) oldChanges['invRecId'] = invRecId;

    return {"newData": newChanges, "oldData": oldChanges};
  }

  Map<PlutoColumn, dynamic> toEditedMap(BillTypeModel billTypeModel) {
    final double total = invRecTotal ?? 0;
    final int quantity = invRecQuantity ?? 1;
    final bool hasVat = billTypeModel.billPatternType?.hasVat ?? false;

    final double subTotalStr =
        (quantity > 0) ? (hasVat ? AppServiceUtils.toFixedDouble(total / (quantity * 1.05)) : total / quantity) : total;

    final double vat = (quantity > 0 && hasVat) ? AppServiceUtils.toFixedDouble(subTotalStr * 0.05) : 0;

    return {
      // Row Index Column
      buildPlutoColumn(
        title: '#',
        field: AppConstants.invRecId,
        type: PlutoColumnType.text(),
        width: 50,
        isReadOnly: true,
        hasContextMenu: false,
        isResizable: false,
        customRenderer: (rendererContext) {
          if (rendererContext.row.cells[AppConstants.invRecProduct]?.value != '') {
            rendererContext.cell.value = rendererContext.rowIdx.toString();
            return Text((rendererContext.rowIdx + 1).toString());
          }
          return const Text("");
        },
      ): invRecId,

      // Product Name Column
      buildPlutoColumn(
        title: AppStrings.material.tr,
        field: AppConstants.invRecProduct,
        type: PlutoColumnType.text(),
        width: 300,
        hasContextMenu: false,
      ): invRecProduct,

      // Quantity Column
      buildPlutoColumn(
        title: AppStrings.quantity.tr,
        field: AppConstants.invRecQuantity,
        type: PlutoColumnType.text(),
        width: 110,
        hasContextMenu: false,
        readOnlyCondition: (row, cell) => cell.row.cells[AppConstants.invRecProduct]?.value == '',
      ): invRecQuantity,

      // Individual Price Column
      buildPlutoColumn(
        title: AppStrings.individual.tr,
        field: AppConstants.invRecSubTotal,
        type: PlutoColumnType.text(),
        hasContextMenu: false,
        width: 110,
        readOnlyCondition: (row, cell) => cell.row.cells[AppConstants.invRecProduct]?.value == '',
      ): subTotalStr,
      // Tax Column (Only if VAT is enabled)
      if (billTypeModel.billPatternType!.hasVat)
        buildPlutoColumn(
          title: AppStrings.tax.tr,
          field: AppConstants.invRecVat,
          type: PlutoColumnType.text(),
          width: 110,
          hasContextMenu: false,
          isEditable: false,
        ): vat,
      // Total Column
      buildPlutoColumn(
        title: AppStrings.total.tr,
        field: AppConstants.invRecTotal,
        type: PlutoColumnType.text(),
        width: 150,
        hasContextMenu: false,
        readOnlyCondition: (row, cell) => cell.row.cells[AppConstants.invRecProduct]?.value == '',
      ): invRecTotal,

      // Gifts Column (Only if Gifts Account is enabled)
      if (billTypeModel.billPatternType!.hasGiftsAccount)
        buildPlutoColumn(
          title: AppStrings.gifts.tr,
          field: AppConstants.invRecGift,
          type: PlutoColumnType.text(),
          width: 110,
          hasContextMenu: false,
          readOnlyCondition: (row, cell) => cell.row.cells[AppConstants.invRecProduct]?.value == '',
        ): invRecGift,
      if (billTypeModel.billPatternType!.hasVat)
        buildPlutoColumn(
          title: AppStrings.invRecSubTotalWithVat.tr,
          field: AppConstants.invRecSubTotalWithVat,
          type: PlutoColumnType.text(),
          width: 150,
          hasContextMenu: false,

          // isEditable: false,
          // isReadOnly: true,
          readOnlyCondition: (row, cell) => cell.row.cells[AppConstants.invRecProduct]?.value == '',
        ): invRecSubTotal == 0 ? '' : ((invRecSubTotal ?? 0) + (invRecVat ?? 0)).toStringAsFixed(2),

      // Serial Numbers Column
      buildPlutoColumn(
        title: AppStrings.productSerialNumbers.tr,
        field: AppConstants.invRecProductSerialNumbers,
        type: PlutoColumnType.text(),
        width: 110,
        isEditable: false,
        hasContextMenu: false,
        isUIHidden: true,
        isFullyHidden: AppConstants.hideInvRecProductSerialNumbers,
      ): invRecProductSerialNumbers,

      // Sold Serial Number Column (Hidden but retains value)
      buildPlutoColumn(
        title: AppStrings.productSoldSerialNumber.tr,
        field: AppConstants.invRecProductSoldSerial,
        type: PlutoColumnType.text(),
        isUIHidden: true,
        hasContextMenu: false,
        isFullyHidden: AppConstants.hideInvRecProductSoldSerial,
      ): invRecProductSoldSerial,
    };
  }

  double? calculateSubTotal({required int quantity, required double total, required double vat}) {
    return (total / quantity) - (total / quantity) * vat;
  }
}

class AdditionsDiscountsRecordModel {
  String? account;
  double? discount;
  double? discountRatio;
  double? addition;
  double? additionRatio;

  AdditionsDiscountsRecordModel({
    this.account,
    this.discount,
    this.discountRatio,
    this.addition,
    this.additionRatio,
  });

  /// Factory method to create an InvoiceRecordModel from a BillItem.
  factory AdditionsDiscountsRecordModel.fromBillModel(BillModel billModel) {
    double partialTotal = (billModel.billDetails.billVatTotal ?? 0) + (billModel.billDetails.billBeforeVatTotal ?? 0);

    final discountTotal = billModel.billDetails.billDiscountsTotal ?? 0;
    final additionTotal = billModel.billDetails.billAdditionsTotal ?? 0;

    double calculateRatio(double value, double total) => AppServiceUtils.toFixedDouble(total > 0 ? ((value / total) * 100) : 0);

    return AdditionsDiscountsRecordModel(
      account: billModel.billTypeModel.accounts?[BillAccounts.discounts]?.accName ?? '',
      discount: AppServiceUtils.toFixedDouble(discountTotal),
      discountRatio: calculateRatio(billModel.billDetails.billDiscountsTotal ?? 0, partialTotal),
      addition: AppServiceUtils.toFixedDouble(additionTotal),
      additionRatio: calculateRatio(billModel.billDetails.billAdditionsTotal ?? 0, partialTotal),
    );
  }

  factory AdditionsDiscountsRecordModel.fromJson(Map<dynamic, dynamic> map) => AdditionsDiscountsRecordModel(
        account: map[AppConstants.id],
        discount: _parseDouble(map[AppConstants.discount]),
        discountRatio: _parseDouble(map[AppConstants.discountRatio]),
        addition: _parseDouble(map[AppConstants.addition]),
        additionRatio: _parseDouble(map[AppConstants.additionRatio]),
      );

  toJson() => {
        AppConstants.id: account,
        AppConstants.discount: discount,
        AppConstants.discountRatio: discountRatio,
        AppConstants.addition: addition,
        AppConstants.additionRatio: additionRatio,
      };

  factory AdditionsDiscountsRecordModel.fromJsonPluto(Map<dynamic, dynamic> map) {
    final String? account = map[AppConstants.id];
    final double? discount = _parseDouble(map[AppConstants.discount]);
    final double? discountRatio = _parseDouble(map[AppConstants.discountRatio]);
    final double? addition = _parseDouble(map[AppConstants.addition]);
    final double? additionRatio = _parseDouble(map[AppConstants.additionRatio]);

    return AdditionsDiscountsRecordModel(
      account: account,
      discount: discount,
      discountRatio: discountRatio,
      addition: addition,
      additionRatio: additionRatio,
    );
  }

  // Helper method to parse doubles, handling Arabic numerals
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(AppServiceUtils.replaceArabicNumbersWithEnglish(value.toString()));
  }

  @override
  int get hashCode => account.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AdditionsDiscountsRecordModel && runtimeType == other.runtimeType && account == other.account;

  Map<String, Map<String, dynamic>> getChanges(AdditionsDiscountsRecordModel other) {
    Map<String, dynamic> newChanges = {};
    Map<String, dynamic> oldChanges = {};

    if (discount != other.discount) {
      newChanges['discount'] = other.discount;
      oldChanges['discount'] = discount;
    }

    if (addition != other.addition) {
      newChanges['addition'] = other.addition;
      oldChanges['addition'] = addition;
    }

    if (discountRatio != other.discountRatio) {
      newChanges['discountRatio'] = other.discountRatio;
      oldChanges['discountRatio'] = discountRatio;
    }

    if (additionRatio != other.additionRatio) {
      newChanges['additionRatio'] = other.additionRatio;
      oldChanges['additionRatio'] = additionRatio;
    }

    if (newChanges.isNotEmpty) newChanges['account'] = other.account;
    if (oldChanges.isNotEmpty) oldChanges['account'] = account;

    return {"newData": newChanges, "oldData": oldChanges};
  }

  Map<PlutoColumn, dynamic> toEditedMap() {
    return {
      PlutoColumn(title: AppStrings.account.tr, field: AppConstants.id, type: PlutoColumnType.text()): account,
      PlutoColumn(title: AppStrings.discount.tr, field: AppConstants.discount, type: PlutoColumnType.text()): discount,
      PlutoColumn(title: AppStrings.discountRatio.tr, field: AppConstants.discountRatio, type: PlutoColumnType.text()): discountRatio,
      PlutoColumn(title: AppStrings.additions.tr, field: AppConstants.addition, type: PlutoColumnType.text()): addition,
      PlutoColumn(title: AppStrings.additionRatio.tr, field: AppConstants.additionRatio, type: PlutoColumnType.text()): additionRatio,
    };
  }
}