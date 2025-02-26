import 'package:ba3_bs_mobile/core/services/translation/interfaces/i_api_client.dart';
import 'package:ba3_bs_mobile/features/cheques/service/cheques_export.dart';
import 'package:ba3_bs_mobile/features/materials/service/materials_groups_import.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:hive/hive.dart';

import '../../features/accounts/controllers/account_statement_controller.dart';
import '../../features/accounts/controllers/accounts_controller.dart';
import '../../features/accounts/data/datasources/remote/account_data_source.dart';
import '../../features/accounts/data/datasources/remote/accounts_statements_data_source.dart';
import '../../features/accounts/data/datasources/remote/entry_bonds_data_source.dart';
import '../../features/accounts/data/models/account_model.dart';
import '../../features/accounts/service/account_export.dart';
import '../../features/accounts/service/account_import.dart';
import '../../features/bill/controllers/bill/all_bills_controller.dart';
import '../../features/bill/data/datasources/bills_compound_data_source.dart';
import '../../features/bill/data/models/bill_model.dart';
import '../../features/bill/services/bill/bil_export.dart';
import '../../features/bill/services/bill/bill_import.dart';
import '../../features/bond/controllers/bonds/all_bond_controller.dart';
import '../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../features/bond/data/datasources/bonds_compound_data_source.dart';
import '../../features/bond/data/models/bond_model.dart';
import '../../features/bond/data/models/entry_bond_model.dart';
import '../../features/bond/service/bond/bond_export.dart';
import '../../features/bond/service/bond/bond_import.dart';
import '../../features/changes/controller/changes_controller.dart';
import '../../features/changes/data/datasources/changes_datasource.dart';
import '../../features/changes/data/model/changes_model.dart';
import '../../features/cheques/controllers/cheques/all_cheques_controller.dart';
import '../../features/cheques/data/datasources/cheques_compound_data_source.dart';
import '../../features/cheques/data/models/cheques_model.dart';
import '../../features/cheques/service/cheques_import.dart';
import '../../features/customer/controllers/customers_controller.dart';
import '../../features/customer/data/datasources/remote/customers_data_source.dart';
import '../../features/customer/data/models/customer_model.dart';
import '../../features/customer/service/customer_import.dart';
import '../../features/materials/controllers/material_controller.dart';
import '../../features/materials/controllers/material_group_controller.dart';
import '../../features/materials/controllers/mats_statement_controller.dart';
import '../../features/materials/data/datasources/local/material_local_data_source.dart';
import '../../features/materials/data/datasources/remote/materials_data_source.dart';
import '../../features/materials/data/datasources/remote/materials_groups_data_source.dart';
import '../../features/materials/data/datasources/remote/materials_serials_data_source.dart';
import '../../features/materials/data/datasources/remote/materials_statements_data_source.dart';
import '../../features/materials/data/models/mat_statement/mat_statement_model.dart';
import '../../features/materials/data/models/materials/material_group.dart';
import '../../features/materials/data/models/materials/material_model.dart';
import '../../features/materials/service/material_export.dart';
import '../../features/materials/service/material_import.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/data/datasources/patterns_data_source.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import '../../features/pluto/controllers/pluto_controller.dart';
import '../../features/print/controller/print_controller.dart';
import '../../features/profile/controller/user_time_controller.dart';
import '../../features/sellers/controllers/add_seller_controller.dart';
import '../../features/sellers/controllers/seller_sales_controller.dart';
import '../../features/sellers/controllers/sellers_controller.dart';
import '../../features/sellers/data/datasources/remote/sellers_data_source.dart';
import '../../features/sellers/data/models/seller_model.dart';
import '../../features/sellers/service/seller_import.dart';
import '../../features/user_time/data/repositories/user_time_repo.dart';
import '../../features/users_management/controllers/user_details_controller.dart';
import '../../features/users_management/data/datasources/roles_data_source.dart';
import '../../features/users_management/data/datasources/users_data_source.dart';
import '../../features/users_management/data/models/role_model.dart';
import '../../features/users_management/data/models/user_model.dart';
import '../helper/enums/enums.dart';
import '../helper/extensions/getx_controller_extensions.dart';
import '../network/api_constants.dart';
import '../services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import '../services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../services/firebase/implementations/repos/filterable_datasource_repo.dart';
import '../services/firebase/implementations/repos/listen_datasource_repo.dart';
import '../services/firebase/implementations/repos/queryable_savable_repo.dart';
import '../services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../services/firebase/implementations/services/compound_firestore_service.dart';
import '../services/firebase/implementations/services/firestore_service.dart';
import '../services/firebase/interfaces/i_compound_database_service.dart';
import '../services/firebase/interfaces/i_remote_database_service.dart';
import '../services/json_file_operations/implementations/import/import_repo.dart';
import '../services/json_file_operations/implementations/import_export_repo.dart';
import '../services/json_file_operations/interfaces/export/i_export_service.dart';
import '../services/json_file_operations/interfaces/import/i_import_repository.dart';
import '../services/json_file_operations/interfaces/import/i_import_service.dart';
import '../services/local_database/implementations/repos/local_datasource_repo.dart';
import '../services/local_database/implementations/services/hive_database_service.dart';
import '../services/local_database/interfaces/i_local_database_service.dart';
import '../services/translation/implementations/dio_client.dart';
import '../services/translation/implementations/google_translation_service.dart';
import '../services/translation/implementations/translation_repo.dart';
import '../services/translation/interfaces/i_translation_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() async {
// Initialize services
    final dioClient = _initializeDioClient();

    final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
    // final FirebaseFirestore firestoreInstance = FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'test');

    final fireStoreService = _initializeFireStoreService(firestoreInstance);

    final compoundFireStoreService = _initializeCompoundFireStoreService(firestoreInstance);

    lazyPut(firestoreInstance);

    final rolesRepo = RemoteDataSourceRepository(RolesDatasource(databaseService: fireStoreService));
    final usersRepo = FilterableDataSourceRepository(UsersDatasource(databaseService: fireStoreService));

    lazyPut(rolesRepo);

    lazyPut(usersRepo);

    final materialsHiveService = await _initializeHiveService<MaterialModel>(boxName: ApiConstants.materials);

    final translationService = _initializeTranslationService(dioClient);

    final billImport = BillImport();
    final billExport = BillExport();
    final bondImport = BondImport();
    final bondExport = BondExport();
    final materialImport = MaterialImport();
    final materialExport = MaterialExport();
    final accountImport = AccountImport();
    final accountExport = AccountExport();
    final chequesImport = ChequesImport();
    final chequesExport = ChequesExport();
    final sellersImport = SellerImport();
    final materialGroupImport = MaterialGroupImport();
    final customerImport = CustomerImport();

