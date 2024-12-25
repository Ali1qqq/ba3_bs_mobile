import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/validators/app_validator.dart';
import 'package:ba3_bs_mobile/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs_mobile/core/router/app_routes.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/datasource_repo.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/pluto/add_bill_pluto_controller.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/e_invoice_dialog_content.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/interfaces/i_store_selection_handler.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../../print/controller/print_controller.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/invoice_record_model.dart';
import '../../services/bill/bill_pdf_generator.dart';
import '../../services/bill/bill_service.dart';
import '../pluto/bill_details_pluto_controller.dart';
import 'all_bills_controller.dart';
import 'bill_details_controller.dart';
import 'bill_search_controller.dart';

class AddBillController extends IBillController with AppValidator implements IStoreSelectionHandler {
  // Repositories
  final DataSourceRepository<BillModel> _billsFirebaseRepo;
  final AddBillPlutoController addBillPlutoController;

  AddBillController(this._billsFirebaseRepo, {required this.addBillPlutoController});

  // Services
  late final BillService _billService;

  final formKey = GlobalKey<FormState>();

  final TextEditingController billNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController storeController = TextEditingController();
  final TextEditingController customerAccountController = TextEditingController();
  final TextEditingController sellerAccountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  late String billDate;
  AccountModel? selectedCustomerAccount;

  InvPayType selectedPayType = InvPayType.cash;
  BillType billType = BillType.sales;

  bool isLoading = true;

  Map<Account, AccountModel> selectedAdditionsDiscountAccounts = {};

  RxBool isAddNewBillButtonVisible = false.obs;

  int? recentBillNumber;

  BillModel? recentBill;

  @override
  updateSelectedAdditionsDiscountAccounts(Account key, AccountModel value) =>
      selectedAdditionsDiscountAccounts[key] = value;

  @override
  Rx<StoreAccount> selectedStore = StoreAccount.main.obs;

  @override
  void onSelectedStoreChanged(StoreAccount? newStore) {
    if (newStore != null) {
      selectedStore.value = newStore;
      update();
    }
  }

  @override
  void updateCustomerAccount(AccountModel? newAccount) {
    if (newAccount != null) {
      selectedCustomerAccount = newAccount;
    }
  }

  @override
  Future<void> sendToEmail(
      {required String recipientEmail, String? url, String? subject, String? body, List<String>? attachments}) async {
    _billService.sendToEmail(
        recipientEmail: recipientEmail, url: url, subject: subject, body: body, attachments: attachments);
  }

