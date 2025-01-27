import 'dart:typed_data';

import 'package:pdf/widgets.dart';

abstract class IPdfGenerator<T> {
  /// Generates a PDF and returns the file path.
  Future<String> generatePdf(T itemModel, String fileName, {String? logoSrc, String? fontSrc});

  Widget buildFooter();

  Widget buildHeader(T itemModel, String fileName, {Uint8List? logoUint8List, Font? font});

  List<Widget> buildBody(T itemModel, {Font? font});
}