// Initialize repositories
    final repositories = _initializeRepositories(
      fireStoreService: fireStoreService,
      compoundFireStoreService: compoundFireStoreService,
      translationService: translationService,
      billImportService: billImport,
      billExportService: billExport,
      bondExportService: bondExport,
      bondImportService: bondImport,
      materialExportService: materialExport,
      materialImportService: materialImport,
      accountExportService: accountExport,
      accountImportService: accountImport,
      chequesExportService: chequesExport,
      chequesImportService: chequesImport,
      sellersImportService: sellersImport,
      materialsHiveService: materialsHiveService,
      importMaterialGroupService: materialGroupImport,
      customerImportService: customerImport,
    );

    // Register the EntryBondRepository and inject the generator

    lazyPut(repositories.listenableDatasourceRepo);

    // Permanent Controllers
    _initializePermanentControllers(repositories);

    // Lazy Controllers
    _initializeLazyControllers(repositories);
  }

  // Initialize external services
  IAPiClient _initializeDioClient() => DioClient<Map<String, dynamic>>(Dio());

  IRemoteDatabaseService<Map<String, dynamic>> _initializeFireStoreService(FirebaseFirestore instance) => FireStoreService(instance);

  ICompoundDatabaseService<Map<String, dynamic>> _initializeCompoundFireStoreService(FirebaseFirestore instance) =>
      CompoundFireStoreService(instance);

  ITranslationService _initializeTranslationService(IAPiClient dioClient) => GoogleTranslationService(
        baseUrl: ApiConstants.translationBaseUrl,
        apiKey: ApiConstants.translationApiKey,
        client: dioClient,
      );

  Future<ILocalDatabaseService<T>> _initializeHiveService<T>({required String boxName}) async {
    var box = await Hive.openBox<T>(boxName);
    return HiveDatabaseService(box);
  }