  @override
  set updateIsBillSaved(bool newValue) {}

  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    setBillDate(DateTime.now());
  }

  // Initializer
  void _initializeServices() {
    _billService = BillService(addBillPlutoController, this);
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void updateBillType(String billTypeLabel) => billType = BillType.byLabel(billTypeLabel);

  void setBillDate(DateTime newDate) {
    billDate = newDate.toString().split(" ")[0];
    update();
  }

  void onPayTypeChanged(InvPayType? payType) {
    if (payType != null) {
      selectedPayType = payType;
      update();
    }
  }

  BillModel get getRecentBill => recentBill!;

  bool get _hasBill => recentBill != null;

  showEInvoice(BuildContext context) {
    if (!_hasBill) {
      AppUIUtils.onFailure('يرجى إضافة الفاتورة أولا!');
      return;
    }

    OverlayService.showDialog(
      context: context,
      title: "Invoice QR Code",
      content: EInvoiceDialogContent(
        billController: this,
        billId: getRecentBill.billId!,
      ),
      onCloseCallback: () {
        log("E-Invoice dialog closed.");
      },
    );
  }

  Future<void> printBill(List<InvoiceRecordModel> invRecords) async {
    if (!_validateBeforePrinting(invRecords)) return;

    await read<PrintingController>()
        .startPrinting(invRecords: invRecords, billNumber: recentBillNumber!, invDate: billDate);
  }

  bool _validateBeforePrinting(List<InvoiceRecordModel> invoiceRecords) {
    if (!_hasRecords(invoiceRecords)) {
      AppUIUtils.onFailure('يرجى إضافة عنصر واحد على الأقل إلى الفاتورة!');
      return false;
    }

    if (!_hasBillNumber) {
      AppUIUtils.onFailure('يرجى إضافة الفاتورة أولا قبل طباعتها!');
      return false;
    }

    return true;
  }

  bool _hasRecords(List<InvoiceRecordModel> items) => items.isNotEmpty;

  bool get _hasBillNumber => recentBillNumber != null;

  void createBond(BillTypeModel billTypeModel, BuildContext context) {
    if (!validateForm()) return;

    // _billService.createBond(context: context, billTypeModel: billTypeModel, customerAccount: selectedCustomerAccount!);
  }

  Future<void> saveBill(BillTypeModel billTypeModel) async {
    // Validate the form first
    if (!validateForm()) return;

    // Create the bill model from the provided invoice data
    final BillModel? updatedBillModel = _createBillModelFromInvoiceData(billTypeModel);

    // Return if the model creation failed
    if (updatedBillModel == null) return;

    // Check if the bill items are not empty
    if (!_hasBillItems(updatedBillModel.items.itemList)) return;

    // Save the bill to Firestore
    final result = await _billsFirebaseRepo.save(updatedBillModel);

    // Handle the result (success or failure)
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (billModel) => _handleSaveSuccess(billModel),
    );
  }

  Future<void> _handleSaveSuccess(BillModel billModel) async {
    AppUIUtils.onSuccess('تم حفظ الفاتورة بنجاح!');

    _setRecentBill(billModel);

    _setRecentBillNumber(billModel.billDetails.billNumber!);

    _updateAddNewBillButtonVisibility(true);

    _billService.generateAndSendPdf(
      fileName: AppStrings.bill,
      pdfGenerator: BillPdfGenerator(),
      itemModel: billModel,
      itemModelId: billModel.billId,
      items: billModel.items.itemList,
    );
  }

  void resetBillForm() {
    addBillPlutoController.resetAllTables();

    sellerAccountController.clear();

    _clearRecentBillNumber();

    _clearRecentBill();

    _updateAddNewBillButtonVisibility(false);
  }

  void _setRecentBill(BillModel billModel) {
    recentBill = billModel;
  }

  void _setRecentBillNumber(int billNumber) {
    recentBillNumber = billNumber;
  }

  void _clearRecentBill() {
    recentBill = null;
  }

  void _clearRecentBillNumber() {
    recentBillNumber = null;
  }

  _updateAddNewBillButtonVisibility(newValue) {
    isAddNewBillButtonVisible.value = newValue;
  }

  bool _hasBillItems(List<BillItem> items) {
    if (items.isEmpty) {
      AppUIUtils.onFailure('يرجى إضافة عنصر واحد على الأقل إلى الفاتورة!');
      return false;
    }
    return true;
  }

  BillModel? _createBillModelFromInvoiceData(BillTypeModel billTypeModel) {
    final updatedBillTypeModel = _updateBillTypeAccounts(billTypeModel) ?? billTypeModel;
    final sellerController = read<SellerController>();

    // Validate customer and seller accounts
    if (!_validateCustomerAccount() || !_validateSellerAccount(sellerController)) {
      return null;
    }

    // Create and return the bill model
    return _billService.createBillModel(
      billTypeModel: updatedBillTypeModel,
      billDate: billDate,
      billCustomerId: selectedCustomerAccount!.id!,
      billSellerId: sellerController.selectedSellerAccount!.costGuid!,
      billPayType: selectedPayType.index,
    );
  }

  bool _validateCustomerAccount() {
    if (selectedCustomerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل!');
      return false;
    }
    return true;
  }

  bool _validateSellerAccount(SellerController sellerController) {
    if (sellerController.selectedSellerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم البائع!');
      return false;
    }
    return true;
  }

  BillTypeModel? _updateBillTypeAccounts(BillTypeModel billTypeModel) {
    final selectedAccounts = selectedAdditionsDiscountAccounts;
    final updatedAccounts = {...billTypeModel.accounts ?? {}};

    if (_noUpdateNeeded(selectedAccounts, selectedCustomerAccount)) return null;

    _updateDiscountAndAdditionAccounts(selectedAccounts, updatedAccounts);

    _updateCachesAccount(selectedCustomerAccount, updatedAccounts);

    _updateStoreAccount(selectedStore.value, updatedAccounts);

    return billTypeModel.copyWith(accounts: updatedAccounts);
  }

  // Return null if there is Additions and Discounts Accounts not updated and no selected customer account
  bool _noUpdateNeeded(Map<Account, AccountModel> selectedAccounts, AccountModel? selectedCustomerAccount) =>
      selectedAccounts.isEmpty && selectedCustomerAccount == null;

  // Update discount and addition accounts
  void _updateDiscountAndAdditionAccounts(
      Map<Account, AccountModel> selectedAccounts, Map<Account, AccountModel> updatedAccounts) {
    if (selectedAccounts.isNotEmpty) {
      if (selectedAccounts.containsKey(BillAccounts.discounts)) {
        updatedAccounts[BillAccounts.discounts] = selectedAccounts[BillAccounts.discounts]!;
      }
      if (selectedAccounts.containsKey(BillAccounts.additions)) {
        updatedAccounts[BillAccounts.additions] = selectedAccounts[BillAccounts.additions]!;
      }
    }
  }

  // Update caches account if selectedCustomerAccount is not null and differs from the current cache
  void _updateCachesAccount(AccountModel? selectedCustomerAccount, Map<Account, AccountModel> updatedAccounts) {
    if (selectedCustomerAccount != null && updatedAccounts[BillAccounts.caches]?.id != selectedCustomerAccount.id) {
      updatedAccounts[BillAccounts.caches] = selectedCustomerAccount;
    }
  }

  // Update store account if selectedStore is not null and differs from the current store
  void _updateStoreAccount(StoreAccount? selectedStore, Map<Account, AccountModel> updatedAccounts) {
    if (selectedStore != null && updatedAccounts[BillAccounts.store]?.id != selectedStore.typeGuide) {
      updatedAccounts[BillAccounts.store] = selectedStore.toStoreAccountModel;
    }
  }

  void initCustomerAccount(AccountModel? account) {
    if (account != null) {
      selectedCustomerAccount = account;
      customerAccountController.text = account.accName!;
    }
  }

  Future<void> onBackPressed({
    required String billTypeId,
    required bool fromBillDetails,
    required bool fromBillById,
    required BillDetailsController billDetailsController,
    required BillDetailsPlutoController billDetailsPlutoController,
    required BillSearchController billSearchController,
  }) async {
    AllBillsController allBillsController = read<AllBillsController>();

    await allBillsController.fetchAllBills();

    resetBillForm();

    List<BillModel> billsByCategory = allBillsController.getBillsByType(billTypeId);

    if (billsByCategory.isNotEmpty) {
      final BillModel lastBill = billsByCategory.last;

      billDetailsController.updateBillDetailsOnScreen(lastBill, billDetailsPlutoController);

      billSearchController.initialize(
        billsByCategory: billsByCategory,
        bill: lastBill,
        billDetailsController: billDetailsController,
        billDetailsPlutoController: billDetailsPlutoController,
      );
    }

    if (!fromBillDetails && billsByCategory.isNotEmpty) {
      Get.offNamed(AppRoutes.billDetailsScreen, arguments: fromBillById);
    } else {
      Get.back();
    }
  }
}
