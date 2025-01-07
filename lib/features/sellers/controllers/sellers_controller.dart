import 'dart:developer';

import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/router/app_routes.dart';
import 'package:ba3_bs_mobile/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/dialogs/seller_selection_dialog_content.dart';
import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../floating_window/services/overlay_service.dart';
import '../data/models/seller_model.dart';

class SellersController extends GetxController with AppNavigator {
  final BulkSavableDatasourceRepository<SellerModel> _sellersFirebaseRepo;

  SellersController(this._sellersFirebaseRepo);

  List<SellerModel> sellers = [];
  bool isLoading = true;

  SellerModel? selectedSellerAccount;

  @override
  void onInit() {
    super.onInit();
    getAllSellers();
  }

  // Fetch sellers from the repository
  Future<void> getAllSellers() async {
    final result = await _sellersFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedSellers) {
        sellers = fetchedSellers;
        isLoading = false;
        update();
      },
    );
    // try {
    //   sellers = _sellersRepository.getAllSellers();
    // } catch (e) {
    //   debugPrint('Error in fetchSellers: $e');
    // } finally {
    //   isLoading = false;
    //   update();
    // }
  }

  Future<void> addSeller(SellerModel seller) async {
    final result = await _sellersFirebaseRepo.save(seller);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedSellers) {},
    );
  }

  Future<void> addSellers() async {
    final result = await _sellersFirebaseRepo.saveAll(sellers);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (addedSellers) => AppUIUtils.onSuccess('Add ${addedSellers.length} sellers'),
    );
  }

  // Navigation to the screen displaying all sellers
  void navigateToAllSellersScreen() {
    to(AppRoutes.showAllSellersScreen);
  }

  // Search for sellers by text query

  List<SellerModel> searchSellersByNameOrCode(text) => sellers
      .where((item) => item.costName!.toLowerCase().contains(text.toLowerCase()) || item.costCode.toString().contains(text))
      .toList();

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
    return sellers.firstWhereOrNull((seller) => seller.costGuid == id) ?? SellerModel(costName: '');
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
