import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/pdf_helper.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/pay_item_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/pdf_generator/implementations/pdf_generator_base.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../data/models/bond_model.dart';

class BondComparisonPdfGenerator extends PdfGeneratorBase<List<BondModel>> with PdfHelperMixin {
  final _accountsController = read<AccountsController>();

  @override
  Widget buildHeader(List<BondModel> itemModel, String fileName, {Uint8List? logoUint8List, Font? font}) {
    final afterUpdate = itemModel[1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildHeaderText(fileName, afterUpdate, font),
        if (logoUint8List != null) buildLogo(logoUint8List),
      ],
    );
  }

  Widget _buildHeaderText(String fileName, BondModel afterUpdate, Font? font) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitleText(fileName, 24, font: font, weight: FontWeight.bold),
        buildDetailRow('الرقم التعريفي للسند: ', afterUpdate.payGuid.toString(), font: font),
        buildDetailRow('رقم السند: ', afterUpdate.payNumber.toString().toString(), font: font),
        buildDetailRow('نوع السند: ', BondType.byTypeGuide(afterUpdate.payTypeGuid!).value, font: font),
      ],
    );
  }

  @override
  List<Widget> buildBody(List<BondModel> itemModel, {Font? font}) {
    final BondModel beforeUpdate = itemModel[0];
    final BondModel afterUpdate = itemModel[1];

    final headersComparison = ['Field', AppStrings.before.tr, AppStrings.after.tr];
    final dataComparison = _buildComparisonData(beforeUpdate, afterUpdate);

    final headersItems = [
      ' الحساب(${AppStrings.before.tr})',
      'الحساب (${AppStrings.after.tr})',
      'مدين (${AppStrings.before.tr})',
      'مدين (${AppStrings.after.tr})',
      'دائن (${AppStrings.before.tr})',
      'دائن (${AppStrings.after.tr})',
      'البيان (${AppStrings.after.tr})',
      'البيان (${AppStrings.after.tr})',
    ];
    final dataItems = _buildItemsComparisonData(beforeUpdate, afterUpdate, font);

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

      /// Table for item details
      TableHelper.fromTextArray(
        headers: headersItems,
        data: dataItems,
        headerDirection: TextDirection.rtl,
        headerAlignments: _headerAlignmentsItems,
        headerStyle: TextStyle(
          fontWeight: FontWeight.bold,
          font: font,
          fontSize: 10,
        ),
        cellStyle: TextStyle(font: font, fontSize: 10),
        tableDirection: TextDirection.rtl,
        headerDecoration: const BoxDecoration(color: PdfColors.grey300),
        cellHeight: 30,
        columnWidths: _columnWidthsItems,
        cellAlignments: _cellAlignmentsItems,
      ),

      Divider(),
    ];
  }

  List<List<dynamic>> _buildItemsComparisonData(BondModel beforeUpdate, BondModel afterUpdate, Font? font) {
    // Create maps of items for easier lookup by item GUID
    final itemsBefore = beforeUpdate.payItems.itemList
        .mergeBy(
          (payEntry) => payEntry.entryAccountGuid,
          (existing, current) => PayItem(
              entryAccountName: existing.entryAccountName,
              entryNote: existing.entryNote! + current.entryNote!,
              entryCredit: existing.entryCredit! + current.entryCredit!,
              entryDebit: existing.entryDebit! + current.entryDebit!,
              entryDate: existing.entryDate),
        )
        .toMap((e) => e.entryAccountGuid);

    final itemsAfter = afterUpdate.payItems.itemList
        .mergeBy(
          (payEntry) => payEntry.entryAccountGuid,
          (existing, current) => PayItem(
              entryAccountName: existing.entryAccountName,
              entryNote: existing.entryNote! + current.entryNote!,
              entryCredit: existing.entryCredit! + current.entryCredit!,
              entryDebit: existing.entryDebit! + current.entryDebit!,
              entryDate: existing.entryDate),
        )
        .toMap((e) => e.entryAccountGuid);

    // Combine all GUIDs from both before and after updates
    final allGuids = {...itemsBefore.keys, ...itemsAfter.keys};

    return allGuids.map((guid) {
      final before = itemsBefore[guid];
      final after = itemsAfter[guid];

      return [
        buildTextCell(before?.entryAccountName ?? '', font),
        buildTextCell(after?.entryAccountName ?? '', font),
        (before?.entryDebit.toString()),
        (after?.entryDebit.toString()),
        (before?.entryCredit.toString()),
        (after?.entryCredit.toString()),
        before?.entryNote ?? '',
        after?.entryNote ?? '',
      ];
    }).toList();
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
      };

  Map<int, TableColumnWidth> get _columnWidthsItems => {
        0: const FixedColumnWidth(120),
        1: const FixedColumnWidth(100),
        2: const FixedColumnWidth(100),
        3: const FixedColumnWidth(100),
        4: const FixedColumnWidth(100),
        5: const FixedColumnWidth(100),
        6: const FixedColumnWidth(90),
        7: const FixedColumnWidth(80),
      };

  Map<int, Alignment> get _headerAlignmentsItems => {
        0: Alignment.topCenter,
        1: Alignment.topCenter,
        2: Alignment.topCenter,
        3: Alignment.topCenter,
        4: Alignment.topCenter,
        5: Alignment.topCenter,
        6: Alignment.topCenter,
        7: Alignment.topCenter,
      };

  Map<int, Alignment> get _cellAlignmentsItems => {
        0: Alignment.topCenter,
        1: Alignment.topCenter,
        2: Alignment.topCenter,
        3: Alignment.topCenter,
        4: Alignment.topCenter,
        5: Alignment.topCenter,
        6: Alignment.topCenter,
        7: Alignment.topCenter,
      };

  List<List<dynamic>> _buildComparisonData(BondModel beforeUpdate, BondModel afterUpdate) {
    final beforeCustomerName = _accountsController.getAccountNameById(beforeUpdate.payAccountGuid);
    final afterCustomerName = _accountsController.getAccountNameById(afterUpdate.payAccountGuid);

    return [
      if (BondType.byTypeGuide(beforeUpdate.payTypeGuid!) == BondType.paymentVoucher ||
          BondType.byTypeGuide(beforeUpdate.payTypeGuid!) == BondType.receiptVoucher)
        ['الحساب', beforeCustomerName, afterCustomerName],
      ['التاريخ', beforeUpdate.payDate, afterUpdate.payDate],
      ['البيان', beforeUpdate.payNote ?? '', afterUpdate.payNote ?? ''],
      // Add more comparisons as needed
    ];
  }
}