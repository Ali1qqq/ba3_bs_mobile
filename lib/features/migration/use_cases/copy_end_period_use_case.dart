import 'dart:developer';

import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/invoice_record_model.dart';
import 'package:ba3_bs_mobile/features/bill/use_cases/convert_bills_to_linked_list_use_case.dart';
import 'package:ba3_bs_mobile/features/bill/use_cases/divide_large_bill_use_case.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import 'generate_bill_records_use_case.dart';

class CopyEndPeriodUseCase {
  final GenerateBillRecordsUseCase _generateBillRecordsUseCase;
  final DivideLargeBillUseCase _divideLargeBillUseCase;
  final ConvertBillsToLinkedListUseCase _convertBillsToLinkedListUseCase;
  final Future<EntitySequence> Function(String, String) fetchAndIncrementEntityNumber;
  final Future<void> Function(BillModel) saveBill;
  final Future<void> Function(String, String, int) setLastUsedNumber;
  final bool Function(String) migrationGuard;

  CopyEndPeriodUseCase({
    required GenerateBillRecordsUseCase generateBillRecordsUseCase,
    required DivideLargeBillUseCase divideLargeBillUseCase,
    required ConvertBillsToLinkedListUseCase convertBillsToLinkedListUseCase,
    required this.fetchAndIncrementEntityNumber,
    required this.saveBill,
    required this.setLastUsedNumber,
    required this.migrationGuard,
  })  : _generateBillRecordsUseCase = generateBillRecordsUseCase,
        _divideLargeBillUseCase = divideLargeBillUseCase,
        _convertBillsToLinkedListUseCase = convertBillsToLinkedListUseCase;

  Future<void> execute(String currentVersion) async {
    if (migrationGuard(currentVersion)) return;

    final billTypeModel = BillType.firstPeriodInventory.billTypeModel;
    final materials = read<MaterialController>().materials;

    // ✅ Now, all GetX-related calls happen before spawning the isolate
    List<InvoiceRecordModel> billRecords = await _generateBillRecordsUseCase.execute(materials);

    double billTotal = billRecords.fold(0, (sum, record) => sum + (record.invRecTotal ?? 0));

    List<BillModel> linkedBills = [];

    final billModel = BillModel.fromBillData(
      status: Status.approved,
      billPayType: InvPayType.cash.index,
      billDate: DateTime.now(),
      billCustomerId: '',
      billAccountId: '',
      billSellerId: '',
      billGiftsTotal: 0,
      billDiscountsTotal: 0,
      billAdditionsTotal: 0,
      billVatTotal: 0,
      billFirstPay: 0,
      billTotal: billTotal,
      billWithoutVatTotal: billTotal,
      billTypeModel: billTypeModel,
      billRecords: billRecords,
    );

    final entitySequence = await fetchAndIncrementEntityNumber(ApiConstants.bills, BillType.firstPeriodInventory.label);

    final updatedBill = billModel.copyWith(
      billId: BillType.firstPeriodInventory.label,
      billDetails: billModel.billDetails.copyWith(billNumber: entitySequence.nextNumber),
    );

    final List<BillModel> splitBills = _divideLargeBillUseCase.execute(updatedBill);

    // 🔹 Use the Use Case for linking bills
    linkedBills.assignAll(_convertBillsToLinkedListUseCase.execute(splitBills));

    for (int i = 0; i < linkedBills.length; i++) {
      await saveBill(linkedBills[i]);
    }

    await setLastUsedNumber(
      ApiConstants.bills,
      BillType.firstPeriodInventory.label,
      linkedBills.last.billDetails.billNumber!,
    );

    log("📌 End of year inventory quantities transferred. Total invoice: $billTotal");
  }
}