import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class PrinterTextStyles {
  static const centered = PosStyles(align: PosAlign.center);
  static const left = PosStyles(align: PosAlign.left);
  static const right = PosStyles(align: PosAlign.right);
  static const boldCentered = PosStyles(align: PosAlign.center, bold: true);
  static const rightBold = PosStyles(align: PosAlign.right, bold: true);
}
