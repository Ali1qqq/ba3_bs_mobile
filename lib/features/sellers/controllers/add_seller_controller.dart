import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/services/firebase/implementations/repos/bulk_savable_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../data/models/seller_model.dart';

class AddSellerController extends GetxController with AppNavigator {
  final BulkSavableDatasourceRepository<SellerModel> _sellersFirebaseRepo;

  AddSellerController(this._sellersFirebaseRepo);

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  SellerModel? selectedSellerModel;

  init(SellerModel? sellerModel) {
    if (sellerModel != null) {
      selectedSellerModel = sellerModel;

      nameController.text = sellerModel.costName ?? '';
      codeController.text = sellerModel.costCode?.toString() ?? '';
    } else {
      selectedSellerModel = null;

      codeController.text = '';
      nameController.text = '';
    }
  }

  Future<void> saveOrUpdateSeller() async {
    // Get values from controllers
    final name = nameController.text.trim();
    final code = int.tryParse(codeController.text.trim());

    if (name.isEmpty || code == null) {
      AppUIUtils.onFailure("يرجى إدخال اسم ورمز صالحين.");
      return;
    }

    if (selectedSellerModel == null) {
      // Creating a new seller
      final newSeller = SellerModel(
        costName: name,
        costCode: code,
      );
      await addSeller(newSeller, isNew: true);
    } else {
      // Updating existing seller
      final updatedSeller = selectedSellerModel!.copyWith(
        costName: name,
        costCode: code,
      );
      await addSeller(updatedSeller, isNew: false);
    }
  }

  Future<void> addSeller(SellerModel seller, {required bool isNew}) async {
    final result = await _sellersFirebaseRepo.save(seller);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedSeller) => onSuccess(savedSeller, isNew: isNew),
    );
  }

  void onSuccess(SellerModel savedSeller, {required bool isNew}) {
    final sellersController = Get.find<SellersController>(); // Ensure Get.find is used correctly

    AppUIUtils.onSuccess('تم حفظ البائع بنجاح!');

    if (isNew) {
      sellersController.sellers.add(savedSeller);
    } else {
      final index = sellersController.sellers.indexWhere(
        (seller) => savedSeller.costGuid == seller.costGuid,
      );

      if (index != -1) {
        sellersController.sellers[index] = savedSeller;
      }
    }
  }
}