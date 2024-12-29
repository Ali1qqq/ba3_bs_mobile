import 'dart:developer';

import 'package:ba3_bs_mobile/core/router/app_routes.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/dialogs/seller_selection_dialog_content.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../floating_window/services/overlay_service.dart';
import '../../users_management/controllers/user_management_controller.dart';
import '../data/models/seller_model.dart';
import '../data/repositories/sellers_repository.dart';

class SellerController extends GetxController {
  final SellersRepository _sellersRepository;

  SellerController(this._sellersRepository);

  List<SellerModel> sellers = [];
  bool isLoading = true;

  SellerModel? selectedSellerAccount;

  @override
  void onInit() {
    super.onInit();
    fetchSellers();
  }

  // Fetch sellers from the repository
  void fetchSellers() {
    try {
      sellers = _sellersRepository.getAllSellers();
    } catch (e) {
      debugPrint('Error in fetchSellers: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Navigation to the screen displaying all sellers
  void navigateToAllSellersScreen() {
    Get.toNamed(AppRoutes.showAllSellersScreen);
  }

  // Search for sellers by text query

  List<SellerModel> searchSellersByNameOrCode(text) {
    if (sellers.isEmpty) {
      log('Accounts isEmpty');
      fetchSellers();
    }
    return sellers
        .where((item) =>
            item.costName!.toLowerCase().contains(text.toLowerCase()) || item.costCode.toString().contains(text))
        .toList();
  }

  List<String> getSellersNames(String query) {
    return searchSellersByNameOrCode(query).map((seller) => seller.costName!).toList();
  }

  List<SellerModel> getSellersAccounts(String query) => searchSellersByNameOrCode(query);

  // Get seller name by ID
  String getSellerNameById(String? id) {
    if (id == null || id.isEmpty) return '';
    return sellers.firstWhere((seller) => seller.costGuid == id).costName ?? '';
  }

  // Get seller  by ID
  SellerModel getSellerById(String id) {
    return sellers.firstWhere((seller) => seller.costGuid == id);
  }

  // Replace Arabic numerals with English numerals
  String replaceArabicNumbersWithEnglish(String input) {
    return input.replaceAllMapped(RegExp(r'[٠-٩]'), (Match match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0x0660 + 0x0030);
    });
  }

  updateSellerAccount(SellerModel? newAccount) {
    if (newAccount != null) {
      selectedSellerAccount = newAccount;
    }
  }

  void initSellerAccount({
    required String? sellerId,
    required BillDetailsController billDetailsController,
  }) {
    final String? billSellerId = sellerId ?? read<UserManagementController>().loggedInUserModel?.userSellerId;

    if (billSellerId == null) {
      selectedSellerAccount = null;

      billDetailsController.sellerAccountController.text = '';
    } else {
      final SellerModel sellerAccount = getSellerById(billSellerId);

      updateSellerAccount(sellerAccount);

      billDetailsController.sellerAccountController.text = sellerAccount.costName!;
    }
  }

  void openSellerSelectionDialog({
    required String query,
    required TextEditingController textEditingController,
    required BuildContext context,
  }) {
    List<SellerModel> searchedSellersAccounts = getSellersAccounts(query);
    if (searchedSellersAccounts.length == 1) {
      // Single match
      selectedSellerAccount = searchedSellersAccounts.first;

      textEditingController.text = selectedSellerAccount!.costName!;
    } else if (searchedSellersAccounts.isNotEmpty) {
      OverlayService.showDialog(
        context: context,
        title: 'أختر البائع',
        content: SellerSelectionDialogContent(
          sellers: searchedSellersAccounts,
          onSellerTap: (selectedSeller) {
            OverlayService.back();

            selectedSellerAccount = selectedSeller;
            textEditingController.text = selectedSeller.costName!;
          },
        ),
        onCloseCallback: () {
          log('Seller Selection Dialog Closed.');
        },
      );
    } else {
      AppUIUtils.showErrorSnackBar(title: 'فحص الحسابات', message: 'هذا الحساب غير موجود');
    }
  }
}
