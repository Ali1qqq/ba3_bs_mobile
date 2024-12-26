import 'package:ba3_bs_mobile/core/services/firebase/implementations/filterable_data_source_repo.dart';
import 'package:ba3_bs_mobile/core/services/firebase/interfaces/i_database_service.dart';
import 'package:ba3_bs_mobile/core/services/translation/interfaces/i_translation_service.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/accounts/data/repositories/accounts_repository.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs_mobile/features/cheques/data/datasources/cheques_data_source.dart';
import 'package:ba3_bs_mobile/features/cheques/data/models/cheques_model.dart';
import 'package:ba3_bs_mobile/features/main_layout/controllers/main_layout_controller.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/print/controller/print_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs_mobile/features/sellers/data/repositories/sellers_repository.dart';
import 'package:ba3_bs_mobile/features/user_time/data/repositories/user_time_repo.dart';
import 'package:ba3_bs_mobile/features/users_management/data/datasources/roles_data_source.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../features/accounts/controllers/account_statement_controller.dart';
import '../../features/accounts/data/datasources/remote/accounts_statements_data_source.dart';
import '../../features/accounts/data/datasources/remote/entry_bonds_data_source.dart';
import '../../features/bill/controllers/bill/all_bills_controller.dart';
import '../../features/bill/controllers/pluto/bill_details_pluto_controller.dart';
import '../../features/bill/data/datasources/bills_data_source.dart';
import '../../features/bill/data/models/bill_model.dart';
import '../../features/bill/services/bill/bill_json_export.dart';
import '../../features/bond/controllers/bonds/all_bond_controller.dart';
import '../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../features/bond/data/datasources/bond_data_source.dart';
import '../../features/bond/data/models/bond_model.dart';
import '../../features/bond/data/models/entry_bond_model.dart';
import '../../features/materials/data/repositories/materials_repository.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/data/datasources/patterns_data_source.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import '../../features/pluto/controllers/pluto_controller.dart';
import '../../features/user_time/controller/user_time_controller.dart';
import '../../features/users_management/controllers/user_management_controller.dart';
import '../../features/users_management/data/datasources/users_data_source.dart';
import '../network/api_constants.dart';
import '../services/firebase/implementations/datasource_repo.dart';
import '../services/firebase/implementations/firestore_service.dart';
import '../services/get_x/shared_preferences_service.dart';
import '../services/json_file_operations/implementations/export/json_export_repo.dart';
import '../services/translation/implementations/dio_client.dart';
import '../services/translation/implementations/google_translation.dart';
import '../services/translation/implementations/translation_repo.dart';
import '../services/translation/interfaces/i_api_client.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() async {
    // Initialize RemoteApiService instance
    IDatabaseService<Map<String, dynamic>> fireStoreService = FireStoreService();

    // Initialize repositories

    // Instantiate PatternsDataSource and FirebaseRepositoryConcrete of BillTypeModel
    final DataSourceRepository<BillTypeModel> patternsFirebaseRepo = DataSourceRepository(
      PatternsDataSource(databaseService: fireStoreService),
    );
    // Instantiate InvoicesDataSource and FirebaseRepositoryConcrete of BillModel
    final FilterableDataSourceRepository<BillModel> billsFirebaseRepo = FilterableDataSourceRepository(BillsDataSource(databaseService: fireStoreService));

    // Instantiate InvoicesDataSource and FirebaseRepositoryConcrete of BondModel
    final DataSourceRepository<BondModel> bondsFirebaseRepo = DataSourceRepository(
      BondsDataSource(databaseService: fireStoreService),
    );

    final DataSourceRepository<ChequesModel> chequesFirebaseRepo = DataSourceRepository(
      ChequesDataSource(databaseService: fireStoreService),
    );

    final DataSourceRepository<RoleModel> rolesFirebaseRepo = DataSourceRepository(
      RolesDataSource(databaseService: fireStoreService),
    );

    final FilterableDataSourceRepository<UserModel> usersFirebaseRepo = FilterableDataSourceRepository(
      UsersDataSource(databaseService: fireStoreService),
    );

    // Instantiate InvoicesDataSource and FirebaseRepositoryConcrete of BondModel
    final DataSourceRepository<EntryBondModel> entryBondsFirebaseRepo = DataSourceRepository(
      EntryBondsDataSource(databaseService: fireStoreService),
    );

    // Instantiate InvoicesDataSource and FirebaseRepositoryConcrete of BondModel
    final AccountsStatementsRepository accountsStatementsRepo = AccountsStatementsRepository(
      AccountsStatementsDataSource(),
    );
    final UserTimeRepository userTimeRepo = UserTimeRepository();

    // Instantiate Api client, GoogleTranslationDataSource and TranslationRepository
    // final IAPiClient httpClient = HttpClient<Map<String, dynamic>>(Client());
    final IAPiClient dioClient = DioClient<Map<String, dynamic>>(Dio());

    final ITranslationService googleTranslation = GoogleTranslation(baseUrl: ApiConstants.translationBaseUrl, apiKey: ApiConstants.translationApiKey, client: dioClient);

    final TranslationRepository translationRepo = TranslationRepository(googleTranslation);

    await Get.putAsync(() => SharedPreferencesService().init());
    Get.put(UserManagementController( rolesFirebaseRepo, usersFirebaseRepo), permanent: true);
    Get.put(UserTimeController(usersFirebaseRepo, userTimeRepo), permanent: true);

    Get.lazyPut(() => translationRepo, fenix: true);

    Get.lazyPut(() => billsFirebaseRepo, fenix: true);

    Get.lazyPut(() => bondsFirebaseRepo, fenix: true);

    Get.lazyPut(() => chequesFirebaseRepo, fenix: true);

    final billJsonExportRepo = JsonExportRepository<BillModel>(BillJsonExport());

    // Lazy load controllers
    Get.lazyPut(() => PlutoController(), fenix: true);
    Get.lazyPut(() => EntryBondController(entryBondsFirebaseRepo, accountsStatementsRepo), fenix: true);

    Get.lazyPut(() => PatternController(patternsFirebaseRepo), fenix: true);

    Get.lazyPut(() => AllBillsController(patternsFirebaseRepo, billsFirebaseRepo, billJsonExportRepo), fenix: true);
    Get.lazyPut(() => AllBondsController(bondsFirebaseRepo), fenix: true);
    Get.lazyPut(() => AllChequesController(chequesFirebaseRepo), fenix: true);

    Get.lazyPut(() => BillDetailsPlutoController(), fenix: true);

    Get.lazyPut(() => MaterialController(MaterialRepository()), fenix: true);
    Get.lazyPut(() => AccountsController(AccountsRepository()), fenix: true);
    Get.lazyPut(() => AccountsController(AccountsRepository()), fenix: true);
    Get.lazyPut(() => SellerController(SellersRepository()), fenix: true);

    Get.lazyPut(() => PrintingController(translationRepo), fenix: true);
    Get.lazyPut(() => MainLayoutController(), fenix: true);
    Get.lazyPut(() => BillSearchController(), fenix: true);
    Get.lazyPut(() => AccountStatementController(accountsStatementsRepo), fenix: true);
  }
}
