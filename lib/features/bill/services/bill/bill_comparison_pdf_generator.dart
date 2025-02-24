import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/date_time_extensions.dart';
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
        buildTitleText(
          fileName,
          32,
          font: font,
          weight: FontWeight.bold,
          color: PdfColors.red,
        ),
        buildDetailRow('الرقم التعريفي للفاتورة: ', afterUpdate.billId!, font: font),
        buildDetailRow(' رقم الفاتورة: ', afterUpdate.billDetails.billNumber.toString(), font: font),
        buildDetailRow(
          'نوع الفاتورة: ',
          billName(afterUpdate),
          font: font,
          valueColor: PdfColor.fromInt(afterUpdate.billTypeModel.color!),
        ),
      ],
    );
  }

  @override
  List<Widget> buildBody(List<BillModel> itemModel, {Font? font}) {
    final beforeUpdate = itemModel[0];
    final afterUpdate = itemModel[1];

    return [
      buildTitleText('تفاصيل التعديلات', 20, font: font, weight: FontWeight.bold),
      _buildComparisonTable(beforeUpdate, afterUpdate, font),
      SizedBox(height: 20),
      _buildItemsTable(beforeUpdate, afterUpdate, font),
      Divider(),
      _buildSummary(beforeUpdate, afterUpdate, font),
    ];
  }

  Widget _buildComparisonTable(BillModel beforeUpdate, BillModel afterUpdate, Font? font) {
    return TableHelper.fromTextArray(
      headers: ['الحقل', AppStrings.before, AppStrings.after],
      data: _buildComparisonData(beforeUpdate, afterUpdate, font),
      headerDirection: TextDirection.rtl,
      tableDirection: TextDirection.rtl,
      // White text for contrast
      headerStyle: TextStyle(
        fontWeight: FontWeight.bold,
        font: font,
        color: PdfColors.white,
      ),
      // Black text for better readability
      cellStyle: TextStyle(
        font: font,
        color: PdfColors.black,
      ),

      headerDecoration: BoxDecoration(
        color: PdfColor.fromInt(afterUpdate.billTypeModel.color!), // Header color
      ),
      // Row background (lighter version of header)
      rowDecoration: BoxDecoration(
        color: PdfColor.fromInt(lightenColor(afterUpdate.billTypeModel.color!, 0.9)),
      ),
      cellHeight: 30,
      columnWidths: _columnWidthsSummary,
      cellAlignments: _cellAlignmentsSummary,
    );
  }

  Widget _buildItemsTable(BillModel beforeUpdate, BillModel afterUpdate, Font? font) {
    return TableHelper.fromTextArray(
      headers: _itemHeaders,
      data: _buildItemsComparisonData(beforeUpdate, afterUpdate, font),
      headerAlignments: _headerAlignmentsItems,
      headerDirection: TextDirection.rtl,
      tableDirection: TextDirection.rtl,
      // White text for contrast
      headerStyle: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        font: font,
        color: PdfColors.white,
      ),
      // Black text for better readability
      cellStyle: TextStyle(
        fontSize: 10,
        font: font,
        color: PdfColors.black,
      ),
      // Header background
      headerDecoration: BoxDecoration(
        color: PdfColor.fromInt(afterUpdate.billTypeModel.color!), // Header color
      ),
      // Row background (lighter version of header)
      rowDecoration: BoxDecoration(
        color: PdfColor.fromInt(lightenColor(afterUpdate.billTypeModel.color!, 0.9)),
      ),
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
      final statusLabel = getItemStatus(before?.itemQuantity, after?.itemQuantity);
      final itemName = before?.itemName ?? after?.itemName;

      return [
        // Item Name + Status]
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              statusLabel,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                font: font,
                fontSize: 10,
                fontWeight: FontWeight.bold, // Make it bold
                color: PdfColors.red, // Change color to red
              ),
            ),
            buildTextCell(itemName, font),
          ],
        ),

        // Barcode (no highlight)
        buildBarcode(guid),

        // Quantity
        before?.itemQuantity.toString() ?? '0',
        highlightChange(
          before?.itemQuantity.toString() ?? '0',
          after?.itemQuantity.toString() ?? '0',
          font,
        ),

        // SubTotal
        before?.itemSubTotalPrice?.toStringAsFixed(2) ?? '0.00',
        highlightChange(
          before?.itemSubTotalPrice?.toStringAsFixed(2) ?? '0.00',
          after?.itemSubTotalPrice?.toStringAsFixed(2) ?? '0.00',
          font,
        ),

        // VAT
        before?.itemVatPrice?.toStringAsFixed(2) ?? '0.00',
        highlightChange(
          before?.itemVatPrice?.toStringAsFixed(2) ?? '0.00',
          after?.itemVatPrice?.toStringAsFixed(2) ?? '0.00',
          font,
        ),

        // Total
        before?.itemTotalPrice.toDouble.toStringAsFixed(2) ?? '0.00',
        highlightChange(
          before?.itemTotalPrice.toDouble.toStringAsFixed(2) ?? '0.00',
          after?.itemTotalPrice.toDouble.toStringAsFixed(2) ?? '0.00',
          font,
        ),
      ];
    }).toList();
  }

  Widget _buildSummary(BillModel beforeUpdate, BillModel afterUpdate, Font? font) {
    final beforeTotal = beforeUpdate.billDetails.billTotal ?? 0;
    final afterTotal = afterUpdate.billDetails.billTotal ?? 0;

    return Container(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSummaryRow(
            title: 'المجموع قبل التعديل:',
            value: Text(beforeTotal.toStringAsFixed(2)),
            font: font,
          ),
          _buildSummaryRow(
            title: 'المجموع بعد التعديل:',
            value: highlightChange(
              beforeTotal.toStringAsFixed(2),
              afterTotal.toStringAsFixed(2),
              font,
            ),
            font: font,
          ),
          Divider(),
          _buildSummaryRow(
            title: 'الفرق:',
            value: Text(
              (afterTotal - beforeTotal).toStringAsFixed(2),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            weight: FontWeight.bold,
            font: font,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({required String title, required Widget value, Font? font, FontWeight? weight}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        value,
        Text(
          title,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            font: font,
            fontWeight: weight,
          ),
        ),
      ],
    );
  }

  List<List<dynamic>> _buildComparisonData(BillModel beforeUpdate, BillModel afterUpdate, Font? font) {
    final beforeCustomerName = _accountsController.getAccountNameById(beforeUpdate.billDetails.billCustomerId);
    final afterCustomerName = _accountsController.getAccountNameById(afterUpdate.billDetails.billCustomerId);

    final beforeSellerName = _sellerController.getSellerNameById(beforeUpdate.billDetails.billSellerId);
    final afterSellerName = _sellerController.getSellerNameById(afterUpdate.billDetails.billSellerId);

    return [
      [
        'العميل',
        beforeCustomerName,
        highlightChange(beforeCustomerName, afterCustomerName, font),
      ],
      [
        'البائع',
        beforeSellerName,
        highlightChange(beforeSellerName, afterSellerName, font),
      ],
      [
        'التاريخ',
        beforeUpdate.billDetails.billDate?.dayMonthYear ?? '',
        highlightChange(
          beforeUpdate.billDetails.billDate?.dayMonthYear,
          afterUpdate.billDetails.billDate?.dayMonthYear,
          font,
        ),
      ],
    ];
  }

  final _itemHeaders = [
    'المادة',
    'الباركود',
    'الكمية ${AppStrings.before}',
    'الكمية ${AppStrings.after}',
    'سعر الوحدة ${AppStrings.before}',
    'سعر الوحدة ${AppStrings.after}',
    'الضريبة ${AppStrings.before}',
    'الضريبة ${AppStrings.after}',
    'المجموع ${AppStrings.before}',
    'المجموع ${AppStrings.after}'
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
    0: const FixedColumnWidth(130),
    1: const FixedColumnWidth(100),
    2: const FixedColumnWidth(90),
    3: const FixedColumnWidth(90),
    4: const FixedColumnWidth(90),
    5: const FixedColumnWidth(90),
    6: const FixedColumnWidth(80),
    7: const FixedColumnWidth(80),
    8: const FixedColumnWidth(90),
    9: const FixedColumnWidth(90),
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
