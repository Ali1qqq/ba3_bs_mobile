import 'dart:io';

import 'package:ba3_bs_mobile/core/constants/printer_constants.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../interfaces/i_pdf_generator.dart';

abstract class PdfGeneratorBase<T> implements IPdfGenerator<T> {
  final Document _pdfDocument = Document();

  @override
  Widget buildTitle(T itemModel, {Uint8List? logoUint8List, Font? font});

  @override
  Widget buildBody(T itemModel, {Font? font});

  @override
  Widget buildFooter() => Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            buildSimpleText(title: '', value: 'Thank You To Visit:'),
            SizedBox(width: 1 * PdfPageFormat.mm),
            buildSimpleText(title: 'Burj ALArab', value: PrinterConstants.contactNumber),
          ])
        ],
      ));

  @override
  buildSimpleText({required String title, required String value}) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  @override
  buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }

  @override
  Future<String> generatePdf(T itemModel, String fileName, {String? logoSrc, String? fontSrc}) async {
    final Uint8List? logoUint8List;
    final Font? font;

    if (logoSrc == null) {
      logoUint8List = null;
    } else {
      ByteData logoByteData = await rootBundle.load(logoSrc);
      logoUint8List = logoByteData.buffer.asUint8List();
    }

    if (fontSrc == null) {
      font = null;
    } else {
      ByteData fontByteData = await rootBundle.load(fontSrc);
      font = Font.ttf(fontByteData.buffer.asByteData());
    }

    final title = buildTitle(itemModel, logoUint8List: logoUint8List, font: font);
    final body = buildBody(itemModel, font: font);
    // final total = buildTotal(itemModel);

    _pdfDocument.addPage(MultiPage(
      build: (context) => [
        title,
        SizedBox(height: 0.5 * PdfPageFormat.cm),
        Text('$fileName Details'),
        SizedBox(height: 0.5 * PdfPageFormat.cm),
        body,
        //     Divider(),
        //   total,
      ],
      footer: (context) => buildFooter(),
    ));

    // Save the PDF locally
    final directory = await getApplicationDocumentsDirectory();

    final updatedFileName = '${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = '${directory.path}/$updatedFileName';

    final file = File(filePath);
    await file.writeAsBytes(await _pdfDocument.save());
    return filePath;
  }
}