// Repositories Initialization
  _Repositories _initializeRepositories({
    required IRemoteDatabaseService<Map<String, dynamic>> fireStoreService,
    required ICompoundDatabaseService<Map<String, dynamic>> compoundFireStoreService,
    required ITranslationService translationService,
    required IImportService<BillModel> billImportService,
    required IExportService<BillModel> billExportService,
    required IImportService<BondModel> bondImportService,
    required IExportService<BondModel> bondExportService,
    required IImportService<MaterialModel> materialImportService,
    required IExportService<MaterialModel> materialExportService,
    required IImportService<AccountModel> accountImportService,
    required IExportService<AccountModel> accountExportService,
    required IImportService<ChequesModel> chequesImportService,
    required IExportService<ChequesModel> chequesExportService,
    required IImportService<SellerModel> sellersImportService,
    required ILocalDatabaseService<MaterialModel> materialsHiveService,
    required IImportService<MaterialGroupModel> importMaterialGroupService,
    required IImportService<CustomerModel> customerImportService,
  }) {
    return _Repositories(
      translationRepo: TranslationRepository(translationService),
      patternsRepo: RemoteDataSourceRepository(PatternsDatasource(databaseService: fireStoreService)),
      billsRepo: CompoundDatasourceRepository(BillCompoundDatasource(compoundDatabaseService: compoundFireStoreService)),
      bondsRepo: CompoundDatasourceRepository(BondCompoundDatasource(compoundDatabaseService: compoundFireStoreService)),
      chequesRepo: CompoundDatasourceRepository(ChequesCompoundDatasource(compoundDatabaseService: compoundFireStoreService)),
      rolesRepo: RemoteDataSourceRepository(RolesDatasource(databaseService: fireStoreService)),
      usersRepo: FilterableDataSourceRepository(UsersDatasource(databaseService: fireStoreService)),
      entryBondsRepo: RemoteDataSourceRepository(EntryBondsDatasource(databaseService: fireStoreService)),
      accountsStatementsRepo: CompoundDatasourceRepository(AccountsStatementsDatasource(compoundDatabaseService: compoundFireStoreService)),
      billImportExportRepo: ImportExportRepository(billImportService, billExportService),
      chequesImportExportRepo: ImportExportRepository(chequesImportService, chequesExportService),
      userTimeRepo: UserTimeRepository(),
      sellersRepo: BulkSavableDatasourceRepository(SellersDatasource(databaseService: fireStoreService)),
      materialsRemoteDatasourceRepo: QueryableSavableRepository(MaterialsRemoteDatasource(databaseService: fireStoreService)),
      accountsRep: BulkSavableDatasourceRepository(AccountsDatasource(databaseService: fireStoreService)),
      bondImportExportRepo: ImportExportRepository(bondImportService, bondExportService),
      materialImportExportRepo: ImportExportRepository(materialImportService, materialExportService),
      accountImportExportRepo: ImportExportRepository(accountImportService, accountExportService),
      sellerImportRepo: ImportRepository(sellersImportService),
      materialsLocalDatasourceRepo: LocalDatasourceRepository(
        localDatasource: MaterialsLocalDatasource(materialsHiveService),
        remoteDatasource: MaterialsRemoteDatasource(databaseService: fireStoreService),
      ),
      listenableDatasourceRepo: ListenDataSourceRepository(
        ChangesListenDatasource(databaseService: fireStoreService),
      ),
      importMaterialRepository: ImportRepository(importMaterialGroupService),
      materialGroupDataSource: QueryableSavableRepository(MaterialsGroupsDataSource(databaseService: fireStoreService)),
      customerImportRepo: ImportRepository(customerImportService),
      customersRepo: BulkSavableDatasourceRepository(CustomersDatasource(databaseService: fireStoreService)),
      matStatementsRepo: CompoundDatasourceRepository(
        MaterialsStatementsDatasource(compoundDatabaseService: compoundFireStoreService),
      ),
      serialNumbersRepo: QueryableSavableRepository(MaterialsSerialsDataSource(databaseService: fireStoreService)),
    );
  }

// Permanent Controllers Initialization
  void _initializePermanentControllers(_Repositories repositories) {
    put(
      SellersController(repositories.sellersRepo, repositories.sellerImportRepo),
      permanent: true,
    );
  }

