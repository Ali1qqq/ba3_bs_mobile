import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time_extensions.dart';
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
    // Create a list to collect the serial number models.
    final List<SerialNumberModel> items = [];

    if (billModel.billTypeModel.billPatternType == BillPatternType.purchase) {
      // Iterate through each material's controllers.
      serialControllers.forEach((material, controllers) {
        for (final controller in controllers) {
          final serialText = controller.text.trim();
          // If the text is not empty, create a SerialNumberModel.
          if (serialText.isNotEmpty) {
            items.add(
              SerialNumberModel(
                serialNumber: serialText,
                matId: material.id,
                matName: material.matName,
                buyBillId: billModel.billId,
                buyBillNumber: billModel.billDetails.billNumber,
                entryDate: billModel.billDetails.billDate,
                sold: false,
              ),
            );
          }
        }
      });

      // Save all the serial numbers using your repository.
      final result = await _serialNumbersRepo.saveAll(items);

      // Handle the result of the save operation.
      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (success) {
          // Update the material's serial numbers after saving successfully.
          serialControllers.forEach(
            (material, controllers) {
              final materialModel = read<MaterialController>().getMaterialById(material.id!);

              if (materialModel != null) {
                final updatedSerialNumbers = {
                  ...?materialModel.serialNumbers, // Preserve existing serials if any
                  for (final controller in controllers) controller.text.trim(): false, // New serials default to unsold
                };

                // Update the material model with new serial numbers
                read<MaterialController>().updateMaterial(materialModel.copyWith(serialNumbers: updatedSerialNumbers));
              }
            },
          );

          // Optionally, show a success message or perform further actions.
          AppUIUtils.onSuccess('Serial numbers saved successfully.');
        },
      );
    }
  }

  onSaveSerialsSuccess(
      {required Map<MaterialModel, List<TextEditingController>> serialControllers, required Map<String, bool> updatedSerialNumbers}) {
    // Update the material's serial numbers after saving successfully.
    serialControllers.forEach(
      (material, controllers) {
        final materialModel = read<MaterialController>().getMaterialById(material.id!);

        if (materialModel != null) {
          final updatedSerialNumbers = {
            ...?materialModel.serialNumbers, // Preserve existing serials if any
            for (final controller in controllers) controller.text.trim(): false, // New serials default to unsold
          };

          // Update the material model with new serial numbers
          read<MaterialController>().updateMaterial(materialModel.copyWith(serialNumbers: updatedSerialNumbers));
        }
      },
    );

    // Optionally, show a success message or perform further actions.
    AppUIUtils.onSuccess('Serial numbers saved successfully.');
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
      billSellerId: sellerController.selectedSellerAccount!.costGuid!,
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