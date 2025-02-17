import 'package:ba3_bs_mobile/features/accounts/ui/screens/account_statement_screen.dart';
import 'package:ba3_bs_mobile/features/accounts/ui/screens/all_accounts_screen.dart';
import 'package:ba3_bs_mobile/features/bill/ui/screens/all_bills_screen.dart';
import 'package:ba3_bs_mobile/features/bill/ui/screens/pending_bills_screen.dart';
import 'package:ba3_bs_mobile/features/login/ui/screens/splash_screen.dart';
import 'package:ba3_bs_mobile/features/main_layout/ui/screens/main_layout.dart';
import 'package:ba3_bs_mobile/features/materials/ui/screens/add_material_screen.dart';
import 'package:ba3_bs_mobile/features/materials/ui/screens/all_materials_group_screen.dart';
import 'package:ba3_bs_mobile/features/materials/ui/screens/all_materials_screen.dart';
import 'package:ba3_bs_mobile/features/patterns/ui/screens/add_pattern_screen.dart';
import 'package:ba3_bs_mobile/features/patterns/ui/screens/pattern_layout.dart';
import 'package:ba3_bs_mobile/features/sellers/ui/screens/seller_sales_screen.dart';
import 'package:ba3_bs_mobile/features/sellers/ui/screens/seller_targets_screen.dart';
import 'package:ba3_bs_mobile/features/users_management/ui/screens/role_management/add_role_screen.dart';
import 'package:ba3_bs_mobile/features/users_management/ui/screens/user_management/add_user_screen.dart';
import 'package:ba3_bs_mobile/features/users_management/ui/screens/user_management/all_user_screen.dart';
import 'package:get/get.dart';

import '../../features/accounts/ui/screens/add_account_screen.dart';
import '../../features/bond/ui/screens/bond_details_screen.dart';
import '../../features/cheques/ui/screens/all_cheques_view.dart';
import '../../features/login/ui/screens/login_screen.dart';
import '../../features/patterns/ui/screens/all_pattern_screen.dart';
import '../../features/sellers/ui/screens/add_seller_screen.dart';
import '../../features/sellers/ui/screens/all_sellers_screen.dart';
import '../../features/user_time/ui/screens/user_details.dart';
import '../../features/users_management/ui/screens/role_management/all_roles_screen.dart';
import '../../features/users_management/ui/screens/user_time_list/user_time_list_screen.dart';
import 'app_routes.dart';

List<GetPage<dynamic>>? appRouter = [
  GetPage(name: AppRoutes.splashScreen, page: () => const SplashScreen()),
  GetPage(name: AppRoutes.mainLayout, page: () => const MainLayout()),
  GetPage(name: AppRoutes.loginScreen, page: () => const LoginScreen()),
  GetPage(name: AppRoutes.patternsScreen, page: () => const PatternLayout()),
  GetPage(name: AppRoutes.addPatternsScreen, page: () => const AddPatternScreen()),
  GetPage(name: AppRoutes.showAllPatternsScreen, page: () => const AllPatternScreen()),
  GetPage(name: AppRoutes.showAllMaterialsScreen, page: () => const AllMaterialsScreen()),
  GetPage(name: AppRoutes.showAllAccountsScreen, page: () => const AllAccountScreen()),
  GetPage(
    name: AppRoutes.showAllBillsScreen,
    page: () => const AllBillsScreen(),
  ),
  GetPage(
    name: AppRoutes.showPendingBillsScreen,
    page: () => const PendingBillsScreen(),
  ),

  // GetPage(name: AppRoutes.entryBondDetailsScreen, page: () => const EntryBondDetailsScreen()),

  GetPage(
    name: AppRoutes.bondDetailsScreen,
    page: () {
      final Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
      return BondDetailsScreen(
        fromBondById: arguments['fromBondById'],
        bondDetailsController: arguments['bondDetailsController'],
        bondDetailsPlutoController: arguments['bondDetailsPlutoController'],
        bondSearchController: arguments['bondSearchController'],
        tag: arguments['tag'],
      );
    },
  ),

  GetPage(
    name: AppRoutes.bondDetailsScreen,
    page: () {
      final Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
      return BondDetailsScreen(
        fromBondById: arguments['fromBondById'],
        bondDetailsController: arguments['bondDetailsController'],
        bondDetailsPlutoController: arguments['bondDetailsPlutoController'],
        bondSearchController: arguments['bondSearchController'],
        tag: arguments['tag'],
      );
    },
  ),
  GetPage(name: AppRoutes.accountStatementScreen, page: () => const AccountStatementScreen()),
  GetPage(
      name: AppRoutes.showAllChequesScreen,
      page: () {
        final bool arguments = Get.arguments as bool;
        return AllCheques(onlyDues: arguments);
      }),

  GetPage(
    name: AppRoutes.showAllUsersScreen,
    page: () => const AllUserScreen(),
  ),
  GetPage(
    name: AppRoutes.showAllPermissionsScreen,
    page: () => const AllRolesScreen(),
  ),
  GetPage(
    name: AppRoutes.addRoleScreen,
    page: () => const AddRoleScreen(),
  ),
  GetPage(
    name: AppRoutes.addUserScreen,
    page: () => const AddUserScreen(),
  ),
  GetPage(
    name: AppRoutes.addSellerScreen,
    page: () => const AddSellerScreen(),
  ),
  GetPage(
    name: AppRoutes.allSellersScreen,
    page: () => const AllSellersScreen(),
  ),
  GetPage(
    name: AppRoutes.sellerSalesScreen,
    page: () => const SellerSalesScreen(),
  ),

  GetPage(
    name: AppRoutes.sellerTargetScreen,
    page: () => const SellerTargetScreen(),
  ),
  GetPage(
    name: AppRoutes.addMaterialScreen,
    page: () => const AddMaterialScreen(),
  ),

  GetPage(
    name: AppRoutes.addAccountScreen,
    page: () => const AddAccountScreen(),
  ),
  GetPage(
    name: AppRoutes.showAllMaterialsGroupScreen,
    page: () => const AllMaterialsGroupScreen(),
  ),
  GetPage(
    name: AppRoutes.showUserTimeListScreen,
    page: () => const UserTimeListScreen(),
  ),
  GetPage(
    name: AppRoutes.showUserDetails,
    page: () => const UserDetails(),
  ),
];