import 'package:ba3_bs_mobile/core/helper/mixin/pdf_helper.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/pdf_generator/implementations/pdf_generator_base.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../data/models/bond_model.dart';

class BondPdfGenerator extends PdfGeneratorBase<BondModel> with PdfHelperMixin {
  final _accountsController = read<AccountsController>();

  @override
  Widget buildHeader(BondModel itemModel, String fileName, {Uint8List? logoUint8List, Font? font}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBondDetails(itemModel, fileName, font),
        if (logoUint8List != null)
          Image(
            MemoryImage(logoUint8List),
            width: 5 * PdfPageFormat.cm,
            height: 5 * PdfPageFormat.cm,
          ),
      ],
    );
  }

  Widget _buildBondDetails(BondModel itemModel, String fileName, Font? font) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitleText(fileName, 24, font, FontWeight.bold),
        buildSpacing(),
        buildDetailRow('Bond number: ', itemModel.payNumber.toString(), font),
        buildSpacing(),
        buildDetailRow('Bond type: ', bondName(itemModel), font),
        buildSpacing(),
        buildDetailRow('Bond id: ', itemModel.payGuid!, font),
        buildSpacing(),
        buildDetailRow('Date of Bond: ', itemModel.payDate!, font),
        buildSpacing(),
      ],
    );
  }

  @override
  List<Widget> buildBody(BondModel itemModel, {Font? font}) {
    final headers = ['id', 'account', 'debt', 'credit', 'nots'];
    final data = _buildTableData(itemModel);

    return <Widget>[
      Text(
        'تفاصيل السند',
        textDirection: TextDirection.rtl,
        style: font != null ? TextStyle(font: font) : null,
      ),
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
    ];
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
