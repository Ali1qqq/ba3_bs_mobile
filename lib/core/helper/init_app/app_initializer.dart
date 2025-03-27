import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/hive_extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../features/bill/data/datasources/bills_compound_data_source.dart';
import '../../../features/bill/data/models/bill_model.dart';
import '../../../features/bond/data/datasources/bonds_compound_data_source.dart';
import '../../../features/bond/data/models/bond_model.dart';
import '../../../features/cheques/data/datasources/cheques_compound_data_source.dart';
import '../../../features/cheques/data/models/cheques_model.dart';
import '../../../features/migration/controllers/migration_controller.dart';
import '../../../features/migration/data/datasources/remote/migration_data_source.dart';
import '../../../features/migration/data/models/migration_model.dart';
import '../../../features/patterns/data/models/bill_type_model.dart';
import '../../../firebase_options.dart';
import '../../constants/app_constants.dart';
import '../../services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../services/firebase/implementations/services/compound_firestore_service.dart';
import '../../services/firebase/implementations/services/firestore_service.dart';
import '../../services/firebase/implementations/services/remote_config_service.dart';
import '../../services/firebase/interfaces/i_compound_database_service.dart';
import '../../services/firebase/interfaces/i_remote_database_service.dart';
import '../../services/local_database/implementations/services/hive_database_service.dart';
import '../../services/translation/translation_controller.dart';
import '../enums/enums.dart';
import '../extensions/getx_controller_extensions.dart';

Future<void> initializeAppServices() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    log('${details.exception}', name: 'FlutterError Error');
    FlutterError.presentError(details);
  };

  WidgetsFlutterBinding.ensureInitialized();

  //   await initializeWindowSettings();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initializeApp();

  await initializeAppLocalization(boxName: AppConstants.appLocalLangBox);

  setupDatabaseServices();

  setupMigrationDependencies();

  await RemoteConfigService.init();
}

Future<void> initializeAppLocalization({required String boxName}) async {
  final Box<String> box = await Hive.openBox<String>(boxName);

  final HiveDatabaseService<String> hiveLocalLangService = HiveDatabaseService(box);

  put(TranslationController(hiveLocalLangService));
}

void setupDatabaseServices() {
  // final FirebaseStorage firebaseStorageInstance = FirebaseStorage.instance;

  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  /// 🔹 To connect to a test Firebase project, use:

  // final FirebaseFirestore firestoreInstance = FirebaseFirestore.instanceFor(
  //   app: Firebase.app(),
  //   databaseId: 'test',
  // );

  // Initialize Firestore services
  final remoteDatabaseService = createRemoteDatabaseService(firestoreInstance);

  final compoundDatabaseService = createCompoundDatabaseService(firestoreInstance);

  //final remoteStorageService = createRemoteStorageService(firebaseStorageInstance);

  // Register dependencies using lazyPut
  lazyPut(firestoreInstance);

  lazyPut(remoteDatabaseService);

  lazyPut(compoundDatabaseService);

  // lazyPut(remoteStorageService);
}

void setupMigrationDependencies() {
  final compoundFireStoreService = read<ICompoundDatabaseService<Map<String, dynamic>>>();

  final fireStoreService = read<IRemoteDatabaseService<Map<String, dynamic>>>();

  // Initialize repositories
  final billsRepository = createBillsRepository(compoundFireStoreService);

  final bondsRepository = createBondsRepository(compoundFireStoreService);

  final chequesRepository = createChequesRepository(compoundFireStoreService);

  final migrationRepository = createMigrationRepository(fireStoreService);

  // Register MigrationController
  put(MigrationController(bondsRepository, billsRepository, chequesRepository, migrationRepository));
}

// 🔹 Helper Methods for Initialization
IRemoteDatabaseService<Map<String, dynamic>> createRemoteDatabaseService(FirebaseFirestore instance) => FireStoreService(instance);

ICompoundDatabaseService<Map<String, dynamic>> createCompoundDatabaseService(FirebaseFirestore instance) =>
    CompoundFireStoreService(instance);

//IRemoteStorageService<String> createRemoteStorageService(FirebaseStorage instance) => FirebaseStorageService(instance);

CompoundDatasourceRepository<BillModel, BillTypeModel> createBillsRepository(ICompoundDatabaseService<Map<String, dynamic>> service) =>
    CompoundDatasourceRepository(BillCompoundDatasource(compoundDatabaseService: service));

CompoundDatasourceRepository<BondModel, BondType> createBondsRepository(ICompoundDatabaseService<Map<String, dynamic>> service) =>
    CompoundDatasourceRepository(BondCompoundDatasource(compoundDatabaseService: service));

CompoundDatasourceRepository<ChequesModel, ChequesType> createChequesRepository(ICompoundDatabaseService<Map<String, dynamic>> service) =>
    CompoundDatasourceRepository(ChequesCompoundDatasource(compoundDatabaseService: service));

RemoteDataSourceRepository<MigrationModel> createMigrationRepository(IRemoteDatabaseService<Map<String, dynamic>> service) =>
    RemoteDataSourceRepository(MigrationRemoteDatasource(databaseService: service));

// Future<void> initializeWindowSettings() async {
//   await windowManager.ensureInitialized();
//   WindowOptions windowOptions = const WindowOptions(
//     size: Size(1000, 800),
//     minimumSize: Size(1000, 800),
//     center: true,
//     backgroundColor: Colors.transparent,
//     skipTaskbar: false,
//     titleBarStyle: TitleBarStyle.normal,
//     windowButtonVisibility: true,
//   );
//
//   await windowManager.waitUntilReadyToShow(windowOptions, () async {
//     await windowManager.show();
//     await windowManager.focus();
//   });
// }