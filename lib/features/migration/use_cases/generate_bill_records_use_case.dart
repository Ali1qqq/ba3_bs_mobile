import 'dart:isolate';

import '../../../core/constants/app_constants.dart';
import '../../bill/data/models/invoice_record_model.dart';
import '../../materials/data/models/materials/material_model.dart';

class GenerateBillRecordsUseCase {
  Future<List<InvoiceRecordModel>> execute(List<MaterialModel> materials) async {
    final ReceivePort receivePort = ReceivePort();

    // Convert materials to a JSON-serializable format before sending to the isolate
    final List<Map<String, dynamic>> materialsJson = materials.map((m) => m.toJson()).toList();

    final Isolate isolate = await Isolate.spawn(
      _generateBillRecordsIsolate,
      [receivePort.sendPort, materialsJson],
    );

    final List<Map<String, dynamic>> billRecordsJson = await receivePort.first as List<Map<String, dynamic>>;

    // Convert JSON results back to `InvoiceRecordModel`
    List<InvoiceRecordModel> billRecords = billRecordsJson.map((recordJson) => InvoiceRecordModel.fromJson(recordJson)).toList();

    // Cleanup: Close the isolate and receive port
    receivePort.close();
    isolate.kill(priority: Isolate.immediate);

    return billRecords;
  }

  static void _generateBillRecordsIsolate(List<dynamic> args) {
    final SendPort sendPort = args[0];
    final List<Map<String, dynamic>> materialsJson = args[1];

    // Convert JSON back to objects
    final List<MaterialModel> materials = materialsJson.map((m) => MaterialModel.fromJson(m)).toList();

    // Process invoice records
    final List<InvoiceRecordModel> result = _processBillRecords(materials);

    // Convert `InvoiceRecordModel` to JSON before sending back
    final List<Map<String, dynamic>> resultJson = result.map((record) => record.toJson()).toList();

    sendPort.send(resultJson);
  }

  static List<InvoiceRecordModel> _processBillRecords(List<MaterialModel> materials) {
    final List<InvoiceRecordModel> invoiceRecords = materials.expand((material) => _processMaterial(material)).toList();

    return invoiceRecords;
  }

  static List<InvoiceRecordModel> _processMaterial(MaterialModel materialModel) {
    List<InvoiceRecordModel> invoiceRecords = [];

    List<String> soldSerials = materialModel.serialNumbers?.entries.where((entry) => entry.value).map((entry) => entry.key).toList() ?? [];

    double vatRatio = 0;

    if (soldSerials.isNotEmpty) {
      for (String serial in soldSerials) {
        Map<String, dynamic> row = _rowToJson(materialModel, serial);
        invoiceRecords.add(InvoiceRecordModel.fromJsonPluto(materialModel.id!, row, vatRatio));
      }
    } else {
      Map<String, dynamic> row = _rowToJson(materialModel, null);
      invoiceRecords.add(InvoiceRecordModel.fromJsonPluto(materialModel.id!, row, vatRatio));
    }

    return invoiceRecords;
  }

  static Map<String, dynamic> _rowToJson(MaterialModel material, String? specificSerial) {
    return {
      AppConstants.invRecProduct: material.matName,
      AppConstants.invRecQuantity: material.matQuantity,
      AppConstants.invRecTotal: (material.matQuantity ?? 0) * (material.calcMinPrice ?? 0),
      AppConstants.invRecProductSoldSerial: specificSerial,
      AppConstants.invRecProductSerialNumbers: material.serialNumbers?.keys.toList(),
    };
  }
}
