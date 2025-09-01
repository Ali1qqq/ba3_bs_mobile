import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../controllers/material_controller.dart';
import '../widgets/scanner_overlay_painter.dart';

class SearchMaterialScreen extends StatelessWidget {
  const SearchMaterialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MaterialController>();
    final materialTextController = TextEditingController();
    final cameraController = MobileScannerController();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: CustomTextFieldWithoutIcon(
          textEditingController: materialTextController,
          hintText: "أدخل الباركود أو الرقم",
          onSubmitted: (value) async {
            if (value.isNotEmpty) {
              controller.getMaterialByBarcode(value, context);
            }
          },
          suffixIcon: Obx(() {
            return IconButton(
              icon: Icon(!controller.isScannerOpen.value ? Icons.qr_code_scanner : Icons.text_fields_rounded, color: Colors.blueAccent),
              onPressed: () {
                controller.isScannerOpen.toggle();
              },
            );
          }),
        ),
      ),
      body: Obx(() {
        if (controller.isScannerOpen.value) {
          return Stack(
            children: [
              MobileScanner(
                controller: cameraController,
                onDetect: (capture) {
                  if (controller.isProcessing) return;
                  for (final barcode in capture.barcodes) {
                    final code = barcode.rawValue;
                    if (code != null) {
                      controller.isProcessing = true;
                      materialTextController.text = code;
                      controller.getMaterialByBarcode(code, context).then((_) {
                        controller.isProcessing = false;
                        controller.isScannerOpen.value = false; // إغلاق الكاميرا
                      });
                      break;
                    }
                  }
                },
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  double overlaySize = constraints.maxWidth * 0.7;
                  final centerX = constraints.maxWidth / 2;
                  final centerY = constraints.maxHeight / 2;

                  return CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: ScannerOverlayPainter(
                      centerX: centerX,
                      centerY: centerY,
                      size: overlaySize,
                    ),
                  );
                },
              ),
              // نص إرشادي متحرك في وسط الشاشة
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 250),
                  child: Text(
                    "وجّه الباركود داخل الإطار",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.qr_code_scanner, size: 120, color: Colors.blueAccent.withValues(alpha: 0.7)),
                onPressed: () {
                  controller.isScannerOpen.toggle();
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "اكتب الباركود أو اضغط زر المسح",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          controller.deleteAllMaterialFromLocal();
        },
        child: const Icon(Icons.refresh_outlined),
      ),
    );
  }
}