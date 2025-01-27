import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/bond/controllers/pluto/bond_details_pluto_controller.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/bond_model.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/pay_item_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/validators/app_validator.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../service/bond/bond_details_service.dart';
import 'bond_search_controller.dart';

class BondDetailsController extends GetxController with AppValidator {
  BondDetailsController(
    this._bondsFirebaseRepo, {
    required this.bondDetailsPlutoController,
    required this.bondSearchController,
    required this.bondType,
  });

  // Repositories

  final CompoundDatasourceRepository<BondModel, BondType> _bondsFirebaseRepo;
  final BondDetailsPlutoController bondDetailsPlutoController;
  final BondSearchController bondSearchController;

  // Services
  late final BondDetailsService _bondService;

  final formKey = GlobalKey<FormState>();

  ///controller
  final TextEditingController accountController = TextEditingController();
  final TextEditingController bondNumberController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  AccountModel? selectedAccount;

  RxString bondDate = DateTime.now().dayMonthYear.obs;
  bool isLoading = true;
  RxBool isBondSaved = false.obs;

  late BondType bondType;

  late bool isDebitOrCredit;

  void setAccount(AccountModel setAccount) {
    selectedAccount = setAccount;
    bondDetailsPlutoController.setAccountGuid = setAccount.id;
    accountController.text = setAccount.accName!;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    setIsDebitOrCredit();
  }

  void setIsDebitOrCredit() {
    if (bondType == BondType.journalVoucher || bondType == BondType.openingEntry) {
      isDebitOrCredit = false;
    } else {
      isDebitOrCredit = true;
    }
    update();
  }

  // Initializer
  void _initializeServices() {
    _bondService = BondDetailsService(bondDetailsPlutoController, this);
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void setBondDate(DateTime newDate) {
    bondDate.value = newDate.dayMonthYear;
    update();
  }

  Future<void> deleteBond(BondModel bondModel, {bool fromBondById = false}) async {
    final result = await _bondsFirebaseRepo.delete(bondModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => _bondService.handleDeleteSuccess(bondModel, bondSearchController, fromBondById),
    );
  }

  Future<void> saveBond(BondType bondType) async {
    await _saveOrUpdateBond(bondType: bondType);
  }

  Future<void> updateBond({required BondType bondType, required BondModel bondModel}) async {
    await _saveOrUpdateBond(bondType: bondType, existingBondModel: bondModel);
  }

  Future<void> _saveOrUpdateBond({required BondType bondType, BondModel? existingBondModel}) async {
    // Validate the form first
    if (!validateForm()) return;

    if (!bondDetailsPlutoController.checkIfBalancedBond()) {
      AppUIUtils.onFailure('يجب موازنة السند من فضلك!');
      return;
    }
    // Create the bond model from the provided data
    final updatedBondModel = _createBondModelFromBondData(bondType, existingBondModel);

    // Handle null bond model
    if (updatedBondModel == null) {
      AppUIUtils.onFailure('من فضلك يرجى اضافة الحساب!');
      return;
    }

    // Ensure there are bond items
    if (updatedBondModel.payItems.itemList.isEmpty) {
      AppUIUtils.onFailure('من فضلك يرجى اضافة حقول للسند');
      return;
    }
    log("save");
    // Save the bond to Firestore
    final result = await _bondsFirebaseRepo.save(updatedBondModel);

    // Handle the result (success or failure)
    result.fold(
      (failure) {
        log("save failure");
        return AppUIUtils.onFailure(failure.message);
      },
      (bondModel) {
        _bondService.handleSaveOrUpdateSuccess(
            previousBond: existingBondModel,
            currentBond: bondModel,
            bondSearchController: bondSearchController,
            isSave: existingBondModel == null,
            bondDetailsController: this);
      },
    );
  }

  void createEntryBond(BondModel bondModel, BuildContext context) {
    if (!validateForm()) return;

    _bondService.launchBondEntryBondScreen(
      bondModel: bondModel,
      context: context,
    );
  }

  updateIsBondSaved(bool newValue) {
    isBondSaved.value = newValue;
  }

  BondModel? _createBondModelFromBondData(BondType bondType, [BondModel? bondModel]) {
    // Validate customer accounts
    if (bondSearchController.bondDetailsController.isDebitOrCredit) {
      if (!_bondService.validateAccount(selectedAccount)) {
        return null;
      }
    }
    // Create and return the bond model

    return _bondService.createBondModel(
        bondModel: bondModel, bondType: bondType, payDate: bondDate.value, payAccountGuid: selectedAccount!.id!, note: noteController.text);
  }

  prepareBondRecords(PayItems bondItems, BondDetailsPlutoController bondDetailsPlutoController) =>
      bondDetailsPlutoController.prepareBondRows(bondItems.itemList);

  initBondNumberController(int? bondNumber) {
    if (bondNumber != null) {
      bondNumberController.text = bondNumber.toString();
    } else {
      bondNumberController.text = '';
    }
  }

  void updateBondDetailsOnScreen(BondModel bond, BondDetailsPlutoController bondPlutoController) {
    log("bond.payDate! ${bond.payDate!}");
    log("bond.payDate!.toDate ${bond.payDate.toDate}");
    setBondDate(bond.payDate!.toDate);

    initBondNumberController(bond.payNumber);

    if (AppServiceUtils.getAccountModelFromLabel(bond.payAccountGuid) != null) {
      setAccount(AppServiceUtils.getAccountModelFromLabel(bond.payAccountGuid)!);
      accountController.text = AppServiceUtils.getAccountModelFromLabel(bond.payAccountGuid)!.accName!;
    }

    prepareBondRecords(bond.payItems, bondPlutoController);

    bondPlutoController.update();
  }

  generateAndSendBondPdf(BondModel bondModel) {
    if (!_bondService.hasModelId(bondModel.payGuid)) return;

    if (!_bondService.hasModelItems(bondModel.payItems.itemList)) return;

    _bondService.generateAndSendPdf(
      fileName: AppStrings.bond,
      itemModel: bondModel,
    );
  }
}
