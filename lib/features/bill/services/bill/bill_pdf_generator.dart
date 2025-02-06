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

/// NewBillPdfGenerator
class BillPdfGenerator extends PdfGeneratorBase<BillModel> with PdfHelperMixin {
  final _sellerController = read<SellersController>();
  final _accountsController = read<AccountsController>();

  @override
  Widget buildHeader(BillModel itemModel, String fileName, {Uint8List? logoUint8List, Font? font}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBillDetails(fileName, itemModel, font),
        if (logoUint8List != null) buildLogo(logoUint8List),
      ],
    );
  }

  Widget _buildBillDetails(String fileName, BillModel itemModel, Font? font) {
    final details = [
      buildDetailRow('الرقم التعريفي للفاتورة: ', itemModel.billId!, font: font),
      buildDetailRow('رقم الفاتورة: ', itemModel.billDetails.billNumber.toString(), font: font),
      buildDetailRow(
        'نوع الفاتورة: ',
        billName(itemModel),
        font: font,
        valueColor: PdfColor.fromInt(itemModel.billTypeModel.color!),
      ),
      buildDetailRow('العميل: ', _accountsController.getAccountNameById(itemModel.billDetails.billCustomerId),
          font: font),
      buildDetailRow('البائع: ', _sellerController.getSellerNameById(itemModel.billDetails.billSellerId), font: font),
      buildDetailRow('التاريخ: ', itemModel.billDetails.billDate!.dayMonthYear, font: font),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitleText(
          fileName,
          32,
          font: font,
          weight: FontWeight.bold,
          color: PdfColor.fromInt(itemModel.billTypeModel.color!),
        ),
        ...details.expand((detail) => [buildSpacing(), detail]),
      ],
    );
  }

  @override
  List<Widget> buildBody(BillModel itemModel, {Font? font}) {
    return [
      buildTitleText('تفاصيل الفاتورة', 20, font: font, weight: FontWeight.bold),
      _buildTable(itemModel, font),
      Divider(),
      _buildTotalSection(itemModel),
    ];
  }

  Widget _buildTable(BillModel itemModel, Font? font) {
    final headers = ['Item Name', 'Barcode', 'Quantity', 'Unit Price', 'VAT', 'Total'];
    final data = _buildTableData(itemModel, font);

    return TableHelper.fromTextArray(
      headers: headers,
      data: data,
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
      // Header background
      headerDecoration: BoxDecoration(
        color: PdfColor.fromInt(itemModel.billTypeModel.color!), // Header color
      ),
      // Row background (lighter version of header)
      rowDecoration: BoxDecoration(
        color: PdfColor.fromInt(lightenColor(itemModel.billTypeModel.color!, 0.9)),
      ),
      cellHeight: 30,
      columnWidths: _columnWidths,
      cellAlignments: _cellAlignments,
    );
  }

  List<List<dynamic>> _buildTableData(BillModel itemModel, Font? font) {
    return itemModel.items.itemList.map((item) {
      return [
        buildTextCell(item.itemName, font),
        buildBarcode(item.itemGuid),
        '${item.itemQuantity}',
        (item.itemSubTotalPrice ?? 0).toStringAsFixed(2),
        (item.itemVatPrice ?? 0).toStringAsFixed(2),
        (item.itemTotalPrice.toDouble).toStringAsFixed(2),
      ];
    }).toList();
  }

  Widget _buildTotalSection(BillModel itemModel) {
    final vat = itemModel.billDetails.billVatTotal ?? 0;
    final totalBeforeVat = itemModel.billDetails.billBeforeVatTotal ?? 0;
    final netTotal = totalBeforeVat + vat;

    return Container(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalRow('Net total', netTotal.toStringAsFixed(2)),
          _buildTotalRow('Vat 5.0 %', vat.toStringAsFixed(2)),
          Divider(),
          _buildTotalRow(
            'Total amount due',
            netTotal.toStringAsFixed(2),
            TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          _buildGreyLine(),
          _buildGreyLine(),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String title, String value, [TextStyle? style]) {
    return Row(
      children: [
        Expanded(child: Text(title, style: style)),
        Text(value, style: style),
      ],
    );
  }

  Widget _buildGreyLine() => Container(height: 1, color: PdfColors.grey400);

  Map<int, TableColumnWidth> get _columnWidths => {
    0: const FixedColumnWidth(150),
    1: const FixedColumnWidth(80),
    2: const FixedColumnWidth(60),
    3: const FixedColumnWidth(60),
    4: const FixedColumnWidth(50),
    5: const FixedColumnWidth(60),
  };

  Map<int, Alignment> get _cellAlignments => {
    0: Alignment.centerLeft,
    1: Alignment.center,
    2: Alignment.center,
    3: Alignment.center,
    4: Alignment.center,
    5: Alignment.center,
  };
}