// Lazy Controllers Initialization
  void _initializeLazyControllers(_Repositories repositories) {
    lazyPut(PlutoController());
    lazyPut(EntryBondController(repositories.entryBondsRepo, repositories.accountsStatementsRepo));
    lazyPut(PatternController(repositories.patternsRepo));
    // lazyPut(MaterialGroupController(repositories.importMaterialRepository, repositories.materialGroupDataSource));
    lazyPut(MaterialGroupController(repositories.importMaterialRepository, repositories.materialGroupDataSource));

    lazyPut(MaterialController(
      repositories.materialImportExportRepo,
      repositories.materialsLocalDatasourceRepo,
      repositories.listenableDatasourceRepo,
    ));
    lazyPut(MaterialsStatementController(repositories.matStatementsRepo));
    lazyPut(CustomersController(repositories.customersRepo, repositories.customerImportRepo));

    lazyPut(AllBillsController(repositories.billsRepo, repositories.serialNumbersRepo, repositories.billImportExportRepo));
    lazyPut(AllBondsController(repositories.bondsRepo, repositories.bondImportExportRepo));
    lazyPut(AllChequesController(repositories.chequesRepo, repositories.chequesImportExportRepo));

    lazyPut(AccountsController(repositories.accountImportExportRepo, repositories.accountsRep));

    lazyPut(PrintingController(repositories.translationRepo));

    lazyPut(AccountStatementController(repositories.accountsStatementsRepo));
    lazyPut(UserTimeController(repositories.usersRepo, repositories.userTimeRepo));
    lazyPut(SellerSalesController(repositories.billsRepo, repositories.sellersRepo));
    lazyPut(
      ChangesController(repositories.listenableDatasourceRepo),
    );
    lazyPut(() => AddSellerController());
    lazyPut(UserDetailsController(read<FilterableDataSourceRepository<UserModel>>()));
  }
}

class _Repositories {
  final TranslationRepository translationRepo;
  final RemoteDataSourceRepository<BillTypeModel> patternsRepo;
  final CompoundDatasourceRepository<BillModel, BillTypeModel> billsRepo;
  final CompoundDatasourceRepository<BondModel, BondType> bondsRepo;
  final CompoundDatasourceRepository<ChequesModel, ChequesType> chequesRepo;
  final RemoteDataSourceRepository<RoleModel> rolesRepo;
  final FilterableDataSourceRepository<UserModel> usersRepo;
  final RemoteDataSourceRepository<EntryBondModel> entryBondsRepo;
  final CompoundDatasourceRepository<EntryBondItems, AccountEntity> accountsStatementsRepo;
  final ImportExportRepository<BillModel> billImportExportRepo;
  final ImportExportRepository<BondModel> bondImportExportRepo;
  final ImportExportRepository<MaterialModel> materialImportExportRepo;
  final ImportRepository<SellerModel> sellerImportRepo;
  final ImportExportRepository<AccountModel> accountImportExportRepo;
  final ImportExportRepository<ChequesModel> chequesImportExportRepo;
  final UserTimeRepository userTimeRepo;
  final BulkSavableDatasourceRepository<SellerModel> sellersRepo;
  final BulkSavableDatasourceRepository<AccountModel> accountsRep;
  final QueryableSavableRepository<MaterialModel> materialsRemoteDatasourceRepo;
  final LocalDatasourceRepository<MaterialModel> materialsLocalDatasourceRepo;
  final ListenDataSourceRepository<ChangesModel> listenableDatasourceRepo;
  final IImportRepository<MaterialGroupModel> importMaterialRepository;
  final QueryableSavableRepository<MaterialGroupModel> materialGroupDataSource;
  final ImportRepository<CustomerModel> customerImportRepo;
  final BulkSavableDatasourceRepository<CustomerModel> customersRepo;
  final CompoundDatasourceRepository<MatStatementModel, String> matStatementsRepo;
  final QueryableSavableRepository<SerialNumberModel> serialNumbersRepo;

  _Repositories({
    required this.translationRepo,
    required this.patternsRepo,
    required this.billsRepo,
    required this.bondsRepo,
    required this.chequesRepo,
    required this.rolesRepo,
    required this.usersRepo,
    required this.entryBondsRepo,
    required this.accountsStatementsRepo,
    required this.billImportExportRepo,
    required this.userTimeRepo,
    required this.sellersRepo,
    required this.bondImportExportRepo,
    required this.materialImportExportRepo,
    required this.sellerImportRepo,
    required this.accountImportExportRepo,
    required this.chequesImportExportRepo,
    required this.accountsRep,
    required this.materialsRemoteDatasourceRepo,
    required this.materialsLocalDatasourceRepo,
    required this.listenableDatasourceRepo,
    required this.importMaterialRepository,
    required this.materialGroupDataSource,
    required this.customerImportRepo,
    required this.customersRepo,
    required this.matStatementsRepo,
    required this.serialNumbersRepo,
  });
}