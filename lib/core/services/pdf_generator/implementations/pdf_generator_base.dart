import 'dart:developer';
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
  Widget buildHeader(T itemModel, String fileName, {Uint8List? logoUint8List, Font? font});

  @override
  List<Widget> buildBody(T itemModel, {Font? font});

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
  Future<String> generatePdf(T itemModel, String fileName, {String? logoSrc, String? fontSrc}) async {
    final Uint8List? logoUint8List;
    final Font? font;

    // Load the logo if provided
    if (logoSrc == null) {
      logoUint8List = null;
    } else {
      ByteData logoByteData = await rootBundle.load(logoSrc);
      logoUint8List = logoByteData.buffer.asUint8List();
    }

    // Load the font if provided
    if (fontSrc == null) {
      font = null;
    } else {
      log('fontSrc $fontSrc');
      ByteData fontByteData = await rootBundle.load(fontSrc);
      font = Font.ttf(fontByteData.buffer.asByteData());
    }

    _pdfDocument.addPage(
      MultiPage(
        header: (context) {
          // Display the header only on the first page
          if (context.pageNumber == 1) {
            return buildHeader(itemModel, fileName, logoUint8List: logoUint8List, font: font);
          }
          return SizedBox.shrink(); // Return an empty container instead of null
        },
        build: (context) => buildBody(itemModel, font: font),
        footer: (context) {
          // Display the footer only on the last page
          if (context.pageNumber == context.pagesCount) {
            return buildFooter();
          }
          return SizedBox.shrink(); // Return an empty container instead of null
        },
      ),
    );

    // Save the PDF locally
    final directory = await getApplicationDocumentsDirectory();

    final updatedFileName = '${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = '${directory.path}/$updatedFileName';

    final file = File(filePath);
    await file.writeAsBytes(await _pdfDocument.save());
    return filePath;
  }
}
