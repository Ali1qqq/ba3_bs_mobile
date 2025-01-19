import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bisc/string_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time_extensions.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/data/models/cheques_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/helper/validators/app_validator.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/utils/generate_id.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../bond/data/models/entry_bond_model.dart';
import '../../service/cheques_details_service.dart';
import '../../service/cheques_entry_bond_creator.dart';
import 'cheques_search_controller.dart';

class ChequesDetailsController extends GetxController with AppValidator {
  ChequesDetailsController(
    this._chequesFirebaseRepo, {
    required this.chequesSearchController,
    required this.chequesType,
  });

  // Repositories

  final CompoundDatasourceRepository<ChequesModel, ChequesType> _chequesFirebaseRepo;
  final ChequesSearchController chequesSearchController;

  // Services
  late final ChequesDetailsService _chequesService;

  final formKey = GlobalKey<FormState>();

  ///controller
  final TextEditingController chequesNumberController = TextEditingController();

  final TextEditingController chequesNumController = TextEditingController();

  final TextEditingController chequesAmountController = TextEditingController();

  final TextEditingController chequesAccPtrController = TextEditingController();

  final TextEditingController chequesToAccountController = TextEditingController();

  final TextEditingController chequesNoteController = TextEditingController();

  AccountModel? chequesAccPtr, chequesToAccountModel;
  bool? isPayed;
  bool? isRefundPay;

  EntryBondController get bondController => read<EntryBondController>();

  RxString chequesDate = DateTime.now().dayMonthYear.obs, chequesDueDate = DateTime.now().dayMonthYear.obs;
  bool isLoading = true;
  RxBool isChequesSaved = false.obs;

  late ChequesType chequesType;

  void setFirstAccount(AccountModel setAccount) {
    chequesAccPtr = setAccount;
    chequesAccPtrController.text = setAccount.accName ?? '';
  }

