import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/bond/data/models/entry_bond_model.dart';
import 'package:ba3_bs_mobile/features/migration/data/models/migration_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../bill/use_cases/convert_bills_to_linked_list_use_case.dart';
import '../../bill/use_cases/divide_large_bill_use_case.dart';
import '../../bond/data/models/bond_model.dart';
import '../../bond/data/models/pay_item_model.dart';
import '../../bond/service/bond/floating_bond_details_launcher.dart';
import '../../cheques/data/models/cheques_model.dart';
import '../../patterns/data/models/bill_type_model.dart';
import '../use_cases/close_accounts_and_items_use_case.dart';
import '../use_cases/copy_end_period_use_case.dart';
import '../use_cases/copy_unpaid_cheque_use_case.dart';
import '../use_cases/generate_bill_records_use_case.dart';
import '../use_cases/rotate_balance_use_case.dart';

class MigrationController extends FloatingBondDetailsLauncher with EntryBondsGenerator, FirestoreSequentialNumbers {
  final CompoundDatasourceRepository<BondModel, BondType> _bondsFirebaseRepo;
  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;

  final CompoundDatasourceRepository<ChequesModel, ChequesType> _chequesFirebaseRepo;
  final RemoteDataSourceRepository<MigrationModel> _migrationFirebaseRep;
  final TextEditingController migrationController = TextEditingController();

  MigrationController(this._bondsFirebaseRepo, this._billsFirebaseRepo, this._chequesFirebaseRepo, this._migrationFirebaseRep);

  RxBool isMigrating = false.obs;
  RxString migrationStatus = ''.obs;

  late final GenerateBillRecordsUseCase _generateBillRecordsUseCase;
  late final DivideLargeBillUseCase _divideLargeBillUseCase;
  late final ConvertBillsToLinkedListUseCase _convertBillsToLinkedListUseCase;

  late final CopyEndPeriodUseCase _copyEndPeriodUseCase;

  late final RotateBalancesUseCase _rotateBalancesUseCase;

  late final CopyUnpaidChequesUseCase _copyUnpaidChequesUseCase;

  late final CloseAccountsAndItemsUseCase _closeAccountsAndItemsUseCase;

  final Rx<RequestState> getMigrationVersionsRequestState = RequestState.initial.obs;
  final Rx<RequestState> addMigrationVersionsRequestState = RequestState.initial.obs;

