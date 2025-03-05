import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs_mobile/core/helper/validators/app_validator.dart';
import 'package:ba3_bs_mobile/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs_mobile/core/interfaces/i_store_selection_handler.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/bill/services/bill/bill_utils.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../materials/controllers/material_controller.dart';
import '../../../materials/data/models/materials/material_model.dart';
import '../../../materials/service/serial_number_model_factory.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../../print/controller/print_controller.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/invoice_record_model.dart';
import '../../services/bill/account_handler.dart';
import '../../services/bill/bill_service.dart';
import '../pluto/bill_details_pluto_controller.dart';

class BillDetailsController extends IBillController
    with AppValidator, AppNavigator, FirestoreSequentialNumbers
    implements IStoreSelectionHandler {
  // Repositories

  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;

  final QueryableSavableRepository<SerialNumberModel> _serialNumbersRepo;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillSearchController billSearchController;

  BillDetailsController(
    this._billsFirebaseRepo,
    this._serialNumbersRepo, {
    required this.billDetailsPlutoController,
    required this.billSearchController,
  });

  // Services
  late final BillDetailsService _billService;
  late final BillUtils _billUtils;
  late final AccountHandler _accountHandler;

  final formKey = GlobalKey<FormState>();
  final TextEditingController billNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController storeController = TextEditingController();
  final TextEditingController customerAccountController = TextEditingController();
  final TextEditingController sellerAccountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController firstPayController = TextEditingController();
  final TextEditingController invReturnDateController = TextEditingController();
  final TextEditingController invReturnCodeController = TextEditingController();
  final TextEditingController invFirstPayController = TextEditingController();

  AccountModel? selectedCustomerAccount;

  Rx<DateTime> billDate = DateTime.now().obs;

  Rx<InvPayType> selectedPayType = InvPayType.cash.obs;

  BillType billType = BillType.sales;
  bool isLoading = true;

  RxBool isBillSaved = false.obs;

  @override
  Rx<StoreAccount> selectedStore = StoreAccount.main.obs;

  bool get isCash => selectedPayType.value == InvPayType.cash;

  @override
  void onSelectedStoreChanged(StoreAccount? newStore) {
    if (newStore != null) {
      selectedStore.value = newStore;
    }
  }

  @override
  void updateCustomerAccount(AccountModel? newAccount) {
    if (newAccount != null) {
      selectedCustomerAccount = newAccount;
      customerAccountController.text = newAccount.accName!;
    }
  }

  @override
  Future<void> sendToEmail({required String recipientEmail, String? url, String? subject, String? body, List<String>? attachments}) async {
    _billService.sendToEmail(recipientEmail: recipientEmail, url: url, subject: subject, body: body, attachments: attachments);
  }

  @override
  set updateIsBillSaved(bool newValue) {
    isBillSaved.value = newValue;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  // Initializer
  void _initializeServices() {
    _billService = BillDetailsService(
      plutoController: billDetailsPlutoController,
      billDetailsController: this,
    );
    _billUtils = BillUtils();
    _accountHandler = AccountHandler();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void updateBillType(String billTypeLabel) => billType = BillType.byLabel(billTypeLabel);

  set setBillDate(DateTime newDate) {
    billDate.value = newDate;
    //   update();
  }

  void onPayTypeChanged(InvPayType? payType) {
    if (payType != null) {
      selectedPayType.value = payType;
      log('onPayTypeChanged');
    }
  }

  Future<void> printBill(
      {required BuildContext context, required BillModel billModel, required List<InvoiceRecordModel> invRecords}) async {
    if (!_billService.hasModelId(billModel.billId)) return;

    await read<PrintingController>().startPrinting(
      context: context,
      invRecords: invRecords,
      billNumber: billModel.billDetails.billNumber!,
      invDate: billDate.value.dayMonthYear,
    );
  }

  void createEntryBond(BillModel billModel, BuildContext context) {
    if (!validateForm()) return;

    _billService.launchFloatingEntryBondDetailsScreen(
      context: context,
      billModel: billModel,
    );
  }

  void updateBillStatus(BillModel billModel, newStatus) async {
    final result = await _billsFirebaseRepo.save(billModel.copyWith(status: newStatus));

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (updatedBillModel) => _billService.handleUpdateBillStatusSuccess(
        updatedBillModel: updatedBillModel,
        billSearchController: billSearchController,
      ),
    );
  }

  Future<void> deleteBill(BillModel billModel) async {
    final result = await _billsFirebaseRepo.delete(billModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => _billService.handleDeleteSuccess(billToDelete: billModel, billSearchController: billSearchController),
    );
  }

  /// Checks if deleting the bill would affect sold serial numbers.
  /// Returns `true` if deletion should be stopped.
/*
  Future<bool> _hasSoldSerialNumbers(BillModel billModel) async {
    final materialController = read<MaterialController>();

    for (BillItem item in billModel.items.itemList) {
      final mat = materialController.getMaterialById(item.itemGuid);
      final serialNumbers = item.itemSerialNumbers ?? [];

      if (mat?.serialNumbers != null) {
        for (final entry in mat!.serialNumbers!.entries) {
          if (serialNumbers.contains(entry.key) && entry.value) {
            int? sellBillNumber = await _getSellBillNumber(entry.key);

            AppUIUtils.onFailure(
              '⚠️ لا يمكن حذف هذه الفاتورة! \n\n'
              '🔹 المادة: ${mat.matName} (${mat.id})\n'
              '🔹 الرقم التسلسلي: [${entry.key}]\n'
              '🔹 تم بيعه بالفعل في فاتورة مبيعات ${sellBillNumber ?? ''}.\n\n'
              '❌ يرجى مراجعة الفواتير المرتبطة قبل المتابعة.',
            );
            return true; // Stop deletion
          }
        }
      }
    }
    return false; // Safe to delete
  }
*/

  /// Fetches the sell bill number for a given serial number.
/*  Future<int?> _getSellBillNumber(String serialNumber) async {
    final result = await _serialNumbersRepo.getById(serialNumber);

    return result.fold(
      (failure) => null, // Return null on failure
      (SerialNumberModel serialsModel) => serialsModel.transactions.isNotEmpty
          ? serialsModel.transactions.where((transaction) => transaction.sold ?? false).last.sellBillNumber
          : null,
    );
  }*/

  /// Deletes all sales transactions associated with a specific bill.
  Future<void> deleteSellSerialTransactions(BillModel billToDelete) async {
    for (final billItem in billToDelete.items.itemList) {
      final soldSerialNumber = billItem.soldSerialNumber;

      if (soldSerialNumber == null) {
        continue; // Skip if no serial number is linked
      }

      final result = await _serialNumbersRepo.getById(soldSerialNumber);

      result.fold(
        (failure) {
          log('❌ Failed to retrieve serial number [$soldSerialNumber]: ${failure.message}');
        },
        (SerialNumberModel serialsModel) async {
          // Filter out transactions related to the deleted bill
          final updatedTransactions =
              serialsModel.transactions.where((transaction) => transaction.sellBillId != billToDelete.billId).toList();

          if (updatedTransactions.length == serialsModel.transactions.length) {
            log('🔍 No transactions to delete for serial [$soldSerialNumber].');
            return;
          }

          // Update the serial number model with filtered transactions
          final updatedSerialModel = serialsModel.copyWith(transactions: updatedTransactions);

          // Update Firestore or local database with new transaction list
          final updateResult = await _serialNumbersRepo.save(updatedSerialModel);

          updateResult.fold(
            (failure) => log('❌ Failed to update transactions for serial [$soldSerialNumber]: ${failure.message}'),
            (success) => log('✅ Successfully removed transactions linked to bill [${billToDelete.billId}] for serial [$soldSerialNumber].'),
          );
        },
      );
    }
  }

  Future<void> deleteBuySerialTransactions(BillModel billToDelete) async {
    final materialController = read<MaterialController>();

    for (final billItem in billToDelete.items.itemList) {
      final materialModel = materialController.getMaterialById(billItem.itemGuid);
      final purchaseSerialNumbers = billItem.itemSerialNumbers ?? [];

      if (materialModel?.serialNumbers == null) {
        continue; // Skip if material or serial numbers are missing
      }

      final updatedSerialNumbers = Map<String, bool>.from(materialModel!.serialNumbers!);

      for (final serialNumber in purchaseSerialNumbers) {
        await _processSerialTransaction(billToDelete, materialModel, serialNumber, updatedSerialNumbers);
      }

      // Apply the updated serial numbers to the material model
      materialController.updateMaterial(materialModel.copyWith(serialNumbers: updatedSerialNumbers));
    }
  }

  /// Processes a single serial number transaction:
  /// Removes it if no transactions remain, or marks it as sold if transactions exist.
  Future<void> _processSerialTransaction(
    BillModel billToDelete,
    MaterialModel materialModel,
    String serialNumber,
    Map<String, bool> updatedSerialNumbers,
  ) async {
    final result = await _serialNumbersRepo.getById(serialNumber);

    await result.fold(
      (failure) async {
        log('❌ Failed to retrieve serial number [$serialNumber]: ${failure.message}');
      },
      (SerialNumberModel serialsModel) async {
        final updatedTransactions = serialsModel.transactions.where((transaction) => transaction.buyBillId != billToDelete.billId).toList();

        if (updatedTransactions.length == serialsModel.transactions.length) {
          log('🔍 No purchase transactions to delete for serial [$serialNumber].');
          return;
        }

        if (updatedTransactions.isEmpty) {
          // No transactions remain, so delete the serial document
          await _deleteSerialDocument(serialNumber, materialModel, updatedSerialNumbers);
        } else {
          // Update Firestore with filtered transactions
          final updatedSerialModel = serialsModel.copyWith(transactions: updatedTransactions);
          final updateResult = await _serialNumbersRepo.save(updatedSerialModel);

          await updateResult.fold(
            (failure) async {
              log('❌ Failed to update transactions for serial [$serialNumber]: ${failure.message}');
            },
            (success) async {
              log('✅ Successfully removed purchase transactions linked to bill [${billToDelete.billId}] for serial [$serialNumber].');
              _updateSerialNumberStatus(materialModel, serialNumber, updatedSerialNumbers, updatedTransactions);
            },
          );
        }
      },
    );
  }

  /// Deletes the serial document from Firestore if there are no transactions left.
  Future<void> _deleteSerialDocument(
    String serialNumber,
    MaterialModel materialModel,
    Map<String, bool> updatedSerialNumbers,
  ) async {
    final deleteResult = await _serialNumbersRepo.delete(serialNumber);

    await deleteResult.fold(
      (failure) async {
        log('❌ Failed to delete serial document [$serialNumber]: ${failure.message}');
      },
      (success) async {
        log('🗑️ Serial document [$serialNumber] deleted from Firestore.');
        updatedSerialNumbers.remove(serialNumber); // Remove from materialModel
      },
    );
  }

  /// Updates serial number status based on remaining transactions.
  void _updateSerialNumberStatus(
    MaterialModel materialModel,
    String serialNumber,
    Map<String, bool> updatedSerialNumbers,
    List<SerialTransactionModel> updatedTransactions,
  ) {
    if (updatedTransactions.isEmpty) {
      updatedSerialNumbers.remove(serialNumber);
      log('🗑️ Serial number [$serialNumber] removed from material (${materialModel.matName}).');
    } else {
      updatedSerialNumbers[serialNumber] = true;
      log('✅ Serial number [$serialNumber] of material (${materialModel.matName}) marked as sold.');
    }
  }

  Future<void> saveBill(BillTypeModel billTypeModel) async {
    await _saveOrUpdateBill(billTypeModel: billTypeModel);
  }

  Future<void> updateBill({required BillTypeModel billTypeModel, required BillModel billModel}) async {
    await _saveOrUpdateBill(billTypeModel: billTypeModel, existingBill: billModel);
  }

  Future<void> _saveOrUpdateBill({required BillTypeModel billTypeModel, BillModel? existingBill}) async {
    // Validate the form first
    if (!validateForm()) return;

    // 2. Create the bill model or handle failure and exit
    final updatedBillModel = _buildBillModelOrNotifyFailure(billTypeModel, existingBill);
    if (updatedBillModel == null) return;

    // Ensure there are bill items
    if (!_billService.hasModelItems(updatedBillModel.items.itemList)) return;

    if (_isNoUpdate(existingBill, updatedBillModel)) return;

    await _saveBillAndHandleResult(updatedBillModel, existingBill);
  }

  /// Checks if there's actually no change from the existing bill.
  bool _isNoUpdate(BillModel? existingBill, BillModel updatedBill) {
    final isNoUpdate = existingBill != null && updatedBill == existingBill;

    if (isNoUpdate) AppUIUtils.onFailure('لم يتم تحديث اي شئ في الفاتورة');
    return isNoUpdate;
  }

  /// Saves the [updatedBill] and handles success/failure UI feedback.
  Future<void> _saveBillAndHandleResult(BillModel updatedBill, BillModel? existingBill) async {
    final result = await _billsFirebaseRepo.save(updatedBill);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedBill) {
        _billService.handleSaveOrUpdateSuccess(
          previousBill: existingBill,
          currentBill: savedBill,
          billSearchController: billSearchController,
          isSave: existingBill == null,
        );
      },
    );
  }

  Future<void> saveSerialNumbers(BillModel billModel, Map<MaterialModel, List<TextEditingController>> serialControllers) async {
    log('saveSerialNumbers $serialControllers');

    // Create a list to collect the serial number models.
    final List<SerialNumberModel> items = [];

    // Iterate through each material's controllers.
    serialControllers.forEach(
      (MaterialModel material, List<TextEditingController> serials) {
        for (final TextEditingController serialController in serials) {
          final serialText = serialController.text.trim();
          log('serialText $serialText');

          // If the text is not empty, create a SerialNumberModel.
          if (serialText.isNotEmpty) {
            final SerialNumberModel serialNumberModel =
                SerialNumberModelFactory.getModel(serialText, billModel: billModel, material: material);
            items.add(serialNumberModel);
          }
        }
      },
    );

    // Save all the serial numbers using your repository.
    final result = await _serialNumbersRepo.saveAll(items);

    // Handle the result of the save operation.
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (List<SerialNumberModel> savedSerialsModels) => onSaveSerialsSuccess(serialControllers, savedSerialsModels),
    );
  }

  void onSaveSerialsSuccess(Map<MaterialModel, List<TextEditingController>> serialControllers, List<SerialNumberModel> savedSerialsModels) {
    serialControllers.forEach((MaterialModel material, List<TextEditingController> serials) {
      final materialModel = read<MaterialController>().getMaterialById(material.id!);

      for (final serial in savedSerialsModels) {
        log('onSaveSerialsSuccess serial: ${serial.toJson()}');
      }

      if (materialModel != null) {
        // Ensure non-null keys and values
        final Map<String, bool> updatedSerialNumbers = {
          ...?materialModel.serialNumbers, // Preserve existing serials
          for (final serial in savedSerialsModels.where((s) => s.matId == material.id))
            if (serial.serialNumber != null && serial.transactions.last.sold != null) serial.serialNumber!: serial.transactions.last.sold!,
        };

        // Update the material model with new serial numbers
        read<MaterialController>().updateMaterial(materialModel.copyWith(serialNumbers: updatedSerialNumbers));
      }
    });
  }

  Future<Either<Failure, BillModel>> updateOnly(BillModel bill) async {
    final result = await _billsFirebaseRepo.save(bill);

    return result;
  }

  appendNewBill({required BillTypeModel billTypeModel, required int lastBillNumber, int? previousBillNumber}) {
    BillModel newBill =
        BillModel.empty(billTypeModel: billTypeModel, lastBillNumber: lastBillNumber, previousBillNumber: previousBillNumber);

    billSearchController.insertLastAndUpdate(newBill);
  }

  /// Builds the new [BillModel] from the form data.
  /// If required fields are missing, shows a failure message and returns `null`.
  BillModel? _buildBillModelOrNotifyFailure(BillTypeModel billTypeModel, BillModel? existingBill) {
    final updatedBillModel = _createBillModelFromBillData(billTypeModel, existingBill);

    if (updatedBillModel == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل واسم البائع!');
      return null;
    }

    return updatedBillModel;
  }

  BillModel? _createBillModelFromBillData(BillTypeModel billTypeModel, [BillModel? billModel]) {
    final sellerController = read<SellersController>();

    // Validate customer and seller accounts
    if (billTypeModel.billPatternType!.hasCashesAccount || billTypeModel.billPatternType!.hasMaterialAccount) {
      if (!_billUtils.validateCustomerAccount(selectedCustomerAccount)) {
        return null;
      }
    }

    if (!_billUtils.validateSellerAccount(sellerController.selectedSellerAccount)) {
      return null;
    }

    final updatedBillTypeModel = _accountHandler.updateBillTypeAccounts(
          billTypeModel,
          billDetailsPlutoController.generateDiscountsAndAdditions,
          selectedCustomerAccount,
          selectedStore.value,
        ) ??
        billTypeModel;

    // Create and return the bill model
    return _billService.createBillModel(
      billModel: billModel,
      billNote: noteController.text,
      billTypeModel: updatedBillTypeModel,
      billDate: billDate.value,
      billFirstPay: firstPayController.text.toDouble,
      billCustomerId: selectedCustomerAccount?.id! ?? "00000000-0000-0000-0000-000000000000",
      billSellerId: sellerController.selectedSellerAccount!.costGuid ?? '',
      billPayType: selectedPayType.value.index,
    );
  }

  Future<int> getLastBillNumberForType(BillTypeModel billTypeModel) async {
    int billsCountByType = await getLastNumber(
      category: ApiConstants.bills,
      entityType: billTypeModel.billTypeLabel!,
    );

    return billsCountByType;
  }

  prepareBillRecords(BillItems billItems, BillDetailsPlutoController billDetailsPlutoController) =>
      billDetailsPlutoController.prepareBillMaterialsRows(
        billItems.getMaterialRecords,
      );

  prepareAdditionsDiscountsRecords(BillModel billModel, BillDetailsPlutoController billDetailsPlutoController) =>
      billDetailsPlutoController.prepareAdditionsDiscountsRows(billModel.getAdditionsDiscountsRecords);

  initCustomerAccount(AccountModel? account) {
    if (account != null) {
      selectedCustomerAccount = account;
      customerAccountController.text = account.accName!;
    }
  }

  initBillNumberController(int? billNumber) {
    if (billNumber != null) {
      billNumberController.text = billNumber.toString();
    } else {
      billNumberController.text = '';
    }
  }

  void updateBillDetailsOnScreen(BillModel bill, BillDetailsPlutoController billPlutoController) {
    onPayTypeChanged(InvPayType.fromIndex(bill.billDetails.billPayType!));

    setBillDate = bill.billDetails.billDate!;
    isBillSaved.value = bill.billId != null;
    noteController.text = bill.billDetails.billNote ?? '';
    firstPayController.text = (bill.billDetails.billFirstPay ?? 0.0).toString();

    initBillNumberController(bill.billDetails.billNumber);

    initCustomerAccount(bill.billTypeModel.accounts?[BillAccounts.caches]);

    read<SellersController>().initSellerAccount(sellerId: bill.billDetails.billSellerId, billDetailsController: this);

    prepareBillRecords(bill.items, billPlutoController);
    prepareAdditionsDiscountsRecords(bill, billPlutoController);

    billPlutoController.update();
  }

  generateAndSendBillPdf(BillModel billModel) {
    if (!_billService.hasModelId(billModel.billId)) return;

    if (!_billService.hasModelItems(billModel.items.itemList)) return;

    _billService.generateAndSendPdf(
      fileName: AppStrings.existedBill.tr,
      itemModel: billModel,
    );
  }

  showEInvoiceDialog(BillModel billModel, BuildContext context) => _billService.showEInvoiceDialog(billModel, context);

  void openFirstPayDialog(BuildContext context) => _billService.showFirstPayDialog(context, firstPayController);

  /// this for mobile
  showBarCodeScanner(BuildContext context, BillTypeModel billTypeModel) => _billService.showBarCodeScanner(
      context: context,
      stateManager: billDetailsPlutoController.recordsTableStateManager,
      plutoController: billDetailsPlutoController,
      billTypeModel: billTypeModel);
}