  void setTowAccount(AccountModel setAccount) {
    chequesToAccountModel = setAccount;
    chequesToAccountController.text = setAccount.accName ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  void setIsPayed(bool pay) {
    isPayed = pay;
  }

  void setIsRefundPay(bool refund) {
    isRefundPay = refund;
  }

  // Initializer
  void _initializeServices() {
    _chequesService = ChequesDetailsService();
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void setChequesDate(DateTime newDate) {
    chequesDate.value = newDate.dayMonthYear;
    update();
  }

  void setChequesDueDate(DateTime newDate) {
    chequesDueDate.value = newDate.dayMonthYear;
    update();
  }

  Future<void> deleteCheques(ChequesModel chequesModel, {bool fromChequesById = false}) async {
    final result = await _chequesFirebaseRepo.delete(chequesModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => _chequesService.handleDeleteSuccess(chequesModel, chequesSearchController, fromChequesById),
    );
  }

  Future<void> saveCheques(ChequesType chequesType) async {
    await _saveOrUpdateCheques(chequesType: chequesType);
  }

  Future<void> updateCheques({required ChequesType chequesType, required ChequesModel chequesModel}) async {
    await _saveOrUpdateCheques(chequesType: chequesType, existingChequesModel: chequesModel);
  }

  Future<void> _saveOrUpdateCheques({required ChequesType chequesType, ChequesModel? existingChequesModel}) async {
    // Validate the form first
    if (!validateForm()) return;

    // Create the cheques model from the provided data
    final updatedChequesModel = _createChequesModelFromChequesData(chequesType, existingChequesModel);

    // Handle null cheques model
    if (updatedChequesModel == null) {
      AppUIUtils.onFailure('من فضلك يرجى اضافة الحساب!');
      return;
    }

    // Save the cheques to Firestore
    final result = await _chequesFirebaseRepo.save(updatedChequesModel);

    // Handle the result (success or failure)
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (chequesModel) {
        _chequesService.handleSaveOrUpdateSuccess(
            chequesModel: chequesModel,
            chequesSearchController: chequesSearchController,
            isSave: existingChequesModel == null,
            chequesDetailsController: this);
      },
    );
  }

  void launchEntryBondWindow(ChequesModel chequesModel, BuildContext context) {
    if (!validateForm()) return;

    _chequesService.launchChequesEntryBondScreen(
        chequesModel: chequesModel, context: context, chequesStrategyType: ChequesStrategyType.chequesStrategy);
  }

  void launchPayEntryBondWindow(ChequesModel chequesModel, BuildContext context) {
    if (!validateForm()) return;

    _chequesService.launchChequesEntryBondScreen(
        chequesModel: chequesModel, context: context, chequesStrategyType: ChequesStrategyType.payStrategy);
  }

  void launchRefundPayEntryBondWindow(ChequesModel chequesModel, BuildContext context) {
    if (!validateForm()) return;

    _chequesService.launchChequesEntryBondScreen(
        chequesModel: chequesModel, context: context, chequesStrategyType: ChequesStrategyType.refundStrategy);
  }

  updateIsChequesSaved(bool newValue) {
    isChequesSaved.value = newValue;
  }

  ChequesModel? _createChequesModelFromChequesData(
    ChequesType chequesType, [
    ChequesModel? chequesModel,
  ]) {
    // Validate customer accounts

    if (!_chequesService.validateAccount(chequesAccPtr) || !_chequesService.validateAccount(chequesToAccountModel)) {
      return null;
    }

    // Create and return the cheques model
    return _chequesService.createChequesModel(
      isPayed: isPayed!,
      isRefund: isRefundPay!,
      accPtrName: chequesAccPtr!.accName!,
      chequesAccount2Name: chequesToAccountModel!.accName!,
      chequesModel: chequesModel,
      chequesType: chequesType,
      chequesAccount2Guid: chequesToAccountModel!.id!,
      accPtr: chequesAccPtr!.id!,
      chequesDate: chequesDate.value,
      chequesDueDate: chequesDueDate.value,
      chequesNote: chequesNoteController.text,
      chequesNum: int.parse(chequesNumController.text),
      chequesVal: double.parse(chequesAmountController.text),
      chequesTypeGuid: chequesType.typeGuide,
    );
  }

  initChequesNumberController(int? chequesNumber) {
    if (chequesNumber != null) {
      chequesNumberController.text = chequesNumber.toString();
    } else {
      chequesNumberController.text = '';
    }
  }

  void updateChequesDetailsOnScreen(
    ChequesModel cheques,
  ) {
    setChequesDate(cheques.chequesDate!.toDate);
    setChequesDueDate(cheques.chequesDueDate!.toDate);
    setIsPayed(cheques.isPayed ?? false);
    setIsRefundPay(cheques.isRefund ?? false);
    setTowAccount(read<AccountsController>().getAccountModelById(cheques.chequesAccount2Guid)!);
    setFirstAccount(read<AccountsController>().getAccountModelById(cheques.accPtr) ?? AccountModel());
    stChequesFormDate(cheques);
    initChequesNumberController(cheques.chequesNumber);
  }

  void stChequesFormDate(ChequesModel cheques) {
    chequesNoteController.text = cheques.chequesNote ?? '';
    chequesNumController.text = (cheques.chequesNum ?? '').toString();
    chequesAmountController.text = (cheques.chequesVal ?? '').toString();
  }

  void savePayCheques(ChequesModel chequesModel) async {
    setIsPayed(true);
    final updatedModel = chequesModel.copyWith(chequesPayGuid: generateId(RecordType.entryBond));

    final creator =
        ChequesStrategyBondFactory.determineStrategy(updatedModel, type: ChequesStrategyType.payStrategy).first;
    EntryBondModel entryBondModel = creator.createEntryBond(originType: EntryBondType.cheque, model: updatedModel);

    await _saveOrUpdateCheques(chequesType: chequesType, existingChequesModel: updatedModel);
    read<EntryBondController>().saveEntryBondModel(entryBondModel: entryBondModel);
  }

  void clearPayCheques(ChequesModel chequesModel) async {
    setIsPayed(false);
    final updatedModel = chequesModel.copyWithNullPayGuid();
    await _saveOrUpdateCheques(chequesType: chequesType, existingChequesModel: updatedModel);
    read<EntryBondController>().deleteEntryBondModel(entryId: chequesModel.chequesPayGuid!);
  }

  void refundPayCheques(ChequesModel chequesModel) async {
    setIsRefundPay(true);
    final updatedModel = chequesModel.copyWith(chequesRefundPayGuid: generateId(RecordType.entryBond));

    final creator =
        ChequesStrategyBondFactory.determineStrategy(updatedModel, type: ChequesStrategyType.refundStrategy).first;

    EntryBondModel entryBondModel = creator.createEntryBond(originType: EntryBondType.cheque, model: updatedModel);

    await _saveOrUpdateCheques(chequesType: chequesType, existingChequesModel: updatedModel);

    log(entryBondModel.origin!.toJson().toString());
    read<EntryBondController>().saveEntryBondModel(entryBondModel: entryBondModel);
  }

  void deleteRefundPayCheques(ChequesModel chequesModel) async {
    setIsRefundPay(false);
    final updatedModel = chequesModel.copyWithNullRefundPayGuid();
    await _saveOrUpdateCheques(chequesType: chequesType, existingChequesModel: updatedModel);
    read<EntryBondController>().deleteEntryBondModel(entryId: chequesModel.chequesRefundPayGuid!);
  }
}
