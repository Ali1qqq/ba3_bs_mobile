import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../features/materials/controllers/material_controller.dart';
import '../extensions/getx_controller_extensions.dart';

mixin PdfHelperMixin {
  final _materialController = read<MaterialController>();

  Widget buildLogo(Uint8List logoUint8List) {
    return Image(
      MemoryImage(logoUint8List),
      width: 5 * PdfPageFormat.cm,
      height: 5 * PdfPageFormat.cm,
    );
  }

  Widget buildBarcode(String itemGuid) {
    return BarcodeWidget(
      barcode: Barcode.code128(),
      data: _materialController.getMaterialBarcodeById(itemGuid),
      width: 100,
      height: 40,
    );
  }

  Widget buildTitleText(
    String text,
    double size,
    Font? font, [
    FontWeight? weight,
  ]) {
    return Text(
      text,
      textDirection: TextDirection.rtl,
      style: TextStyle(fontSize: size, fontWeight: weight, font: font),
    );
  }

  Widget buildTextCell(String? value, Font? font) {
    final textValue = value ?? 'Unknown';

    // Detect Arabic and English characters
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');

    // Split the text into words
    final words = textValue.split(RegExp(r'\s+'));

    final spans = <InlineSpan>[];

    for (final word in words) {
      final containsArabic = arabicRegex.hasMatch(word);
      final textDirection = containsArabic ? TextDirection.rtl : TextDirection.ltr;

      spans.add(
        WidgetSpan(
          child: Directionality(
            textDirection: textDirection,
            child: Text(
              word,
              style: TextStyle(
                font: font,
                fontSize: 10,
              ),
            ),
          ),
        ),
      );

      // Add a space after each word (except the last)
      if (word != words.last) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    // Overall direction is set to LTR for consistent layout
    return RichText(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
    );
  }

  TextDirection _getTextDirection(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;

  Widget buildSpacing() => SizedBox(height: 0.4 * PdfPageFormat.cm);

  InlineSpan buildTextSpan(String text, Font? font) {
    final textDirection = _getTextDirection(text);
    return WidgetSpan(
      child: Directionality(
        textDirection: textDirection,
        child: Text(
          text,
          style: TextStyle(font: font),
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value, [Font? font]) {
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: [
          buildTextSpan(title, font),
          buildTextSpan(value, font),
        ],
      ),
    );
  }
}
