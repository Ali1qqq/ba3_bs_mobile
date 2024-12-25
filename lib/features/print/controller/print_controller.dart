import 'dart:async';

import 'package:ba3_bs_mobile/core/constants/app_assets.dart';
import 'package:ba3_bs_mobile/core/constants/printer_constants.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/translation/implementations/translation_repo.dart';
import '../../../core/styling/printer_text_styles.dart';
import '../../bill/data/models/invoice_record_model.dart';
import '../../materials/data/models/material_model.dart';
import '../ui/widgets/printing_loading_dialog.dart';

class PrintingController extends GetxController {
  final TranslationRepository _translationRepository;

  PrintingController(this._translationRepository);

  bool isPrinterConnected = false;
  List<BluetoothInfo> bluetoothDevices = [];

  RxString loadingDots = ''.obs;
  Timer? _loadingAnimationTimer;

  @override
  void onInit() {
    super.onInit();
    _startLoadingDotsAnimation();
  }

  @override
  void onClose() {
    _loadingAnimationTimer?.cancel();
    super.onClose();
  }

  void _startLoadingDotsAnimation() {
    _loadingAnimationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      loadingDots.value = loadingDots.value.length < 3 ? '${loadingDots.value}.' : '';
    });
  }

  Future<void> startPrinting(
      {required int billNumber, required List<InvoiceRecordModel> invRecords, required String invDate}) async {
    _showLoadingDialog();

    await _printBill(billNumber: billNumber, invRecords: invRecords, invDate: invDate);

    _dismissLoadingDialog();
    Get.delete<PrintingController>();
  }

  /// Displays a loading dialog during the printing process
  void _showLoadingDialog() {
    Get.defaultDialog(
      title: '',
      content: const PrintingLoadingDialog(),
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      radius: 8,
    );
  }

  void _dismissLoadingDialog() => Get.back();

  Future<void> _printBill(
      {required int billNumber, required List<InvoiceRecordModel> invRecords, required String invDate}) async {
    List<BluetoothInfo> bluetoothDevices = await _fetchPairedBluetoothDevices();

    const String targetPrinterMacAddress = PrinterConstants.printerMacAddress;

    // Check if the specified printer is among the paired devices
    bool isPrinterAvailable =
        bluetoothDevices.any((device) => device.macAdress.toLowerCase() == targetPrinterMacAddress.toLowerCase());

    if (isPrinterAvailable) {
      if (!isPrinterConnected) await _connectToPrinter(targetPrinterMacAddress);

      await _sendBillToPrinter(invRecords, invDate, billNumber);
    } else {
      debugPrint('Cannot find the printer');
    }
  }

  // Retrieves a list of paired Bluetooth devices
  Future<List<BluetoothInfo>> _fetchPairedBluetoothDevices() async {
    bluetoothDevices = await PrintBluetoothThermal.pairedBluetooths;
    debugPrint('isPermissionBluetoothGranted ${await PrintBluetoothThermal.isPermissionBluetoothGranted}');
    return bluetoothDevices;
  }

  // Connects to the printer using its MAC address
  Future<void> _connectToPrinter(String mac) async {
    isPrinterConnected = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    debugPrint('Connection status: $isPrinterConnected');
  }

  // Disconnects from the printer
  Future<void> _disconnectFromPrinter() async {
    isPrinterConnected = !(await PrintBluetoothThermal.disconnect);
    debugPrint('Disconnect status: $isPrinterConnected');
  }

  // Sends the print data to the printer if connected
  Future<void> _sendBillToPrinter(List<InvoiceRecordModel> invRecords, String invDate, int billNumber) async {
    if (await PrintBluetoothThermal.connectionStatus) {
      List<int> ticket = await _generateBillPrintData(invRecords, invDate, billNumber);

      // Write bytes to the printer
      await PrintBluetoothThermal.writeBytes(ticket);
    } else {
      await _disconnectFromPrinter();
      debugPrint('Print connection status: false');
    }
  }

  // Generates the print data for the invoice
  Future<List<int>> _generateBillPrintData(
      List<InvoiceRecordModel> invoiceRecords, String invoiceDate, int billNumber) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = generator.reset();

    // Header
    bytes += generator.text(PrinterConstants.invoiceTitle, styles: PrinterTextStyles.centered, linesAfter: 1);
    bytes += await _generateLogo(generator);
    bytes += _createHeaderSection(generator, invoiceDate, billNumber);

    // Process Items
    final result = await _generateItemsDetailsAndTotals(generator, invoiceRecords);
    bytes += result.bytes;

    // Totals Summary
    bytes += _generateTotalSummary(generator, result.totals['netAmount']!, result.totals['vatAmount']!);

    // Footer
    bytes += _createFooterSection(generator);

    return bytes;
  }

