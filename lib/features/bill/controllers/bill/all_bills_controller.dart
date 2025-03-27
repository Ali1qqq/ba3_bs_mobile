import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/models/query_filter.dart';
import 'package:ba3_bs_mobile/core/network/api_constants.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import 'package:ba3_bs_mobile/core/services/json_file_operations/implementations/import_export_repo.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import 'package:ba3_bs_mobile/features/bill/ui/screens/all_bills_screen.dart';
import 'package:ba3_bs_mobile/features/bill/ui/screens/bill_details_screen.dart';
import 'package:ba3_bs_mobile/features/car_store/controllers/store_cart_controller.dart';
import 'package:ba3_bs_mobile/features/customer/controllers/customers_controller.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_group_controller.dart';
import 'package:ba3_bs_mobile/features/materials/service/mat_statement_generator.dart';
import 'package:ba3_bs_mobile/features/materials/ui/screens/serials_statement_screen.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/mixin/app_navigator.dart';
import '../../../../core/models/date_filter.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import '../../../../core/services/export_xml/export_xml_service.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../floating_window/controllers/floating_window_controller.dart';
import '../../../materials/data/models/materials/material_model.dart';
import '../../../patterns/controllers/pattern_controller.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';
import '../../services/bill/bill_utils.dart';
import '../../services/bill/floating_bill_details_launcher.dart';
import 'bill_search_controller.dart';

