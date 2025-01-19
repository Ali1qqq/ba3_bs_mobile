import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/i_remote_database_service.dart';
import 'package:ba3_bs_mobile/core/services/json_file_operations/implementations/import_export_repo.dart';
import 'package:ba3_bs_mobile/core/services/translation/interfaces/i_translation_service.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/accounts/data/datasources/remote/account_data_source.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs_mobile/features/bill/services/bill/bill_import.dart';
import 'package:ba3_bs_mobile/features/bond/service/bond/bond_import.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/data/datasources/cheques_compound_data_source.dart';
import 'package:ba3_bs_mobile/features/cheques/data/models/cheques_model.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/datasources/remote/materials_data_source.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/material_model.dart';
import 'package:ba3_bs_mobile/features/materials/service/material_export.dart';
import 'package:ba3_bs_mobile/features/print/controller/print_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/data/datasources/remote/sellers_data_source.dart';
import 'package:ba3_bs_mobile/features/sellers/data/models/seller_model.dart';
import 'package:ba3_bs_mobile/features/user_time/data/repositories/user_time_repo.dart';
import 'package:ba3_bs_mobile/features/users_management/data/datasources/roles_data_source.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../features/accounts/controllers/account_statement_controller.dart';
import '../../features/accounts/data/datasources/remote/accounts_statements_data_source.dart';
import '../../features/accounts/data/datasources/remote/entry_bonds_data_source.dart';
import '../../features/accounts/service/account_export.dart';
import '../../features/accounts/service/account_import.dart';
import '../../features/bill/controllers/bill/all_bills_controller.dart';
import '../../features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import '../../features/bill/data/datasources/bills_compound_data_source.dart';
import '../../features/bill/data/models/bill_model.dart';
import '../../features/bill/services/bill/bil_export.dart';
import '../../features/bond/controllers/bonds/all_bond_controller.dart';
import '../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../features/bond/data/datasources/bonds_compound_data_source.dart';
import '../../features/bond/data/models/bond_model.dart';
import '../../features/bond/data/models/entry_bond_model.dart';
import '../../features/bond/service/bond/bond_export.dart';
import '../../features/changes/controller/changes_controller.dart';
import '../../features/changes/data/datasources/changes_datasource.dart';
import '../../features/changes/data/model/changes_model.dart';
import '../../features/cheques/service/cheques_export.dart';
import '../../features/cheques/service/cheques_import.dart';
import '../../features/materials/data/datasources/local/material_local_data_source.dart';
import '../../features/materials/service/material_import.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/data/datasources/patterns_data_source.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import '../../features/pluto/controllers/pluto_controller.dart';
import '../../features/sellers/controllers/add_seller_controller.dart';
import '../../features/user_time/controller/user_time_controller.dart';
import '../../features/users_management/data/datasources/users_data_source.dart';
import '../helper/extensions/getx_controller_extensions.dart';
import '../network/api_constants.dart';
import '../services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import '../services/entry_bond_creator/interfaces/i_entry_bonds_generator.dart';
import '../services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../services/firebase/implementations/repos/listen_datasource_repo.dart';
import '../services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../services/firebase/implementations/services/compound_firestore_service.dart';
import '../services/firebase/implementations/services/firestore_service.dart';
import '../services/firebase/interfaces/i_compound_database_service.dart';
import '../services/json_file_operations/interfaces/export/i_export_service.dart';
import '../services/json_file_operations/interfaces/import/i_import_service.dart';
import '../services/local_database/implementations/repos/local_datasource_repo.dart';
import '../services/local_database/implementations/services/hive_database_service.dart';
import '../services/local_database/interfaces/i_local_database_service.dart';
import '../services/translation/implementations/dio_client.dart';
import '../services/translation/implementations/google_translation_service.dart';
import '../services/translation/implementations/translation_repo.dart';
import '../services/translation/interfaces/i_api_client.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() async {
// Initialize services
    final dioClient = _initializeDioClient();

    final fireStoreService = _initializeFireStoreService();

    final materialsHiveService = await _initializeHiveService<MaterialModel>(boxName: ApiConstants.materials);

    final compoundFireStoreService = _initializeCompoundFireStoreService();

    final translationService = _initializeTranslationService(dioClient);

    final entryBondGenerator = _initializeEntryBondGenerator();

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
      materialsHiveService: materialsHiveService,
    );

    // Register the EntryBondRepository and inject the generator
    lazyPut(EntryBondsGeneratorRepo(entryBondGenerator));

    lazyPut(repositories.listenableDatasourceRepo);

    // Permanent Controllers
    _initializePermanentControllers(repositories);

    // Lazy Controllers
    _initializeLazyControllers(repositories);
  }

  // Initialize external services
  IAPiClient _initializeDioClient() => DioClient<Map<String, dynamic>>(Dio());

  IRemoteDatabaseService<Map<String, dynamic>> _initializeFireStoreService() => FireStoreService();

  ICompoundDatabaseService<Map<String, dynamic>> _initializeCompoundFireStoreService() => CompoundFireStoreService();

  IEntryBondGenerator _initializeEntryBondGenerator() => EntryBondsGenerator();

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
    required ILocalDatabaseService<MaterialModel> materialsHiveService,
  }) {
    return _Repositories(
      translationRepo: TranslationRepository(translationService),
      patternsRepo: RemoteDataSourceRepository(PatternsDatasource(databaseService: fireStoreService)),
      billsRepo:
          CompoundDatasourceRepository(BillCompoundDatasource(compoundDatabaseService: compoundFireStoreService)),
      bondsRepo:
          CompoundDatasourceRepository(BondCompoundDatasource(compoundDatabaseService: compoundFireStoreService)),
      chequesRepo:
          CompoundDatasourceRepository(ChequesCompoundDatasource(compoundDatabaseService: compoundFireStoreService)),
      rolesRepo: RemoteDataSourceRepository(RolesDatasource(databaseService: fireStoreService)),
      usersRepo: FilterableDatasourceRepository(UsersDatasource(databaseService: fireStoreService)),
      entryBondsRepo: RemoteDataSourceRepository(EntryBondsDatasource(databaseService: fireStoreService)),
      accountsStatementsRepo:
          CompoundDatasourceRepository(AccountsStatementsDatasource(compoundDatabaseService: compoundFireStoreService)),
      billImportExportRepo: ImportExportRepository(billImportService, billExportService),
      chequesImportExportRepo: ImportExportRepository(chequesImportService, chequesExportService),
      userTimeRepo: UserTimeRepository(),
      sellersRepo: BulkSavableDatasourceRepository(SellersDatasource(databaseService: fireStoreService)),
      materialsRepo: QueryableSavableRepository(MaterialsDatasource(databaseService: fireStoreService)),
      accountsRep: BulkSavableDatasourceRepository(AccountsDatasource(databaseService: fireStoreService)),
      bondImportExportRepo: ImportExportRepository(bondImportService, bondExportService),
      materialImportExportRepo: ImportExportRepository(materialImportService, materialExportService),
      accountImportExportRepo: ImportExportRepository(accountImportService, accountExportService),
      materialsLocalDatasourceRepo: LocalDatasourceRepository(
          localDatasource: MaterialsLocalDatasource(materialsHiveService),
          remoteDatasource: MaterialsDatasource(databaseService: fireStoreService)),
      listenableDatasourceRepo: ListenDataSourceRepository(
        ChangesListenDatasource(databaseService: fireStoreService),
      ),
    );
  }

