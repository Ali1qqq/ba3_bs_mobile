import 'package:ba3_bs_mobile/core/helper/mixin/pdf_helper.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/pdf_generator/implementations/pdf_generator_base.dart';
import '../data/models/cheques_model.dart';

class ChequesComparisonPdfGenerator extends PdfGeneratorBase<List<ChequesModel>> with PdfHelperMixin {
  @override
  Widget buildHeader(List<ChequesModel> itemModel, String fileName, {Uint8List? logoUint8List, Font? font}) {
    final afterUpdate = itemModel[1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeaderText(fileName, afterUpdate, font),
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
        buildDetailRow('نوع الشيك: ', ChequesType
            .byTypeGuide(afterUpdate.chequesTypeGuid!)
            .value, font: font),
      ],
    );
  }

  @override
  List<Widget> buildBody(List<ChequesModel> itemModel, {Font? font}) {
    final ChequesModel beforeUpdate = itemModel[0];
    final ChequesModel afterUpdate = itemModel[1];

    final headersComparison = ['Field', AppStrings.before.tr, AppStrings.after.tr];
    final dataComparison = _buildComparisonData(beforeUpdate, afterUpdate);

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

  Map<int, TableColumnWidth> get _columnWidthsSummary =>
      {
        0: const FixedColumnWidth(80), // Field
        1: const FixedColumnWidth(150), // Before
        2: const FixedColumnWidth(150), // After
      };

  Map<int, Alignment> get _cellAlignmentsSummary =>
      {
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

  List<List<dynamic>> _buildComparisonData(ChequesModel beforeUpdate, ChequesModel afterUpdate) {
    return [
      ['دفع الى', beforeUpdate.accPtrName, afterUpdate.accPtrName],
      ['الحساب', beforeUpdate.chequesAccount2Name, afterUpdate.chequesAccount2Name],
      ['التاريخ', beforeUpdate.chequesDate ?? '', afterUpdate.chequesDate ?? ''],
      ['تاريخ الاستحقاق', beforeUpdate.chequesDueDate ?? '', afterUpdate.chequesDueDate ?? ''],
      ['قيمة الشيك', beforeUpdate.chequesVal ?? '', afterUpdate.chequesVal ?? ''],
      ['رقم الشيك', beforeUpdate.chequesNumber ?? '', afterUpdate.chequesNumber ?? ''],
      ['رقم الورقة', beforeUpdate.chequesNum ?? '', afterUpdate.chequesNum ?? ''],
      ['تم الدفع', (beforeUpdate.isPayed ?? false) ? 'نعم' : 'لا', (afterUpdate.isPayed ?? false) ? 'نعم' : 'لا'],
      ['تم الارجاع', (beforeUpdate.isRefund ?? false) ? 'نعم' : 'لا', (afterUpdate.isRefund ?? false) ? 'نعم' : 'لا'],
      ['البيان', beforeUpdate.chequesNote ?? '', afterUpdate.chequesNote ?? ''],
      // Add more comparisons as needed
    ];
  }
}