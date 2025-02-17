import 'package:ba3_bs_mobile/core/helper/mixin/pdf_helper.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/pdf_generator/implementations/pdf_generator_base.dart';
import '../data/models/cheques_model.dart';

class ChequesPdfGenerator extends PdfGeneratorBase<ChequesModel> with PdfHelperMixin {
  @override
  Widget buildHeader(ChequesModel itemModel, String fileName, {Uint8List? logoUint8List, Font? font}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeaderText(fileName, itemModel, font),
        if (logoUint8List != null) buildLogo(logoUint8List),
      ],
    );
  }

  Widget _buildHeaderText(String fileName, ChequesModel afterUpdate, Font? font) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitleText(fileName, 24, font: font, weight: FontWeight.bold),
        buildDetailRow('رقم الشيك التعريفي: ', afterUpdate.chequesGuid.toString(), font: font),
        buildDetailRow('رقم الشيك: ', afterUpdate.chequesNumber.toString().toString(), font: font),
        buildDetailRow('نوع الشيك: ', ChequesType.byTypeGuide(afterUpdate.chequesTypeGuid!).value, font: font),
      ],
    );
  }

  @override
  List<Widget> buildBody(ChequesModel itemModel, {Font? font}) {
    final headersComparison = ['Field', 'Values'];
    final dataComparison = _buildComparisonData(itemModel);

    return <Widget>[
      buildTitleText('تفاصيل التعديلات', 20, font: font),

      /// Table for seller, customer, and date
      TableHelper.fromTextArray(
        headers: headersComparison,
        data: dataComparison,
        headerDirection: TextDirection.rtl,
        headerStyle: TextStyle(fontWeight: FontWeight.bold, font: font),
        cellStyle: TextStyle(font: font),
        tableDirection: TextDirection.rtl,
        headerDecoration: const BoxDecoration(color: PdfColors.grey300),
        cellHeight: 30,
        columnWidths: _columnWidthsSummary,
        cellAlignments: _cellAlignmentsSummary,
      ),

      SizedBox(height: 20),
    ];
  }

  Map<int, TableColumnWidth> get _columnWidthsSummary => {
        0: const FixedColumnWidth(80), // Field
        1: const FixedColumnWidth(150), // Before
        2: const FixedColumnWidth(150), // After
      };

  Map<int, Alignment> get _cellAlignmentsSummary => {
        0: Alignment.center,
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

  List<List<dynamic>> _buildComparisonData(ChequesModel beforeUpdate) {
    return [
      ['دفع الى', beforeUpdate.accPtrName],
      ['الحساب', beforeUpdate.chequesAccount2Name],
      ['التاريخ', beforeUpdate.chequesDate ?? ''],
      ['تاريخ الاستحقاق', beforeUpdate.chequesDueDate ?? ''],
      ['قيمة الشيك', beforeUpdate.chequesVal ?? ''],
      ['رقم الشيك', beforeUpdate.chequesNumber ?? ''],
      ['رقم الورقة', beforeUpdate.chequesNum ?? '' ''],
      [
        'تم الدفع',
        (beforeUpdate.isPayed ?? false) ? 'نعم' : 'لا',
      ],
      ['تم الارجاع', (beforeUpdate.isRefund ?? false) ? 'نعم' : 'لا'],
      ['البيان', beforeUpdate.chequesNote ?? ''],
      // Add more comparisons as needed
    ];
  }
}