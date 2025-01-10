import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/utils/generate_id.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/material_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  }) {
    final MaterialModel newMaterialModel;

    if (materialModel == null) {
      newMaterialModel = MaterialModel(
        id: generateId(RecordType.product),
        matName: matName,
        matCompositionLatinName: matCompositionLatinName,
        matBarCode: matBarCode,
        wholesalePrice: wholesalePrice,
        endUserPrice: endUserPrice,
        retailPrice: retailPrice,
        matCode: matCode,
        matGroupGuid: matGroupGuid,
        matVatGuid: matVatGuid,
        matPrevQty: "0",
        matLastPriceCurVal: 0.0,
        matCreateDate: Timestamp.now().toDate(),
        matExtraBarcode: [],
        matPictureGuid: '',
      );
    } else {
      newMaterialModel = materialModel.copyWith(
        matName: matName,
        matBarCode: matBarCode,
        wholesalePrice: wholesalePrice,
        endUserPrice: endUserPrice,
        retailPrice: retailPrice,
        matCode: matCode,
        matGroupGuid: matGroupGuid,
        matVatGuid: matVatGuid,
      );
    }
    return newMaterialModel;
  }
}
