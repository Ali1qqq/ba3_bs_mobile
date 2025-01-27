import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time_extensions.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/helper/mixin/pdf_helper.dart';
import '../../../../core/services/pdf_generator/implementations/pdf_generator_base.dart';

/// UpdatedBillPdfGenerator
class BillComparisonPdfGenerator extends PdfGeneratorBase<List<BillModel>> with PdfHelperMixin {
  final _accountsController = read<AccountsController>();
  final _sellerController = read<SellersController>();

  @override
  Widget buildHeader(List<BillModel> itemModel, String fileName, {Uint8List? logoUint8List, Font? font}) {
    final afterUpdate = itemModel[1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeaderText(fileName, afterUpdate, font),
        if (logoUint8List != null) buildLogo(logoUint8List),
      ],
    );
  }

  Widget _buildHeaderText(String fileName, BillModel afterUpdate, Font? font) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitleText(fileName, 24, font, FontWeight.bold),
        buildDetailRow('الرقم التعريفي للفاتورة: ', afterUpdate.billId!, font),
        buildDetailRow(' رقم الفاتورة: ', afterUpdate.billDetails.billNumber.toString(), font),
      ],
    );
  }

  @override
  List<Widget> buildBody(List<BillModel> itemModel, {Font? font}) {
    final beforeUpdate = itemModel[0];
    final afterUpdate = itemModel[1];

    return [
      buildTitleText('تفاصيل التعديلات', 20, font, FontWeight.bold),
      _buildComparisonTable(beforeUpdate, afterUpdate, font),
      SizedBox(height: 20),
      _buildItemsTable(beforeUpdate, afterUpdate, font),
      Divider(),
      _buildSummary(beforeUpdate, afterUpdate),
    ];
  }

  Widget _buildComparisonTable(BillModel beforeUpdate, BillModel afterUpdate, Font? font) {
    return TableHelper.fromTextArray(
      headers: ['Field', AppStrings.before, AppStrings.after],
      data: _buildComparisonData(beforeUpdate, afterUpdate),
      headerDirection: TextDirection.rtl,
      headerStyle: TextStyle(fontWeight: FontWeight.bold, font: font),
      cellStyle: TextStyle(font: font),
      tableDirection: TextDirection.rtl,
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      columnWidths: _columnWidthsSummary,
      cellAlignments: _cellAlignmentsSummary,
    );
  }

  Widget _buildItemsTable(BillModel beforeUpdate, BillModel afterUpdate, Font? font) {
    return TableHelper.fromTextArray(
      headers: _itemHeaders,
      data: _buildItemsComparisonData(beforeUpdate, afterUpdate, font),
      headerDirection: TextDirection.rtl,
      headerAlignments: _headerAlignmentsItems,
      headerStyle: TextStyle(fontWeight: FontWeight.bold, font: font, fontSize: 10),
      cellStyle: TextStyle(font: font, fontSize: 10),
      tableDirection: TextDirection.rtl,
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      columnWidths: _columnWidthsItems,
      cellAlignments: _cellAlignmentsItems,
    );
  }

  List<List<dynamic>> _buildItemsComparisonData(BillModel beforeUpdate, BillModel afterUpdate, Font? font) {
    final itemsBefore = {for (var item in beforeUpdate.items.itemList) item.itemGuid: item};
    final itemsAfter = {for (var item in afterUpdate.items.itemList) item.itemGuid: item};
    final allGuids = {...itemsBefore.keys, ...itemsAfter.keys};

    return allGuids.map((guid) {
      final before = itemsBefore[guid];
      final after = itemsAfter[guid];

      return [
        buildTextCell(before?.itemName ?? after?.itemName, font),
        buildBarcode(guid),
        before?.itemQuantity.toString() ?? '0',
        after?.itemQuantity.toString() ?? '0',
        before?.itemSubTotalPrice?.toStringAsFixed(2) ?? '0.00',
        after?.itemSubTotalPrice?.toStringAsFixed(2) ?? '0.00',
        before?.itemVatPrice?.toStringAsFixed(2) ?? '0.00',
        after?.itemVatPrice?.toStringAsFixed(2) ?? '0.00',
        before?.itemTotalPrice.toDouble.toStringAsFixed(2) ?? '0.00',
        after?.itemTotalPrice.toDouble.toStringAsFixed(2) ?? '0.00',
      ];
    }).toList();
  }

  Widget _buildSummary(BillModel beforeUpdate, BillModel afterUpdate) {
    final beforeTotal = beforeUpdate.billDetails.billTotal ?? 0;
    final afterTotal = afterUpdate.billDetails.billTotal ?? 0;

    return Container(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSummaryRow('Total Before Update:', beforeTotal.toStringAsFixed(2)),
          _buildSummaryRow('Total After Update:', afterTotal.toStringAsFixed(2)),
          Divider(),
          _buildSummaryRow('Difference:', (afterTotal - beforeTotal).toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {TextStyle? style}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style),
        Text(value, style: style),
      ],
    );
  }

  List<List<dynamic>> _buildComparisonData(BillModel beforeUpdate, BillModel afterUpdate) {
    final beforeCustomerName = _accountsController.getAccountNameById(beforeUpdate.billDetails.billCustomerId);
    final afterCustomerName = _accountsController.getAccountNameById(afterUpdate.billDetails.billCustomerId);

    final beforeSellerName = _sellerController.getSellerNameById(beforeUpdate.billDetails.billSellerId);
    final afterSellerName = _sellerController.getSellerNameById(afterUpdate.billDetails.billSellerId);

    return [
      ['العميل', beforeCustomerName, afterCustomerName],
      ['البائع', beforeSellerName, afterSellerName],
      ['التاريخ', beforeUpdate.billDetails.billDate?.dayMonthYear ?? '', afterUpdate.billDetails.billDate?.dayMonthYear ?? ''],
    ];
  }

  final _itemHeaders = [
    'Item Name',
    'Barcode',
    'Quantity (${AppStrings.before})',
    'Quantity (${AppStrings.after})',
    'Unit Price (${AppStrings.before})',
    'Unit Price (${AppStrings.after})',
    'VAT (${AppStrings.before})',
    'VAT (${AppStrings.after})',
    'Total (${AppStrings.before})',
    'Total (${AppStrings.after})'
  ];

  final _columnWidthsSummary = {
    0: const FixedColumnWidth(80),
    1: const FixedColumnWidth(150),
    2: const FixedColumnWidth(150),
  };

  final _cellAlignmentsSummary = {
    0: Alignment.centerLeft,
    1: Alignment.center,
    2: Alignment.center,
  };

  final _columnWidthsItems = {
    0: const FixedColumnWidth(120),
    1: const FixedColumnWidth(100),
    2: const FixedColumnWidth(100),
    3: const FixedColumnWidth(100),
    4: const FixedColumnWidth(90),
    5: const FixedColumnWidth(80),
    6: const FixedColumnWidth(90),
    7: const FixedColumnWidth(80),
    8: const FixedColumnWidth(90),
    9: const FixedColumnWidth(80),
  };

  final _headerAlignmentsItems = {
    0: Alignment.topCenter,
    1: Alignment.topCenter,
    2: Alignment.topCenter,
    3: Alignment.topCenter,
    4: Alignment.topCenter,
    5: Alignment.topCenter,
    6: Alignment.topCenter,
    7: Alignment.topCenter,
    8: Alignment.topCenter,
    9: Alignment.topCenter,
  };

  final _cellAlignmentsItems = {
    0: Alignment.topCenter,
    1: Alignment.center,
    2: Alignment.center,
    3: Alignment.center,
    4: Alignment.center,
    5: Alignment.center,
    6: Alignment.center,
    7: Alignment.center,
    8: Alignment.center,
    9: Alignment.center,
  };
}
