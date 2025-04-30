import '../../features/migration/controllers/migration_controller.dart';
import '../constants/app_constants.dart';
import '../helper/extensions/getx_controller_extensions.dart';

class ApiConstants {
  static const String translationApiKey =
      'AIzaSyAil4Csq27_oCC_BzF7ZMetUEyNM665VqQ';
  static const String translationBaseUrl =
      'https://translation.googleapis.com/language/translate/v2';

  // static const String whatsappPhoneNumberID = '578828715319909';

  // static const String whatsappBusinessAccountId = '636525489008457';

  // Test number: +1 555 175 7120
  static const String whatsappPhoneNumberID = '586121637924133';

  static const String whatsappBusinessAccountId = '626521303518096';

  static String get year {
    final MigrationController migrationController = read<MigrationController>();

    final currentVersion = migrationController.currentVersion;

    return currentVersion == AppConstants.defaultVersion ||
            currentVersion.isEmpty
        ? ''
        : '${migrationController.currentVersion}_';
  }

  /// COLLECTIONS
  static String get bills => '${year}bills';

  static String get bonds => '${year}bonds';

  static String get cheques => '${year}cheques';

  static String get entryBonds => '${year}entry_bonds';

  static String get accountsStatements => '${year}accounts_statements';

  static String get accounts => '${year}accounts';

  static String get materials => '${year}materials';

  static String get customers => '${year}customers';

  static const String patterns = 'bill_types';
  static const String roles = 'roles';
  static const String users = 'users';
  static const String sellers = 'sellers';
  static const String taxes = 'texes';
  static const String migration = 'migration';
  static const String dashBoardAccounts = 'dashBoardAccounts';
  static const String materialsSerialNumbers = 'materials_serial_numbers';
  static const String materialGroup = 'materialGroup';
  static const String changes = 'changes';
  static const String sequentialNumbers = 'sequential_numbers';
  static const String guestUser = 'guest_user';
  static const String storeCart = 'StoreCart';
  static const String materialsStatements = 'materials_statements';
  static const String largeBills = 'large_bills';
  static const String logs = 'logs';

  /// **Documents**
  static const String guest = 'guest';

  /// **FIELDS**
  static const String status = 'status';
  static const String userPassword = 'userPassword';
  static const String billDate = 'billDetails.billDate';
  static const String billSellerId = 'billDetails.billSellerId';
  static const String type = 'type';
  static const String lastNumber = 'lastNumber';
  static const String billNumber = 'billDetails.billNumber';
  static const String orderNumber = 'billDetails.orderNumber';
  static const String customerPhone = 'billDetails.customerPhone';
  static const String bondNumber = 'PayNumber';
  static const String metaValue = 'metaValue';

  static String userTask = 'user_task';
}