// Processes each invoice record, calculates totals, and adds item details to the print data
  Future<({List<int> bytes, Map<String, double> totals})> _generateItemsDetailsAndTotals(
      Generator generator, List<InvoiceRecordModel> invoiceRecords) async {
    double netAmount = 0;
    double vatAmount = 0;
    List<int> itemBytes = [];

    final materialController = read<MaterialController>();

    for (var record in invoiceRecords) {
      final material = materialController.getMaterialById(record.invRecId!);
      final recordTotals = _computeRecordTotals(record);

      // Update totals
      netAmount += recordTotals['netTotal']!;
      vatAmount += recordTotals['vatTotal']!;

      // Generate item details
      itemBytes += await _generateItemDetails(generator, material, record, recordTotals);
    }

    return (bytes: itemBytes, totals: {'netAmount': netAmount, 'vatAmount': vatAmount});
  }

// Calculates totals for an invoice record
  Map<String, double> _computeRecordTotals(InvoiceRecordModel record) {
    final unitPriceWithVat = record.invRecTotal! / record.invRecQuantity!;
    final vatPerUnit = unitPriceWithVat * 0.05;
    final netPerUnit = unitPriceWithVat - vatPerUnit;

    return {
      'unitPriceWithVat': unitPriceWithVat,
      'vatPerUnit': vatPerUnit,
      'netPerUnit': netPerUnit,
      'lineTotal': record.invRecTotal!,
      'netTotal': record.invRecQuantity! * netPerUnit,
      'vatTotal': record.invRecQuantity! * vatPerUnit,
    };
  }

// Generates the item details for each invoice record
  Future<List<int>> _generateItemDetails(
      Generator generator, MaterialModel material, InvoiceRecordModel record, Map<String, double> totals) async {
    final itemName = (material.matName ?? '').substring(0, (material.matName?.length ?? 0).clamp(0, 64));
    final translatedName = await _translationRepository.translateText(itemName);

    return [
      ...generator.text(translatedName, styles: PrinterTextStyles.left),
      ...generator.text(material.matBarCode ?? '', styles: PrinterTextStyles.left),
      ...generator.text(
        '${record.invRecQuantity} x ${totals['unitPriceWithVat']!.toStringAsFixed(2)} -> '
        '${PrinterConstants.totalLabel}${totals['lineTotal']!.toStringAsFixed(2)}',
        styles: PrinterTextStyles.left,
        linesAfter: 1,
      ),
    ];
  }

  // Generates the logo image for printing
  Future<List<int>> _generateLogo(Generator generator) async {
    try {
      final ByteData data = await rootBundle.load(AppAssets.ba3Logo);
      final Uint8List imageBytes = data.buffer.asUint8List();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image != null) {
        final img.Image resizedImage = img.copyResize(image, width: 200);
        return generator.imageRaster(resizedImage);
      } else {
        debugPrint('Failed to decode the image');
      }
    } catch (e) {
      debugPrint('Error generating logo: $e');
    }
    return [];
  }

  List<int> _createHeaderSection(Generator generator, String date, int billNumber) {
    return [
      ...generator.emptyLines(2),
      ...generator.text(PrinterConstants.storeName, styles: PrinterTextStyles.boldCentered),
      ...generator.emptyLines(1),
      ...generator.text('${PrinterConstants.dateLabel}$date', styles: PrinterTextStyles.left),
      ...generator.text('${PrinterConstants.billNumberLabel}$billNumber', styles: PrinterTextStyles.left),
      ...generator.text(PrinterConstants.trnNumber, styles: PrinterTextStyles.left, linesAfter: 1),
    ];
  }

  List<int> _generateTotalSummary(Generator generator, double netTotal, double vatTotal) {
    return [
      ...generator.text('${PrinterConstants.totalVatLabel}${vatTotal.toStringAsFixed(2)}',
          styles: PrinterTextStyles.centered),
      ...generator.text('-' * 30, styles: PrinterTextStyles.right),
      ...generator.text('${PrinterConstants.subTotalLabel}${netTotal.toStringAsFixed(2)} AED',
          styles: PrinterTextStyles.rightBold),
      ...generator.text('${PrinterConstants.vatLabel}${vatTotal.toStringAsFixed(2)} AED',
          styles: PrinterTextStyles.rightBold),
      ...generator.text('${PrinterConstants.totalLabel}${(netTotal + vatTotal).toStringAsFixed(2)} AED',
          styles: PrinterTextStyles.rightBold),
      ...generator.emptyLines(1),
    ];
  }

  List<int> _createFooterSection(Generator generator) {
    return [
      ...generator.text(PrinterConstants.storeLocation, styles: PrinterTextStyles.centered),
      ...generator.text(PrinterConstants.contactNumber, styles: PrinterTextStyles.centered),
      ...generator.text(PrinterConstants.thankYouMessage, styles: PrinterTextStyles.boldCentered),
      ...generator.emptyLines(2),
    ];
  }
}
