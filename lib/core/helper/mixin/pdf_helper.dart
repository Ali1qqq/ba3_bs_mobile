import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../features/bill/data/models/bill_model.dart';
import '../../../features/materials/controllers/material_controller.dart';
import '../enums/enums.dart';
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
    double size, {
    Font? font,
    FontWeight? weight,
    PdfColor? color,
  }) {
    return Text(
      text,
      textDirection: TextDirection.rtl,
      style: TextStyle(fontSize: size, fontWeight: weight, font: font, color: color),
    );
  }

  String cleanText(String input) => input.replaceAll(RegExp(r'[\u200B-\u200D\u2060-\u206F]'), '');

  Widget buildTextCell(String? value, Font? font) {
    final textValue = value?.trim() ?? 'Unknown';
    final cleanTextValue = cleanText(textValue);

    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    final containsArabic = arabicRegex.hasMatch(cleanTextValue);

    // Split into words
    final words = cleanTextValue.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

    final spans = <InlineSpan>[];

    for (final word in words) {
      final isArabicWord = arabicRegex.hasMatch(word);
      final textDirection = isArabicWord ? TextDirection.rtl : TextDirection.ltr;

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

      if (word != words.last) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(children: spans),
      textDirection: containsArabic ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  TextDirection _getTextDirection(String text) =>
      RegExp(r'[\u0600-\u06FF]').hasMatch(text) ? TextDirection.rtl : TextDirection.ltr;

  Widget buildSpacing() => SizedBox(height: 0.4 * PdfPageFormat.cm);

  InlineSpan buildTextSpan(String text, PdfColor? valueColor, Font? font) {
    final textDirection = _getTextDirection(text);
    return WidgetSpan(
      child: Directionality(
        textDirection: textDirection,
        child: Text(
          text,
          style: TextStyle(font: font, color: valueColor),
        ),
      ),
    );
  }

  Widget buildDetailRow(String title, String value, {PdfColor? valueColor, Font? font}) {
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        children: [
          buildTextSpan(title, valueColor, font),
          buildTextSpan(value, valueColor, font),
        ],
      ),
    );
  } // Function to highlight differences

  Widget highlightChange(String? before, String? after, Font? font) {
    if (before != after) {
      return Text(
        after ?? '',
        textDirection: TextDirection.rtl,
        style: TextStyle(
          font: font,
          fontSize: 12,
          fontWeight: FontWeight.bold, // Make it bold
          color: PdfColors.red, // Change color to red
        ),
      );
    }
    return Text(
      after ?? '',
      textDirection: TextDirection.rtl,
      style: TextStyle(font: font, color: PdfColors.black),
    );
  }

  String getItemStatus(int? before, int? after) {
    if (before == after) return ''; // No change

    int beforeValue = before == null ? 0 : 1; // If `null`, treat as 0 (not existing)
    int afterValue = after == null ? 0 : 1;

    if (beforeValue == 0 && afterValue > 0) {
      return 'عنصر جديد'; // New item
    } else if (beforeValue > 0 && afterValue == 0) {
      return 'عنصر محذوف'; // Removed item
    } else {
      return 'عنصر معدل'; // Modified item
    }
  }

// Function to lighten a given color
  int lightenColor(int color, double factor) {
    Color original = Color(color); // Convert int to Color
    int r = ((original.r * (1 - factor)) + (255 * factor)).toInt();
    int g = ((original.g * (1 - factor)) + (255 * factor)).toInt();
    int b = ((original.b * (1 - factor)) + (255 * factor)).toInt();
    return Color.fromARGB(original.alpha, r, g, b).value; // Convert back to int
  }

  String billName(BillModel billModel) => BillType.byLabel(billModel.billTypeModel.billTypeLabel!).value;
}
