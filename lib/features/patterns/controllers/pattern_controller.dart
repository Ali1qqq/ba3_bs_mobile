import 'dart:developer';

import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:ba3_bs_mobile/features/patterns/ui/screens/add_pattern_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../accounts/data/models/account_model.dart';
import '../data/models/bill_type_model.dart';
import '../services/pattern_form_handler.dart';

class PatternController extends GetxController with AppNavigator, FloatingLauncher {
  final RemoteDataSourceRepository<BillTypeModel> _repository;

  PatternController(this._repository);

  final List<BillTypeModel> billsTypes = [];

  final Map<TextEditingController, BillAccounts> controllerToBillAccountsMap = {};

  // Form Handlers
  late final PatternFormHandler patternFormHandler;

  BillPatternType? get selectedBillPatternType => patternFormHandler.selectedBillPatternType.value;

  BillTypeModel get billsTypeSales => billsTypes.firstWhere((billTypeModel) => billTypeModel.billTypeId == BillType.sales.typeGuide);

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
        fillControllers(shortName: 'النقص', fullName: 'تسوية النقص', latinShortName: 'remove', latinFullName: 'Settlement of the dicrease');

      case BillPatternType.transferIn:
        fillControllers(
            shortName: 'الزيادة', fullName: 'تسوية الزيادة', latinShortName: 'Add', latinFullName: 'Settlement of the increase');

      case BillPatternType.salesService:
        fillControllers(shortName: 'مبيعات', fullName: 'فاتورة مبيعات', latinShortName: 'Sales', latinFullName: 'Sales Invoice');
        break;
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

  void navigateToAddPatternScreen({BillTypeModel? billType, required BuildContext context}) {
    patternFormHandler.init(billType);

    launchFloatingWindow(context: context, minimizedTitle: ApiConstants.patterns.tr, floatingScreen: AddPatternScreen());

    // to(AppRoutes.addPatternsScreen);
  }

  Future<List<BillTypeModel>> getAllBillTypes() async {
    final result = await _repository.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBillTypes) => billsTypes.assignAll(fetchedBillTypes),
    );

    return billsTypes;
  }

  Future<void> addNewPattern() async {
    if (!patternFormHandler.validate()) return;

    if (patternFormHandler.selectedBillPatternType.value == null) {
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
    Map<Account, AccountModel> accounts = patternFormHandler.selectedAccounts;

    accounts[BillAccounts.store] = patternFormHandler.selectedStore.value.toStoreAccountModel;

    final selectedBillTypeModel = patternFormHandler.selectedBillTypeModel;

    log(accounts.toString());

    if (selectedBillTypeModel != null) {
      return selectedBillTypeModel.copyWith(
        shortName: patternFormHandler.shortNameController.text,
        latinShortName: patternFormHandler.latinShortNameController.text,
        fullName: patternFormHandler.fullNameController.text,
        latinFullName: patternFormHandler.latinFullNameController.text,
        billTypeLabel: patternFormHandler.selectedBillPatternType.value!.value,
        billTypeId: BillType.byLabel(patternFormHandler.selectedBillPatternType.value!.value).typeGuide,
        accounts: accounts,
        color: patternFormHandler.selectedColorValue,
      );
    } else {
      return BillTypeModel(
        shortName: patternFormHandler.shortNameController.text,
        latinShortName: patternFormHandler.latinShortNameController.text,
        fullName: patternFormHandler.fullNameController.text,
        latinFullName: patternFormHandler.latinFullNameController.text,
        billTypeLabel: patternFormHandler.selectedBillPatternType.value!.value,
        billTypeId: BillType.byLabel(patternFormHandler.selectedBillPatternType.value!.value).typeGuide,
        accounts: accounts,
        color: patternFormHandler.selectedColorValue,
      );
    }
  }
}