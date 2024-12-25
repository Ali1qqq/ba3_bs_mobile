import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/pdf_generator/implementations/pdf_generator_base.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../data/models/bond_model.dart';

class BondPdfGenerator extends PdfGeneratorBase<BondModel> {
  final _accountsController = read<AccountsController>();

  @override
  Widget buildTitle(BondModel itemModel, {Uint8List? logoUint8List, Font? font}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBondDetails(itemModel, font),
        if (logoUint8List != null)
          Image(
            MemoryImage(logoUint8List),
            width: 5 * PdfPageFormat.cm,
            height: 5 * PdfPageFormat.cm,
          ),
      ],
    );
  }

  Widget _buildBondDetails(BondModel itemModel, Font? font) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleText('Bond', 24, FontWeight.bold),
        _buildSpacing(),
        _buildDetailRow('Bond number: ', itemModel.payNumber.toString()),
        _buildSpacing(),
        _buildDetailRow('Bond type: ', bondName(itemModel), font, TextDirection.rtl),
        _buildSpacing(),
        _buildDetailRow('Bond id: ', itemModel.payGuid!),
        _buildSpacing(),
        _buildDetailRow('Date of Bond: ', itemModel.payDate!),
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
  Widget buildBody(BondModel itemModel, {Font? font}) {
    final headers = ['id', 'account', 'debt', 'credit', 'nots'];
    final data = _buildTableData(itemModel);

    return TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: TextStyle(fontWeight: FontWeight.bold, font: font),
      cellStyle: TextStyle(font: font),
      tableDirection: TextDirection.rtl,
      headerDecoration: const BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      columnWidths: _columnWidths,
      cellAlignments: _cellAlignments,
    );
  }

  List<List<dynamic>> _buildTableData(BondModel itemModel) {
    return List.generate(itemModel.payItems.itemList.length, (index) {
      final item = itemModel.payItems.itemList[index];

      final accountName = _accountsController.getAccountNameById(item.entryAccountGuid);

      return [
        index,
        accountName,
        item.entryDebit,
        item.entryCredit,
        item.entryNote,
      ];
    });
  }

  Map<int, TableColumnWidth> get _columnWidths => {
        0: const FixedColumnWidth(50), // id
        1: const FixedColumnWidth(150), // account
        2: const FixedColumnWidth(60), // debt
        3: const FixedColumnWidth(60), // credit
        4: const FixedColumnWidth(50), // nots
      };

  Map<int, Alignment> get _cellAlignments => {
        0: Alignment.centerLeft, // id
        1: Alignment.center, // account
        2: Alignment.center, // debt
        3: Alignment.center, // credit
        4: Alignment.center, // nots
      };

  String bondName(BondModel bondModel) => BondType.byTypeGuide(bondModel.payTypeGuid!).value;
}
