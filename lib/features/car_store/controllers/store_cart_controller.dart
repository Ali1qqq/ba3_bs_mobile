import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/store_cart_converter.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/listen_datasource_repo.dart';
import 'package:ba3_bs_mobile/core/utils/app_ui_utils.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_details.dart';
import 'package:ba3_bs_mobile/features/car_store/data/model/store_cart.dart';
import 'package:ba3_bs_mobile/features/patterns/controllers/pattern_controller.dart';
import 'package:get/get.dart';

import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../bill/data/models/bill_model.dart';
import '../../patterns/data/models/bill_type_model.dart';

class StoreCartController extends GetxController {
  final ListenDataSourceRepository<StoreCartModel> _dataSourceRepository;
  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;

  List<StoreCartModel> storeCartModels = [];
  List<BillModel> bills = [];

  StoreCartController(this._dataSourceRepository, this._billsFirebaseRepo);

  void fetchAllStoreCart() async {
    final result = await _dataSourceRepository.getAll();
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedStoreCard) => onStoreCartFetched(fetchedStoreCard),
    );
  }

  void onStoreCartFetched(List<StoreCartModel> fetchedStoreCard) {
    storeCartModels.assignAll(fetchedStoreCard);

    convertStoreCartToBills(storeCartModels);
  }

  void convertStoreCartToBills(List<StoreCartModel> storeCartModels) {
    for (var element in storeCartModels) {
      final double billTotal = element.storeProducts!.storeProduct.fold(
        0,
        (previousValue, element) => previousValue + (element.price! * element.amount!),
      );

      saveBillFromStoreCardAndHandleResult(
        BillModel(
          freeBill: false,
          billTypeModel: read<PatternController>().billsTypeSales,
          items: element.storeProducts!.toBillItems(),
          billDetails: BillDetails(
            billAdditionsTotal: 0,
            billBeforeVatTotal: 0,
            billDate: DateTime.now(),
            billDiscountsTotal: 0,
            billFirstPay: 0,
            billCustomerId: AppConstants.primaryCashAccountId,
            billGiftsTotal: 0,
            billPayType: 0,
            billTotal: billTotal,
            billVatTotal: billTotal * 0.05,
            billNote: '',
          ),
          status: Status.pending,
        ),
      );
    }
    deleteAllStoreCart();
  }

  void deleteAllStoreCart() async {
    for (var storeCard in storeCartModels) {
      final result = await _dataSourceRepository.delete(storeCard.id!);
      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (_) {},
      );
    }
  }

  Future<void> saveBillFromStoreCardAndHandleResult(BillModel billModel) async {
    final result = await _billsFirebaseRepo.save(billModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) {},
    );
  }
}