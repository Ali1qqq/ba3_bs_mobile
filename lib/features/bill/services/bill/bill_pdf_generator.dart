import 'package:ba3_bs_mobile/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/pdf_generator/implementations/pdf_generator_base.dart';
import '../../../materials/controllers/material_controller.dart';

class BillPdfGenerator extends PdfGeneratorBase<BillModel> {
  final _sellerController = read<SellerController>();
  final _materialController = read<MaterialController>();

  @override
  Widget buildTitle(BillModel itemModel, {Uint8List? logoUint8List, Font? font}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBillDetails(itemModel, font),
        if (logoUint8List != null)
          Image(
            MemoryImage(logoUint8List),
            width: 5 * PdfPageFormat.cm,
            height: 5 * PdfPageFormat.cm,
          ),
      ],
    );
  }

  Widget _buildBillDetails(BillModel itemModel, Font? font) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleText('INVOICE', 24, FontWeight.bold),
        _buildSpacing(),
        _buildDetailRow('Bill number: ', itemModel.billDetails.billNumber.toString()),
        _buildSpacing(),
        _buildDetailRow('Bill type: ', billName(itemModel), font, TextDirection.rtl),
        _buildSpacing(),
        _buildDetailRow('Bill id: ', itemModel.billId!),
        _buildSpacing(),
        _buildDetailRow('Date of Invoice: ', itemModel.billDetails.billDate!),
        _buildSpacing(),
        _buildDetailRow(
          'Seller Name: ',
          _sellerController.getSellerNameById(itemModel.billDetails.billSellerId),
          font,
          TextDirection.rtl,
        ),
        _buildSpacing(),
      ],
    );
  }

  Widget _buildTitleText(String text, double size, FontWeight weight) {
    return Text(
      text,
      style: TextStyle(fontSize: size, fontWeight: weight),
    );
  }

  Widget _buildDetailRow(String title, String value, [Font? font, TextDirection? direction]) {
    return Row(
      children: [
        Text(title),
        Text(
          value,
          style: font != null ? TextStyle(font: font) : null,
          textDirection: direction,
        ),
      ],
    );
  }

  Widget _buildSpacing() => SizedBox(height: 0.4 * PdfPageFormat.cm);

  @override
  Widget buildBody(BillModel itemModel, {Font? font}) {
    final headers = ['Item Name', 'Barcode', 'Quantity', 'Unit Price', 'VAT', 'Total'];
    final data = _buildTableData(itemModel);

    return Column(
      children: [
        TableHelper.fromTextArray(
          headers: headers,
          data: data,
          headerStyle: TextStyle(fontWeight: FontWeight.bold, font: font),
          cellStyle: TextStyle(font: font),
          tableDirection: TextDirection.rtl,
          headerDecoration: const BoxDecoration(color: PdfColors.grey300),
          cellHeight: 30,
          columnWidths: _columnWidths,
          cellAlignments: _cellAlignments,
        ),
        Divider(),
        buildTotal(itemModel)
      ],
    );
  }

  List<List<dynamic>> _buildTableData(BillModel itemModel) {
    return itemModel.items.itemList.map((item) {
      final barcodeWidget = _buildBarcode(item.itemGuid);

      return [
        item.itemName,
        barcodeWidget,
        '${item.itemQuantity}',
        (item.itemSubTotalPrice ?? 0).toStringAsFixed(2),
        (item.itemVatPrice ?? 0).toStringAsFixed(2),
        (item.itemTotalPrice.toDouble ?? 0).toStringAsFixed(2),
      ];
    }).toList();
  }

  Widget _buildBarcode(String itemGuid) {
    final barcode = Barcode.code128();
    final barcodeData = _materialController.getMaterialBarcodeById(itemGuid);

    return BarcodeWidget(
      barcode: barcode,
      data: barcodeData,
      width: 100,
      height: 40,
    );
  }

  Map<int, TableColumnWidth> get _columnWidths => {
        0: const FixedColumnWidth(150), // Item Name
        1: const FixedColumnWidth(80), // Barcode
        2: const FixedColumnWidth(60), // Quantity
        3: const FixedColumnWidth(60), // Unit Price
        4: const FixedColumnWidth(50), // VAT
        5: const FixedColumnWidth(60), // Total
      };

  Map<int, Alignment> get _cellAlignments => {
        0: Alignment.centerLeft, // Item Name
        1: Alignment.center, // Barcode
        2: Alignment.center, // Quantity
        3: Alignment.center, // Unit Price
        4: Alignment.center, // VAT
        5: Alignment.center, // Total
      };

  Widget buildTotal(BillModel itemModel) {
    final vat = itemModel.billDetails.billVatTotal ?? 0;
    final totalBeforeVat = itemModel.billDetails.billBeforeVatTotal ?? 0;
    final netTotal = totalBeforeVat + vat;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        alignment: Alignment.centerRight,
        child: Row(
          children: [
            Spacer(flex: 6),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalText('Net total', netTotal.toStringAsFixed(2)),
                  _buildTotalText('Vat 5.0 %', vat.toStringAsFixed(2)),
                  Divider(),
                  _buildTotalText(
                    'Total amount due',
                    netTotal.toStringAsFixed(2),
                    titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2 * PdfPageFormat.mm),
                  _buildGreyLine(),
                  SizedBox(height: 0.5 * PdfPageFormat.mm),
                  _buildGreyLine(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalText(String title, String value, {TextStyle? titleStyle}) =>
      buildText(title: title, value: value, titleStyle: titleStyle, unite: true);

  Widget _buildGreyLine() => Container(height: 1, color: PdfColors.grey400);

  String billName(BillModel billModel) => BillType.byLabel(billModel.billTypeModel.billTypeLabel!).value;
}