  final Rx<RequestState> updateMigrationVersionsRequestState = RequestState.initial.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    fetchMigrationVersions();
  }

  void _initializeServices() {
    _generateBillRecordsUseCase = GenerateBillRecordsUseCase();
    _divideLargeBillUseCase = DivideLargeBillUseCase();
    _convertBillsToLinkedListUseCase = ConvertBillsToLinkedListUseCase();

    _rotateBalancesUseCase = RotateBalancesUseCase(
      saveBond: saveBond,
      migrationGuard: migrationGuard,
      setCurrentVersion: (v) => currentVersion = v,
    );

    _copyEndPeriodUseCase = CopyEndPeriodUseCase(
      generateBillRecordsUseCase: _generateBillRecordsUseCase,
      divideLargeBillUseCase: _divideLargeBillUseCase,
      convertBillsToLinkedListUseCase: _convertBillsToLinkedListUseCase,
      fetchAndIncrementEntityNumber: fetchAndIncrementEntityNumber,
      saveBill: saveBill,
      setLastUsedNumber: setLastUsedNumber,
      migrationGuard: migrationGuard,
    );

    _copyUnpaidChequesUseCase = CopyUnpaidChequesUseCase(
      fetchChequesByType: fetchCheques,
      saveAllCheques: saveAllCheques,
      migrationGuard: migrationGuard,
      setCurrentVersion: (v) => currentVersion = v,
    );

    _closeAccountsAndItemsUseCase = CloseAccountsAndItemsUseCase(migrationGuard: migrationGuard);
  }

  // 🔹 Available migration versions
  final RxList<String> migrationVersions = <String>[].obs;

  // 🔹 Selected migration version (initialized to the first version)
  RxString selectedVersion = ''.obs;

  String get currentVersion => selectedVersion.value;

  set currentVersion(String version) => selectedVersion.value = version;

  String get year {
    return currentVersion == AppConstants.defaultVersion || currentVersion.isEmpty
        ? ''
        : '${currentVersion}_'; // 🔹 Ensures it always fetches the latest version
  }

  void setMigrationVersion(String version) {
    selectedVersion.value = version;

    updateCurrentMigrationVersion(version);
  }

  Future<void> fetchMigrationVersions() async {
    getMigrationVersionsRequestState.value = RequestState.loading;
    final result = await _migrationFirebaseRep.getAll();

    result.fold(
      (failure) {
        getMigrationVersionsRequestState.value = RequestState.error;

        AppUIUtils.onFailure(failure.message);
      },
      (fetchedMigrationVersions) {
        getMigrationVersionsRequestState.value = RequestState.success;

        if (fetchedMigrationVersions.isNotEmpty) {
          migrationVersions.addAll(fetchedMigrationVersions.first.migrationVersions ?? []);
          selectedVersion.value = fetchedMigrationVersions.first.currentVersion ?? '';
        }
      },
    );
  }

  Future<void> updateCurrentMigrationVersion(String currentVersion) async {
    updateMigrationVersionsRequestState.value = RequestState.loading;

    // 🔹 Save to Firebase before adding locally
    final result = await _migrationFirebaseRep.save(
      MigrationModel(
        id: 'main-migration',
        currentVersion: currentVersion,
        migrationVersions: migrationVersions,
      ),
    );

    // 🔹 Handle success or failure
    result.fold(
      (failure) {
        updateMigrationVersionsRequestState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (_) {
        updateMigrationVersionsRequestState.value = RequestState.success;
        AppUIUtils.onInfo('تم تحديث سنة الترحيل ل $currentVersion بنجاح', 'الترحيل');
      },
    );
  }

  Future<void> addMigrationVersion() async {
    final newVersion = migrationController.text.trim();

    // 🔹 Validate input
    if (newVersion.isEmpty) {
      AppUIUtils.onFailure('يرجى كتابة سنة الترحيل');
      return;
    }

    if (migrationVersions.contains(newVersion)) {
      AppUIUtils.onFailure('سنة الترحيل موجودة بالفعل');
      return;
    }

    addMigrationVersionsRequestState.value = RequestState.loading;

    // 🔹 Save to Firebase before adding locally
    final result = await _migrationFirebaseRep.save(
      MigrationModel(
        id: 'main-migration',
        currentVersion: newVersion,
        migrationVersions: [...migrationVersions, newVersion], // Add new version
      ),
    );

    // 🔹 Handle success or failure
    result.fold(
      (failure) {
        addMigrationVersionsRequestState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (_) {
        addMigrationVersionsRequestState.value = RequestState.success;
        migrationVersions.add(newVersion);
        selectedVersion.value = newVersion; // 🔹 Set new version as selected
        Get.back(); // Close dialog on success
      },
    );
  }

  Future<void> startMigration() async {
    // 🔹 Show confirmation dialog before proceeding
    bool shouldProceed = await _showMigrationConfirmationDialog();
    if (!shouldProceed) return;

    final currentYear = currentVersion;

    if (migrationGuard(currentYear)) {
      return;
    }

    isMigrating.value = true;
    migrationStatus.value = 'جارٍ تنفيذ الترحيل...';

    try {
      log(currentYear, name: 'AppConfig.year');

      // // تدوير الأرصدة: كل حساب يتم نقل أرصدته للسنة الجديدة كمفتتح
      await _rotateBalancesUseCase.execute(currentYear);

      // // نسخ نهاية المدة: كل المواد يتم نقل كميتها الختامية للسنة الجديدة
      await _copyEndPeriodUseCase.execute(currentYear);

      // التحقق من الإدخالات غير المصروفة
      await _copyUnpaidChequesUseCase.execute(currentYear);

      // إغلاق الحساب والمواد
      await _closeAccountsAndItemsUseCase.execute(currentYear);

      migrationStatus.value = "✅ تم الترحيل بنجاح!";
    } catch (e, stackTrace) {
      migrationStatus.value = "⚠️ فشل الترحيل: $e";
      log(e.toString(), name: "catch", stackTrace: stackTrace);
    } finally {
      isMigrating.value = false;
      log('currentYear: $currentYear', name: "finally");
    }
  }

  Future<bool> _showMigrationConfirmationDialog() async {
    if (Get.isSnackbarOpen) {
      try {
        Get.closeCurrentSnackbar();
      } catch (e) {
        log("Snack bar already closed: $e", name: "MigrationController");
      }
    }

    bool userConfirmed = false;

    await Get.defaultDialog(
      title: "تأكيد الترحيل",
      titleStyle: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
      middleTextStyle: TextStyle(color: Colors.black, fontSize: 13),
      middleText: "هل أنت متأكد أنك تريد تنفيذ الترحيل؟\nهذه العملية لا يمكن التراجع عنها.",
      textConfirm: "نعم، متابعة",
      textCancel: "إلغاء",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.red,
      backgroundColor: Colors.white,
      onConfirm: () {
        userConfirmed = true;

        if (Get.isSnackbarOpen) {
          try {
            Get.closeCurrentSnackbar();
          } catch (e) {
            log("Snack bar already closed: $e");
          }
        }

        Get.back();
      },
      onCancel: () {
        userConfirmed = false;

        if (Get.isSnackbarOpen) {
          try {
            Get.closeCurrentSnackbar();
          } catch (e) {
            log("Snack bar already closed: $e");
          }
        }

        Get.back();
      },
    );

    return userConfirmed;
  }

  // 1:32
  // 5436

  Future<void> saveBond(BondModel bondModel) async {
    final result = await _bondsFirebaseRepo.save(bondModel);

    await result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedBond) async => await handleSaveBondSuccess(savedBond),
    );
  }

  Future<void> handleSaveBondSuccess(BondModel bond) async {
    await createAndStoreEntryBond(
      model: bond,
      sourceNumbers: [bond.payNumber!],
      isSave: true,
    );
  }

  List<PayItem> generatePayItems(List<EntryBondItemModel> entryBondItems) {
    final payItems = entryBondItems
        .map(
          (EntryBondItemModel item) => PayItem(
            entryCredit: item.bondItemType == BondItemType.creditor ? item.amount : 0,
            entryDebit: item.bondItemType == BondItemType.debtor ? item.amount : 0,
            entryAccountGuid: item.account.id,
            entryAccountName: item.account.name,
            entryDate: item.date,
            entryNote: item.note,
          ),
        )
        .toList();

    return payItems;
  }

  bool migrationGuard(String currentVersion) {
    log('🔍 Checking migration year: $currentVersion', name: 'MigrationGuard');

    if (currentVersion == AppConstants.defaultVersion) {
      log(
        '⚠️ Invalid Migration Year: \'$currentVersion\' is empty. This is the default and cannot be used. Please select a valid version.',
        name: 'MigrationGuard',
      );

      // 🔹 Notify user about invalid selection
      AppUIUtils.showInfoSnackBar(
        message: "يرجى اختيار إصدار ترحيل صالح قبل المتابعة. هذا هو الإصدار الأساسي ولا يمكن الترحيل له.",
        status: NotificationStatus.error,
      );

      return true; // Migration is not allowed
    }

    return false; // Migration is allowed
  }

  Future<void> saveBill(BillModel billModel) async {
    final result = await _billsFirebaseRepo.save(billModel);

    await result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedBill) async => await handleSaveBillSuccess(savedBill),
    );
  }

  Future<void> handleSaveBillSuccess(BillModel bill) async {}

  Future<List<ChequesModel>> fetchCheques() async {
    final result = await _chequesFirebaseRepo.getAll(ChequesType.paidChecks);

    // Handle the result (success or failure)

    return result.fold(
      (failure) {
        AppUIUtils.onFailure(failure.message);
        return [];
      },
      (fetchedCheques) => fetchedCheques,
    );
  }

  Future<void> saveAllCheques(List<ChequesModel> cheques, ChequesType type) async {
    // Save the cheques to Firestore
    final result = await _chequesFirebaseRepo.saveAll(cheques, type);

    // Handle the result (success or failure)
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (currentChequesModel) {},
    );
  }

  bool checkDebitCreditEquals(double a, double b) => (a - b).abs() <= 1;
}

