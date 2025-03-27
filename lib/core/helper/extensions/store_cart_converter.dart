import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_model.dart';

import '../../../features/bill/data/models/bill_items.dart';
import '../../../features/car_store/data/model/store_product.dart';

extension StoreProductConversion on StoreProduct {
  BillItem toBillItem() {
    MaterialModel? materialModel = read<MaterialController>().searchOfProductByText(barcode ?? 'xxxxx').lastOrNull;
    if (materialModel != null && barcode != '0' && barcode != '00') {
      return BillItem(
        itemGuid: materialModel.id!,
        itemName: materialModel.matName,
        itemQuantity: amount!,
        itemTotalPrice: (price! * amount!).toString(),
        itemSubTotalPrice: (price!) / 1.05,
        itemVatPrice: ((price!) / 1.05) * 0.05,
        itemGiftsNumber: 0,
        itemGiftsPrice: 0,
        soldSerialNumber: null,
        itemSerialNumbers: null,
      );
    }
    return BillItem(
      itemGuid: "الباركود خطأ",
      itemName: "الباركود خطأ",
      itemQuantity: amount!,
      itemTotalPrice: (price! * amount!).toString(),
      itemSubTotalPrice: (price!) / 1.05,
      itemVatPrice: ((price!) / 1.05) * 0.05,
      itemGiftsNumber: 0,
      itemGiftsPrice: 0,
      soldSerialNumber: null,
      itemSerialNumbers: null,
    );
  }
}

extension StoreProductsConversion on StoreProducts {
  BillItems toBillItems() {
    return BillItems(
      itemList: storeProduct.map((e) => e.toBillItem()).toList(),
    );
  }
}