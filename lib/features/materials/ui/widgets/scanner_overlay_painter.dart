import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  final double centerX;
  final double centerY;
  final double size;

  ScannerOverlayPainter({
    required this.centerX,
    required this.centerY,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final overlayRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: size,
      height: size,
    );

    // Dark background
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final fullRect = Path()
      ..addRect(Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
    final cutOut = Path()..addRect(overlayRect);
    final result = Path.combine(PathOperation.difference, fullRect, cutOut);
    canvas.drawPath(result, paint);

    // Draw corner borders only
    final borderPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    double corner = 30;
    // top-left
    canvas.drawLine(overlayRect.topLeft,
        overlayRect.topLeft.translate(corner, 0), borderPaint);
    canvas.drawLine(overlayRect.topLeft,
        overlayRect.topLeft.translate(0, corner), borderPaint);

    // top-right
    canvas.drawLine(overlayRect.topRight,
        overlayRect.topRight.translate(-corner, 0), borderPaint);
    canvas.drawLine(overlayRect.topRight,
        overlayRect.topRight.translate(0, corner), borderPaint);

    // bottom-left
    canvas.drawLine(overlayRect.bottomLeft,
        overlayRect.bottomLeft.translate(corner, 0), borderPaint);
    canvas.drawLine(overlayRect.bottomLeft,
        overlayRect.bottomLeft.translate(0, -corner), borderPaint);

    // bottom-right
    canvas.drawLine(overlayRect.bottomRight,
        overlayRect.bottomRight.translate(-corner, 0), borderPaint);
    canvas.drawLine(overlayRect.bottomRight,
        overlayRect.bottomRight.translate(0, -corner), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}