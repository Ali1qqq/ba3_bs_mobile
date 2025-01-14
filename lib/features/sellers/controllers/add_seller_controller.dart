import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../data/models/seller_model.dart';

class AddSellerController extends GetxController with AppNavigator {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  SellerModel? selectedSellerModel;

  init(SellerModel? sellerModel) {
    if (sellerModel != null) {
      sellerModel = sellerModel;

      nameController.text = sellerModel.costName ?? '';
      codeController.text = sellerModel.costCode?.toString() ?? '';
    } else {
      selectedSellerModel = null;

      codeController.text = '';
      nameController.text = '';
    }
  }

  Future<void> saveOrUpdateSeller() async {}
}
