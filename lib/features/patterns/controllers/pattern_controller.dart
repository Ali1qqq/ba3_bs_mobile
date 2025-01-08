import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../accounts/data/models/account_model.dart';
import '../data/models/bill_type_model.dart';
import '../services/pattern_form_handler.dart';

class PatternController extends GetxController with AppNavigator {
  final DataSourceRepository<BillTypeModel> _repository;

  PatternController(this._repository) {
    getAllBillTypes();
  }

  List<BillTypeModel> billsTypes = [];

  bool isLoading = true;

  final Map<TextEditingController, BillAccounts> controllerToBillAccountsMap = {};

  // Form Handlers
  late final PatternFormHandler patternFormHandler;

  BillPatternType? get selectedBillPatternType => patternFormHandler.selectedBillPatternType;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  // Initializer
  void _initializeServices() {
    patternFormHandler = PatternFormHandler();
  }

  void autoFillControllers(BillPatternType newType) {
    switch (newType) {
      case BillPatternType.sales:
        fillControllers(shortName: 'مبيعات', fullName: 'فاتورة مبيعات', latinShortName: 'Sales', latinFullName: 'Sales Invoice');
        break;

      case BillPatternType.purchase:
        fillControllers(shortName: 'شراء', fullName: 'فاتورة مشتريات', latinShortName: 'Buy', latinFullName: 'Purchase Invoice');
        break;

      case BillPatternType.add:
        fillControllers(shortName: 'إضافة', fullName: 'فاتورة إضافة', latinShortName: 'Add', latinFullName: 'Addition Invoice');
        break;

      case BillPatternType.remove:
        fillControllers(shortName: 'سحب', fullName: 'فاتورة سحب', latinShortName: 'Remove', latinFullName: 'Removal Invoice');
        break;

      case BillPatternType.buyReturn:
        fillControllers(
            shortName: 'مرتجع شراء',
            fullName: 'فاتورة مرتجع مشتريات',
            latinShortName: 'Return Buy',
            latinFullName: 'Purchase Return Invoice');
        break;

      case BillPatternType.salesReturn:
        fillControllers(
            shortName: 'مرتجع مبيعات',
            fullName: 'فاتورة مرتجع مبيعات',
            latinShortName: 'Return Sales',
            latinFullName: 'Sales Return Invoice');
        break;
      case BillPatternType.firstPeriodInventory:
        fillControllers(
            shortName: 'القيد الافتتاحي', fullName: 'بضاعة اول مدة', latinShortName: 'Add', latinFullName: 'first Period Inventory');
      case BillPatternType.transferOut:
        fillControllers(
            shortName: 'القيد الافتتاحي', fullName: 'بضاعة اول مدة', latinShortName: 'Add', latinFullName: 'first Period Inventory');
      case BillPatternType.transferIn:
        fillControllers(
            shortName: 'القيد الافتتاحي', fullName: 'بضاعة اول مدة', latinShortName: 'Add', latinFullName: 'first Period Inventory');
    }
  }

  void fillControllers({
    required String shortName,
    required String fullName,
    required String latinShortName,
    required String latinFullName,
  }) {
    patternFormHandler.shortNameController.text = shortName;
    patternFormHandler.fullNameController.text = fullName;
    patternFormHandler.latinShortNameController.text = latinShortName;
    patternFormHandler.latinFullNameController.text = latinFullName;

    update();
  }

  void navigateToAddPatternScreen([BillTypeModel? billType]) {
    patternFormHandler.init(billType);
    to(AppRoutes.addPatternsScreen);
  }

  Future<void> getAllBillTypes() async {
    final result = await _repository.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBillTypes) => billsTypes.assignAll(fetchedBillTypes),
    );

    isLoading = false;
    update();
  }

  Future<void> addNewPattern() async {
    if (!patternFormHandler.validate()) return;

    if (patternFormHandler.selectedBillPatternType == null) {
      AppUIUtils.onFailure('من فضلك قم بادخال نوع النمط!');
      return;
    }

    final billTypeModel = _createBillTypeModel();

    final result = await _repository.save(billTypeModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => AppUIUtils.onSuccess('تم حفظ النموذج بنجاح!'),
    );
  }

  BillTypeModel _createBillTypeModel() {
    Map<Account, AccountModel> accounts = read<AccountsController>().selectedAccounts;

    accounts[BillAccounts.store] = patternFormHandler.selectedStore.value.toStoreAccountModel;

    final selectedBillTypeModel = patternFormHandler.selectedBillTypeModel;

    if (selectedBillTypeModel != null) {
      return selectedBillTypeModel.copyWith(
        shortName: patternFormHandler.shortNameController.text,
        latinShortName: patternFormHandler.latinShortNameController.text,
        fullName: patternFormHandler.fullNameController.text,
        latinFullName: patternFormHandler.latinFullNameController.text,
        billTypeLabel: patternFormHandler.selectedBillPatternType!.value,
        billTypeId: BillType.byLabel(patternFormHandler.selectedBillPatternType!.value).typeGuide,
        accounts: accounts,
        color: patternFormHandler.selectedColorValue,
      );
    } else {
      return BillTypeModel(
        shortName: patternFormHandler.shortNameController.text,
        latinShortName: patternFormHandler.latinShortNameController.text,
        fullName: patternFormHandler.fullNameController.text,
        latinFullName: patternFormHandler.latinFullNameController.text,
        billTypeLabel: patternFormHandler.selectedBillPatternType!.value,
        billTypeId: BillType.byLabel(patternFormHandler.selectedBillPatternType!.value).typeGuide,
        accounts: accounts,
        color: patternFormHandler.selectedColorValue,
      );
    }
  }
}