// Permanent Controllers Initialization
  void _initializePermanentControllers(_Repositories repositories) {
    put(
      SellersController(repositories.sellersRepo),
      permanent: true,
    );
  }

// Lazy Controllers Initialization
  void _initializeLazyControllers(_Repositories repositories) {
    lazyPut(PlutoController());
    lazyPut(EntryBondController(repositories.entryBondsRepo, repositories.accountsStatementsRepo));
    lazyPut(PatternController(repositories.patternsRepo));
    lazyPut(AllBillsController(repositories.patternsRepo, repositories.billsRepo, repositories.billImportExportRepo));
    lazyPut(AllBondsController(repositories.bondsRepo, repositories.bondImportExportRepo));
    lazyPut(AllChequesController(repositories.chequesRepo, repositories.chequesImportExportRepo));
    lazyPut(BillDetailsPlutoController());
    lazyPut(AccountsController(repositories.accountImportExportRepo, repositories.accountsRep));
    lazyPut(PrintingController(repositories.translationRepo));
    lazyPut(BillSearchController());
    lazyPut(AccountStatementController(repositories.accountsStatementsRepo));
    lazyPut(UserTimeController(repositories.usersRepo, repositories.userTimeRepo));
    lazyPut(SellerSalesController(repositories.billsRepo, repositories.sellersRepo));
    lazyPut(MaterialController(
      repositories.materialImportExportRepo,
      repositories.materialsLocalDatasourceRepo,
      repositories.listenableDatasourceRepo,
    ));
    lazyPut(
      ChangesController(repositories.listenableDatasourceRepo),
    );
    lazyPut(() => AddSellerController());
  }
}

// Helper class to group repositories
class _Repositories {
  final TranslationRepository translationRepo;
  final RemoteDataSourceRepository<BillTypeModel> patternsRepo;
  final CompoundDatasourceRepository<BillModel, BillTypeModel> billsRepo;
  final CompoundDatasourceRepository<BondModel, BondType> bondsRepo;
  final CompoundDatasourceRepository<ChequesModel, ChequesType> chequesRepo;
  final RemoteDataSourceRepository<RoleModel> rolesRepo;
  final FilterableDatasourceRepository<UserModel> usersRepo;
  final RemoteDataSourceRepository<EntryBondModel> entryBondsRepo;
  final CompoundDatasourceRepository<EntryBondItems, AccountEntity> accountsStatementsRepo;
  final ImportExportRepository<BillModel> billImportExportRepo;
  final ImportExportRepository<BondModel> bondImportExportRepo;
  final ImportExportRepository<MaterialModel> materialImportExportRepo;
  final ImportExportRepository<AccountModel> accountImportExportRepo;
  final ImportExportRepository<ChequesModel> chequesImportExportRepo;
  final UserTimeRepository userTimeRepo;
  final BulkSavableDatasourceRepository<SellerModel> sellersRepo;
  final BulkSavableDatasourceRepository<AccountModel> accountsRep;
  final QueryableSavableRepository<MaterialModel> materialsRepo;
  final LocalDatasourceRepository<MaterialModel> materialsLocalDatasourceRepo;
  final ListenDataSourceRepository<ChangesModel> listenableDatasourceRepo;

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
    required this.accountImportExportRepo,
    required this.chequesImportExportRepo,
    required this.accountsRep,
    required this.materialsRepo,
    required this.materialsLocalDatasourceRepo,
    required this.listenableDatasourceRepo,
  });
}
