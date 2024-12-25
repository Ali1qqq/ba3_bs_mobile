import 'dart:typed_data';

import 'package:pdf/widgets.dart';

abstract class IPdfGenerator<T> {
  /// Generates a PDF and returns the file path.
  Future<String> generatePdf(T itemModel, String fileName, {String? logoSrc, String? fontSrc});

  Widget buildFooter();

  Widget buildSimpleText({required String title, required String value});

  Widget buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  });

  Widget buildTitle(T itemModel, {Uint8List? logoUint8List, Font? font});

  Widget buildBody(T itemModel, {Font? font});
}