class AllBillsController extends FloatingBillDetailsLauncher
    with AppNavigator, EntryBondsGenerator, MatsStatementsGenerator, FirestoreSequentialNumbers {
  // Repositories

  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;
  final QueryableSavableRepository<SerialNumberModel> _serialNumbersRepo;
  final ImportExportRepository<BillModel> _jsonImportExportRepo;

  AllBillsController(this._billsFirebaseRepo, this._serialNumbersRepo, this._jsonImportExportRepo);

  // Services
  late final BillUtils _billUtils;

  final List<BillModel> bills = [];
  final Map<BillTypeModel, List<BillModel>> nestedBills = {};
  final Map<String, List<BillModel>> billsByTypeGuid = {};
  final List<BillModel> allNestedBills = [];

  final List<BillModel> pendingBills = [];

  // final List<BillModel> nunPendingBills = [];

  final pendingBillsCountsByType = <BillTypeModel, int>{};
  final allBillsCountsByType = <BillTypeModel, int>{};

  bool plutoGridIsLoading = true;

  bool isBillsLoading = true;

  final Rx<RequestState> getBillsTypesRequestState = RequestState.initial.obs;

  final Rx<RequestState> getAllNestedBillsRequestState = RequestState.initial.obs;

  final Rx<RequestState> saveAllBillsRequestState = RequestState.initial.obs;
  final Rx<RequestState> saveAllBillsBondRequestState = RequestState.initial.obs;

  // Initialize a progress observable
  final RxDouble uploadProgress = 0.0.obs;

  // Initializer
  void _initializeServices() {
    _billUtils = BillUtils();
  }

  fetchStoreCard() async {}

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    fetchBillsTypes();

    read<MaterialController>().reloadMaterials();
  }

  Future<void> refreshBillsTypes() async => await fetchBillsTypes();

  int pendingBillsCounts(BillTypeModel billTypeModel) => pendingBillsCountsByType[billTypeModel] ?? 0;

  int allBillsCounts(BillTypeModel billTypeModel) => allBillsCountsByType[billTypeModel] ?? 0;

  BillModel getBillById(String billId) => bills.firstWhere((bill) => bill.billId == billId);

  Future<void> saveXmlToFile() async {
    final xmlService = ExportXmlService();

    // await fetchAllNestedBills();
    await fetchBills(read<PatternController>().billsTypeSales);
    log(bills.length.toString());
    final allBills = [bills.last];
    // await read<AllBondsController>().fetchAllNestedBonds();

    // billsByTypeGuid
    final usedMaterialIds = allBills.expand((bill) => bill.items.itemList.map((item) => item.itemGuid)).toSet();

    final usedMaterials = read<MaterialController>().materials.where((mat) => usedMaterialIds.contains(mat.id)).toList();

    final usedAccountIds = allBills
        .map((bill) => bill.billTypeModel.accounts?.values.map((acc) => acc.id))
        .where((ids) => ids != null)
        .expand((ids) => ids!)
        .toSet();

    final usedAccounts = read<AccountsController>().accounts.where((acc) => usedAccountIds.contains(acc.id)).toList();
    final usedCustomerAccounts = usedAccounts.map((acc) => acc.id).whereType<String>().toSet();

    final usedCustomers =
        read<CustomersController>().customers.where((customer) => usedCustomerAccounts.contains(customer.accountGuid)).toList();

// 🔹 3. مجموعات المواد المستخدمة
    final usedGroupIds = usedMaterials.map((mat) => mat.matGroupGuid).whereType<String>().toSet();

    final usedGroups = read<MaterialGroupController>().materialGroups.where((group) => usedGroupIds.contains(group.matGroupGuid)).toList();

// 🔹 4. البائعون المستخدمون في الفواتير
    final usedSellerIds = allBills.map((bill) => bill.billDetails.billSellerId).whereType<String>().toSet();

    final usedSellers = read<SellersController>().sellers.where((seller) => usedSellerIds.contains(seller.costGuid)).toList();
    nestedBills.clear();
    nestedBills[bills.first.billTypeModel] = [bills.last];
    final xmlString = xmlService.generateFullXml(
      bills: nestedBills,
      bonds: {} /*read<AllBondsController>().bondsByTypeGuid*/,
      materials: usedMaterials,
      cheques: [] /* read<AllChequesController>().chequesList*/,
      customers: usedCustomers /*read<CustomersController>().customers*/,
      accounts: usedAccounts,
      groups: usedGroups,
      allStore: StoreAccount.values.toList(),
      sellers: usedSellers,
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/exported_file.xml');
    await file.writeAsString(xmlString);
    log('✅ تم حفظ الملف: ${file.path}');
  }

  Future<void> fetchAllNestedBills() async {
    getAllNestedBillsRequestState.value = RequestState.loading;

    final result = await _billsFirebaseRepo.fetchAllNested(read<PatternController>().billsTypes);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedNestedBills) {
        nestedBills.assignAll(fetchedNestedBills);
      },
    );

    billsByTypeGuid.assignAll(nestedBills.map((billType, bills) => MapEntry(billType.billTypeId!, bills)));
    nestedBills.forEach((k, v) => log('bill Type: ${k.billTypeLabel} has ${v.length} bills'));

    allNestedBills.assignAll(nestedBills.values.expand((bills) => bills).toList());

    log("allNestedBills is ${allNestedBills.length}");
/*
    await createAndStoreMatsStatements(
      sourceModels: allNestedBills,
      onProgress: (progress) {
        uploadProgress.value = progress; // Update progress
        log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      },
    );
*/

