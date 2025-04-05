import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs_mobile/features/sellers/ui/screens/all_sellers_screen.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../../core/dialogs/seller_selection_dialog_content.dart';
import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import '../../../core/services/json_file_operations/implementations/import/import_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../floating_window/services/overlay_service.dart';
import '../data/models/seller_model.dart';

class SellersController extends GetxController with AppNavigator, FloatingLauncher {
  final BulkSavableDatasourceRepository<SellerModel> _sellersFirebaseRepo;

  final ImportRepository<SellerModel> _sellersImportRepo;

  SellersController(this._sellersFirebaseRepo, this._sellersImportRepo);

  RxList<SellerModel> sellers = <SellerModel>[].obs;

  SellerModel? selectedSellerAccount;
  final logger = Logger();

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
        sellers.assignAll(fetchedSellers);
      },
    );
  }

  Future<void> fetchAllSellersFromLocal() async {
    FilePickerResult? resultFile = await FilePicker.platform.pickFiles();

    if (resultFile != null) {
      File file = File(resultFile.files.single.path!);
      final result = await _sellersImportRepo.importXmlFile(file);

      result.fold(
        (failure) {
          logger.e("Error log", error: failure.message);
          AppUIUtils.onFailure(failure.message);
        },
        (fetchedSellers) => _handelFetchAllSellersFromLocalSuccess(fetchedSellers),
      );
    }
  }

  void _handelFetchAllSellersFromLocalSuccess(List<SellerModel> fetchedSellers) async {
    log("fetchedSellers length ${fetchedSellers.length}");
    log('current sellers length is ${sellers.length}');

    final newSellers = fetchedSellers.subtract(sellers, (seller) => seller.costName);
    log('newSellers length is ${newSellers.length}');

    if (newSellers.isNotEmpty) {
      final result = await _sellersFirebaseRepo.saveAll(newSellers);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedSellers) {
          AppUIUtils.onSuccess('تم اضافة  ${newSellers.length}');

          sellers.addAll(newSellers);
        },
      );
    }
  }

  Future<void> addSellers() async {
    final result = await _sellersFirebaseRepo.saveAll(sellers);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (addedSellers) => AppUIUtils.onSuccess('Add ${addedSellers.length} sellers'),
    );
  }

  Future<void> deleteSeller(String sellerId) async {
    final result = await _sellersFirebaseRepo.delete(sellerId);

    result.fold(
      (failure) => AppUIUtils.onFailure('فشل في حذف البائع: ${failure.message}'),
      (success) {
        AppUIUtils.onSuccess('تم الحذف البائع بنجاح!');
        sellers.removeWhere((seller) => seller.costGuid == sellerId);
      },
    );
  }

  // Navigation to the screen displaying all sellers
  void navigateToAllSellersScreen(BuildContext context) {
    launchFloatingWindow(context: context, floatingScreen: AllSellersScreen());
    // to(AppRoutes.showAllSellersScreen);
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
    return sellers.firstWhereOrNull((seller) => seller.costGuid == id)?.costName ?? '';
  }

  // Get seller ID by name
  String getSellerIdByName(String? name) {
    if (name == null || name.isEmpty) return '';
    return sellers.firstWhereOrNull((seller) => seller.costName == name)?.costGuid ?? '';
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

  fetchLoginSellers() async {
    UserModel userModel = read<UserManagementController>().loggedInUserModel!;
    final result = await _sellersFirebaseRepo.getById(userModel.userSellerId!);
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedSeller) => sellers.assignAll([fetchedSeller]),
    );
  }

  Future<SellerModel?> openSellerSelectionDialog({
    required String query,
    required BuildContext context,
  }) async {
    selectedSellerAccount = null;
    List<SellerModel> searchedSellersAccounts = getSellersAccounts(query);
    if (searchedSellersAccounts.length == 1) {
      // Single match
      selectedSellerAccount = searchedSellersAccounts.first;
    } else if (searchedSellersAccounts.isNotEmpty) {
      await OverlayService.showDialog(
        context: context,
        title: 'أختر البائع',
        content: SellerSelectionDialogContent(
          sellers: searchedSellersAccounts,
          onSellerTap: (selectedSeller) {
            OverlayService.back();

            selectedSellerAccount = selectedSeller;
          },
        ),
        onCloseCallback: () {
          log('Seller Selection Dialog Closed.');
        },
      );
    } else {
      AppUIUtils.showErrorSnackBar(title: 'فحص الحسابات', message: 'هذا الحساب غير موجود');
    }
    return selectedSellerAccount;
  }
}