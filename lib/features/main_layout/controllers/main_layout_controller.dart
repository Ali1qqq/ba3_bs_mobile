import 'package:ba3_bs_mobile/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_assets.dart';
import '../../accounts/ui/screens/account_layout.dart';
import '../../bill/ui/screens/bill_layout.dart';
import '../../bond/ui/screens/bond_layout.dart';
import '../../cheques/ui/screens/cheque_layout.dart';
import '../../dashboard/ui/screens/dash_board_layout.dart';
import '../../materials/ui/screens/materials_layout.dart';
import '../../patterns/ui/screens/pattern_layout.dart';
import '../../profile/ui/screens/profile_screen.dart';
import '../../sellers/ui/screens/sellers_layout.dart';
import '../../user_time/ui/screens/all_attendance_screen.dart';
import '../../users_management/ui/screens/user_management_layout.dart';
import '../data/model/app_layout_item_model.dart';

class MainLayoutController extends GetxController {
  final RxBool isDrawerOpen = false.obs;

  void openDrawer() => isDrawerOpen.value = true;

  void closeDrawer() => isDrawerOpen.value = false;

  RxList<AppLayoutItemModel> appLayouts = [
    if (RoleItemType.administrator.hasReadPermission)
      AppLayoutItemModel(
        name: 'لوحة التحكم',
        layout: const DashBoardLayout(),
        icon: AppAssets.dashBoardIcon,
        unSelectedIcon: AppAssets.dashBoardUnselectedIcon,
      ),
    if (RoleItemType.viewBill.hasReadPermission)
      AppLayoutItemModel(
        name: 'الفواتير',
        layout: const BillLayout(),
        icon: AppAssets.billsIcon,
        unSelectedIcon: AppAssets.billsUnselectedIcon,
      ),
    if (RoleItemType.viewPattern.hasReadPermission)
      AppLayoutItemModel(
        name: 'الأنماط',
        layout: const PatternLayout(),
        icon: AppAssets.patternsIcon,
        unSelectedIcon: AppAssets.patternsUnselectedIcon,
      ),
    if (RoleItemType.viewProduct.hasAdminPermission)
      AppLayoutItemModel(
        name: 'المواد',
        layout: const MaterialLayout(),
        icon: AppAssets.materialIcon,
        unSelectedIcon: AppAssets.materialUnselectedIcon,
      ),
    if (RoleItemType.viewAccount.hasReadPermission)
      AppLayoutItemModel(
        name: 'الحسابات',
        layout: const AccountLayout(),
        icon: AppAssets.accountsIcon,
        unSelectedIcon: AppAssets.accountsUnselectedIcon,
      ),
    if (RoleItemType.viewBond.hasReadPermission)
      AppLayoutItemModel(
        name: 'السندات',
        layout: const BondLayout(),
        icon: AppAssets.bondsIcon,
        unSelectedIcon: AppAssets.bondsUnselectedIcon,
      ),
    if (RoleItemType.viewCheques.hasReadPermission)
      AppLayoutItemModel(
        name: 'الشيكات',
        layout: const ChequeLayout(),
        icon: AppAssets.chequesIcon,
        unSelectedIcon: AppAssets.chequesUnselectedIcon,
      ),
    if (RoleItemType.viewSellers.hasAdminPermission)
      AppLayoutItemModel(
        name: 'البائعون',
        layout: const SellersLayout(),
        icon: AppAssets.accountsIcon,
        unSelectedIcon: AppAssets.accountsUnselectedIcon,
      ),
    if (RoleItemType.viewUserManagement.hasAdminPermission)
      AppLayoutItemModel(
        name: 'إدارة المستخدمين',
        layout: const UserManagementLayout(),
        icon: AppAssets.usersIcon,
        unSelectedIcon: AppAssets.usersUnselectedIcon,
      ),
    if (RoleItemType.administrator.hasReadPermission)
      AppLayoutItemModel(
        name: 'لوحة التحكم',
        layout: const AllAttendanceScreen(),
        icon: AppAssets.billsIcon,
        unSelectedIcon: AppAssets.billsUnselectedIcon,
      ),
    AppLayoutItemModel(
      name: 'الملف الشخصي',
      layout: const ProfileScreen(),
      icon: AppAssets.profileIcon,
      unSelectedIcon: AppAssets.profileUnselectedIcon,
    ),
  ].obs;

  PageController pageController = PageController();

  int tabIndex = 0;

  set setIndex(int index) {
    tabIndex = index;
    update();
  }
}