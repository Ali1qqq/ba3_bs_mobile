import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/utils/utils.dart';

class MaterialService {
  MaterialModel? createMaterialModel({
    MaterialModel? materialModel,
    required String matName,
    String? matCompositionLatinName,
    required String matBarCode,
    required String wholesalePrice,
    required String endUserPrice,
    required String retailPrice,
    required int matCode,
    required String matGroupGuid,
    required String matVatGuid,
    double? matCurrencyVal,
  }) {
    if (materialModel == null) {
      return MaterialModel(
        id: generateId(RecordType.material),
        matName: matName,
        matCompositionLatinName: matCompositionLatinName,
        matBarCode: matBarCode,
        wholesalePrice: wholesalePrice,
        endUserPrice: endUserPrice,
        retailPrice: retailPrice,
        matCode: matCode,
        matGroupGuid: matGroupGuid,
        matVatGuid: matVatGuid,
        matCurrencyVal: matCurrencyVal,
        matPrevQty: "0",
        matLastPriceCurVal: 0.0,
        matCreateDate: Timestamp.now().toDate(),
        matExtraBarcode: [],
        matPictureGuid: '',
      );
    } else {
      return materialModel.copyWith(
        matName: matName,
        matBarCode: matBarCode,
        wholesalePrice: wholesalePrice,
        endUserPrice: endUserPrice,
        retailPrice: retailPrice,
        matCode: matCode,
        matGroupGuid: matGroupGuid,
        matVatGuid: matVatGuid,
        matCurrencyVal: matCurrencyVal,
      );
    }
  }
}