/*    await createAndStoreEntryBonds(
      sourceModels: allNestedBills,
      onProgress: (progress) {
        uploadProgress.value = progress; // Update progress
        log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      },
    );*/
    getAllNestedBillsRequestState.value = RequestState.success;
  }

  Future<void> fetchAllBillsFromLocal() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      //     saveAllBillsRequestState.value = RequestState.loading;
      final result = await _jsonImportExportRepo.importXmlFile(File(resultFile.files.single.path!));

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedBills) => _onFetchBillsFromLocalSuccess(fetchedBills),
      );
    }
  }

  void _onFetchBillsFromLocalSuccess(List<BillModel> fetchedBills) async {
    log("fetchedBills length ${fetchedBills.length}");

    bills.assignAll(fetchedBills);

    saveAllBillsRequestState.value = RequestState.loading;

    if (fetchedBills.isNotEmpty) {
      log("saveAllNested _billsFirebaseRepo Started......");
      await _billsFirebaseRepo.saveAllNested(
        items: fetchedBills,
        itemIdentifiers: read<PatternController>().billsTypes,
        onProgress: (progress) {
          uploadProgress.value = progress; // Update progress
          log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );
      log("saveAllNested _billsFirebaseRepo Finished......");

      // await createAndStoreMatsStatements(
      //   sourceModels: fetchedBills,
      //   onProgress: (progress) {
      //     uploadProgress.value = progress; // Update progress
      //     log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      //   },
      // );
      //
      // await createAndStoreEntryBonds(
      //   sourceModels: fetchedBills,
      //   onProgress: (progress) {
      //     uploadProgress.value = progress; // Update progress
      //     log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
      //   },
      // );
    }
    saveAllBillsRequestState.value = RequestState.success;

    AppUIUtils.onSuccess("تم تحميل الفواتير بنجاح");
  }

  Future<void> fetchPendingBills(BillTypeModel billTypeModel) async {
    final result =
        await _billsFirebaseRepo.fetchWhere(itemIdentifier: billTypeModel, field: ApiConstants.status, value: Status.pending.value);

    result.fold(
      (failure) => AppUIUtils.onFailure('لا يوجد فواتير معلقة في ${billTypeModel.fullName}'),
      (fetchedPendingBills) {
        pendingBills.assignAll(fetchedPendingBills);
        navigateToPendingBillsScreen();
      },
    );

    isBillsLoading = false;
    update();
  }

  Future<void> fetchNunPendingBills(BillTypeModel billTypeModel, BuildContext context) async {
    isBillsLoading = true;
    update();

    // launchFloatingWindow(context: context, floatingScreen: AllBillsScreen());
    navigateToPendingBillsScreen();
    final result =
        await _billsFirebaseRepo.fetchWhere(itemIdentifier: billTypeModel, field: ApiConstants.status, value: Status.approved.value);

    result.fold(
      (failure) => AppUIUtils.onFailure('لا يوجد فواتير  في ${billTypeModel.fullName}'),
      (fetchedPendingBills) {
        bills.assignAll(fetchedPendingBills);
      },
    );

    isBillsLoading = false;
    update();
  }

  lunchBillsScreen(List<BillModel> billsList, BuildContext context) {
    bills.assignAll(billsList);
    isBillsLoading = false;
    launchFloatingWindow(
        context: context,
        floatingScreen: AllBillsScreen(
          bills: bills,
        ));
  }

  Future<List<BillModel>> fetchBillsByDate(BillTypeModel billTypeModel, DateFilter dateFilter) async {
    final result = await _billsFirebaseRepo.fetchWhere(itemIdentifier: billTypeModel, dateFilter: dateFilter);
    List<BillModel> allBills = [];
    result.fold(
      (failure) => AppUIUtils.onFailure(
          'لا يوجد فواتير في ${billTypeModel.fullName} خلال الفترة: ${dateFilter.range.start} - ${dateFilter.range.end}'),
      (fetchedBills) => allBills = fetchedBills,
    );

    return allBills;
  }

  Future<List<BillModel>> fetchBills(BillTypeModel billTypeModel) async {
    final result = await _billsFirebaseRepo.getAll(billTypeModel);
    List<BillModel> allBills = [];
    result.fold(
      (failure) => AppUIUtils.onFailure('لا يوجد فواتير في ${billTypeModel.fullName} '),
      (fetchedBills) {
        bills.assignAll(fetchedBills);
        allBills = fetchedBills;
      },
    );

    return allBills;
  }

  Future<Either<Failure, List<BillModel>>> fetchBillByNumber({required BillTypeModel billTypeModel, required int billNumber}) async {
    final result = await _billsFirebaseRepo.fetchWhere(itemIdentifier: billTypeModel, field: ApiConstants.billNumber, value: billNumber);

    return result;
  }

  Future<void> searchBill({
    required String searchInput,
    required String searchType,
    required BuildContext context,
  }) async {
    List<BillModel> searchResults = [];

    for (final billTypeModel in read<PatternController>().billsTypes) {
      final result = await _billsFirebaseRepo.fetchWhere(
        itemIdentifier: billTypeModel,
        field: searchType == 'phone' ? ApiConstants.customerPhone : ApiConstants.orderNumber,
        value: searchInput,
      );

      result.fold(
        (failure) {},
        (bills) => searchResults.addAll(bills),
      );
    }

    if (searchResults.isEmpty) {
      // Show a message if no results found
      AppUIUtils.onFailure('لا يوجد نتائج للبحث');
    } else {
      if (!context.mounted) return;

      launchFloatingWindow(
          context: context,
          floatingScreen: AllBillsScreen(
            bills: searchResults,
          ));
    }
  }

  Future<void> fetchBillsTypes() async {
    getBillsTypesRequestState.value = RequestState.loading;

    final List<BillTypeModel> fetchedBillTypes = await read<PatternController>().getAllBillTypes();
    _handleFetchBillTypesSuccess(fetchedBillTypes);
    read<StoreCartController>().fetchAllStoreCart();
  }

  Future<void> _handleFetchBillTypesSuccess(List<BillTypeModel> fetchedBillTypes) async {
    await fetchPendingBillsCountsByTypes(fetchedBillTypes);
    await fetchAllBillsCountsByTypes(fetchedBillTypes);

    getBillsTypesRequestState.value = RequestState.success;
  }

  Future<void> fetchPendingBillsCountsByTypes(List<BillTypeModel> fetchedBillTypes) async {
    // Clear the existing counts to avoid accumulation
    pendingBillsCountsByType.clear();

    final List<Future<void>> fetchTasks = [];
    final errors = <String>[]; // Collect error messages.

    for (final billTypeModel in fetchedBillTypes) {
      fetchTasks.add(
        _billsFirebaseRepo
            .count(
          itemIdentifier: billTypeModel,
          countQueryFilter: QueryFilter(field: ApiConstants.status, value: Status.pending.value),
        )
            .then((result) {
          result.fold(
            (failure) => errors.add('Failed to fetch count for ${billTypeModel.fullName}: ${failure.message}'),
            (int count) => pendingBillsCountsByType[billTypeModel] = count,
          );
        }),
      );
    }

    // Wait for all tasks to complete.
    await Future.wait(fetchTasks);

    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some counts failed to fetch: ${errors.join(', ')}');
    }
  }

  Future<void> fetchAllBillsCountsByTypes(List<BillTypeModel> fetchedBillTypes) async {
    // Clear the existing counts to avoid accumulation
    allBillsCountsByType.clear();

    final List<Future<void>> fetchTasks = [];
    final errors = <String>[]; // Collect error messages.

    for (final billTypeModel in fetchedBillTypes) {
      fetchTasks.add(
        _billsFirebaseRepo.count(itemIdentifier: billTypeModel).then((result) {
          result.fold(
            (failure) => errors.add('Failed to fetch count for ${billTypeModel.fullName}: ${failure.message}'),
            (int count) => allBillsCountsByType[billTypeModel] = count,
          );
        }),
      );
    }

    // Wait for all tasks to complete.
    await Future.wait(fetchTasks);

    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some counts failed to fetch: ${errors.join(', ')}');
    }
  }

  Future<void> exportBillsJsonFile() async {
    if (bills.isEmpty) {
      AppUIUtils.onFailure('لا توجد فواتير للتصدير');
      return;
    }

    final result = await _jsonImportExportRepo.exportJsonFile(bills);

    result.fold(
      (failure) => AppUIUtils.onFailure('فشل في تصدير الملف [${failure.message}]'),
      (filePath) => AppUIUtils.showExportSuccessDialog(filePath, 'تم تصدير الفواتير بنجاح!', 'تم تصدير الملف إلى:'),
    );
  }

  void navigateToAllBillsScreen() => to(AppRoutes.showAllBillsScreen);

  void navigateToPendingBillsScreen() => to(AppRoutes.showPendingBillsScreen);

  List<BillModel> getBillsByType(String billTypeId) {
    if (bills.isEmpty) return [];
    fetchAllNestedBills();
    return bills.where((bill) => bill.billTypeModel.billTypeId == billTypeId).toList();
  }

  void openFloatingBillDetailsById({required String billId, required BuildContext context, required BillTypeModel bilTypeModel}) async {
    final BillModel? billModel = await fetchBillById(billId, bilTypeModel);

    if (billModel == null) return;

    if (!context.mounted) return;

    openFloatingBillDetails(context, billModel.billTypeModel, currentBill: billModel);
  }

  Future<List<BillModel>> billsCountByType(BillTypeModel billTypeModel) async {
    int billsCountByType = await getLastNumber(
      // category: '${read<MigrationController>().currentVersion}${ApiConstants.bills}',
      category: ApiConstants.bills,
      entityType: billTypeModel.billTypeLabel!,
    );

    return _billUtils.appendEmptyBillModelNew(billTypeModel, billsCountByType);
  }

  Future<void> openFloatingBillDetails(BuildContext context, BillTypeModel billTypeModel, {BillModel? currentBill}) async {
    final bills = await billsCountByType(billTypeModel);

    if (!context.mounted) return;

    _openBillDetailsFloatingWindow(
      context: context,
      lastBillNumber: bills.last.billDetails.billNumber!,
      currentBill: currentBill ?? bills.last,
    );
  }

  // Opens the 'Bill Details' floating window.

  Future<void> _openBillDetailsFloatingWindow(
      {required BuildContext context, required int lastBillNumber, required BillModel currentBill}) async {
    final String controllerTag = AppServiceUtils.generateUniqueTag('FloatingBillDetails');

    final Map<String, GetxController> controllers = setupControllers(
      params: {
        'tag': controllerTag,
        'billsFirebaseRepo': _billsFirebaseRepo,
        'serialNumbersRepo': _serialNumbersRepo,
        'billTypeModel': currentBill.billTypeModel,
        'billItems': currentBill.items,
      },
    );

    final billDetailsController = controllers['billDetailsController'] as BillDetailsController;
    final billDetailsPlutoController = controllers['billDetailsPlutoController'] as BillDetailsPlutoController;
    final billSearchController = controllers['billSearchController'] as BillSearchController;

    await billSearchController.initialize(
      initialBill: currentBill,
      lastBillNumber: lastBillNumber,
      billDetailsController: billDetailsController,
      billDetailsPlutoController: billDetailsPlutoController,
    );

    if (!context.mounted) return;

    launchFloatingWindow(
      context: context,
      tag: controllerTag,
      minimizedTitle: BillType.byLabel(currentBill.billTypeModel.billTypeLabel!).value,
      floatingScreen: BillDetailsScreen(
        billDetailsController: billDetailsController,
        billDetailsPlutoController: billDetailsPlutoController,
        billSearchController: billSearchController,
        tag: controllerTag,
      ),
      onCloseCallback: () {
        delete<BillSearchController>(tag: controllerTag, force: true);
        delete<BillDetailsController>(tag: controllerTag, force: true);
        delete<BillDetailsPlutoController>(tag: controllerTag, force: true);
        delete<FloatingWindowController>(tag: controllerTag, force: true);
      },
    );
  }

  Future<BillModel?> fetchBillById(String billId, BillTypeModel billTypeModel) async {
    final result = await _billsFirebaseRepo.getById(id: billId, itemIdentifier: billTypeModel);

    return result.fold(
      (failure) {
        AppUIUtils.onFailure(failure.message);
        return null;
      },
      (fetchedBill) => fetchedBill,
    );
  }

  Future<void> fetchAllBillsMetaDataByTypes(List<BillTypeModel> fetchedBillTypes) async {
    final List<Future<void>> fetchTasks = [];
    final errors = <String>[]; // Collect error messages.

    for (final billTypeModel in fetchedBillTypes) {
      fetchTasks.add(
        _billsFirebaseRepo.getMetaData(id: billTypeModel.billTypeId!, itemIdentifier: billTypeModel).then((result) {
          result.fold(
            (failure) => errors.add('Failed to fetch count for ${billTypeModel.fullName}: ${failure.message}'),
            (double? count) => allBillsCountsByType[billTypeModel] = (count ?? 0).toInt(),
          );
        }),
      );
    }

    // Wait for all tasks to complete.
    await Future.wait(fetchTasks);

    // Handle errors if any.
    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some counts failed to fetch: ${errors.join(', ')}');
    }
  }

  Future<void> fetchXXXXXX() async {
    _billsFirebaseRepo.getMetaData(id: BillType.transferOut.typeGuide, itemIdentifier: BillType.transferOut.billTypeModel).then((result) {
      result.fold(
        (failure) => AppUIUtils.onFailure('Failed to fetch count for ${BillType.transferOut.label}: ${failure.message}'),
        (double? count) {
          log(count.toString());
        },
      );
    });
  }

  Future<void> getSerialNumberStatement(String serialNumberInput, {required BuildContext context}) async {
    final result = await _serialNumbersRepo.getById(serialNumberInput);

    result.fold(
      (failure) => AppUIUtils.onFailure('⚠️ لم يتم العثور على أي فواتير  تم ذكر فيها هذا الرقم التسلسلي [$serialNumberInput] ❌'),
      (SerialNumberModel fetchedSerialNumberModel) {
        // Clear previous statements before adding new ones.
        serialNumberStatements.clear();

        // Iterate through transactions and create SerialTransactionModels.
        List<SerialTransactionModel> transactionsList = [];

        for (SerialTransactionModel transaction in fetchedSerialNumberModel.transactions) {
          // Always add the transaction as a buy transaction
          transactionsList.add(
            SerialTransactionModel(
              buyBillId: transaction.buyBillId,
              buyBillNumber: transaction.buyBillNumber,
              buyBillTypeId: transaction.buyBillTypeId,
              sellBillId: transaction.sellBillId,
              sellBillNumber: transaction.sellBillNumber,
              sellBillTypeId: transaction.sellBillTypeId,
              entryDate: transaction.entryDate,
              sold: transaction.sold,
              transactionOrigin: SerialTransactionOrigin(
                serialNumber: fetchedSerialNumberModel.serialNumber,
                matId: fetchedSerialNumberModel.matId,
                matName: fetchedSerialNumberModel.matName,
              ),
            ),
          );
        }

        // Assign the generated list to serialNumberStatements
        serialNumberStatements.assignAll(transactionsList);

        // Open the statement screen to display results
        launchFloatingWindow(
          context: context,
          floatingScreen: SerialsStatementScreenScreen(),
          minimizedTitle: serialNumbersStatementScreenTitle,
        );
      },
    );
  }

  void onSerialSelected(PlutoGridOnSelectedEvent event, BuildContext context) {
    // Extract cell values safely
    final String? sold = event.row?.cells['sold']?.value;
    final String? buyBillId = event.row?.cells['buyBillId']?.value;
    final String? sellBillId = event.row?.cells['sellBillId']?.value;
    final String? buyBillTypeId = event.row?.cells['buyBillTypeId']?.value;
    final String? sellBillTypeId = event.row?.cells['sellBillTypeId']?.value;

    // Determine bill details based on sold status
    final bool isSold = sold == AppStrings.yes.tr;
    final String? billId = isSold ? sellBillId : buyBillId;
    final String? billTypeId = isSold ? sellBillTypeId : buyBillTypeId;

    log('isSold: $isSold');

    if (billId != null && billTypeId != null) {
      openFloatingBillDetailsById(billId: billId, context: context, bilTypeModel: BillType.byTypeGuide(billTypeId).billTypeModel);
    } else {
      AppUIUtils.onFailure('⚠️ Missing Bill ID or Bill Type ID');
    }
  }

  bool isLoadingPlutoGrid = false;
  final List<SerialTransactionModel> serialNumberStatements = [];

  String get serialNumbersStatementScreenTitle => AppStrings.serialNumbersStatement.tr;

  double get totalBillsSum => bills.fold(
        0.0,
        (previousValue, element) => previousValue + (element.billDetails.billTotal ?? 1),
      );
}

// 30 - 22 -> 52
// 23 - 12 -> 35
// 25 - 4  -> 29