bool dateBaseGuard(String rootCollectionPath) {
  if (!read<MigrationController>().isMigrating.value) {
    log('Migration Guard is disabled. Migration is allowed.', name: 'MigrationGuard');
    return false; // ✅ السماح بالترحيل
  }

  // ✅ يجب أن يبدأ `rootCollectionPath` إما بـ `_` أو رقم، وإلا فهو غير مسموح به
  final validPattern = RegExp(r'^[_0-9]');

  if (!validPattern.hasMatch(rootCollectionPath)) {
    log(
      '⛔ Invalid root collection path: \'$rootCollectionPath\' - Migration not allowed!',
      name: 'MigrationGuard',
    );

    AppUIUtils.showInfoSnackBar(
      message: "❌ مسار الترحيل غير صالح. يجب أن يبدأ بشرطة سفلية (_) أو رقم.",
      status: NotificationStatus.error,
    );

    log('Migration is not allowed.', name: 'MigrationGuard');

    return true; // ❌ منع الترحيل
  }

  // ✅ إذا بدأ `_` أو رقم، السماح بالترحيل
  log('✅ Valid root collection path: \'$rootCollectionPath\' - Proceeding with migration.', name: 'MigrationGuard');
  log('Migration is allowed.', name: 'MigrationGuard');

  return false; // ✅ السماح بالترحيل
}