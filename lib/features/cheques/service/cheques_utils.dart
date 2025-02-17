import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../accounts/data/models/account_model.dart';
import '../../sellers/data/models/seller_model.dart';
import '../data/models/cheques_model.dart';

class ChequesUtils {
  ChequesModel appendEmptyChequesModel(List<ChequesModel> cheques, ChequesType bondTyp) {
    final int lastBillNumber = cheques.isNotEmpty ? cheques.last.chequesNumber! : 0;

    final emptyBillModel = ChequesModel.empty(
      chequesType: bondTyp,
      lastChequesNumber: lastBillNumber,
    );

    cheques.add(emptyBillModel);
    return emptyBillModel;
  }

  bool validateCustomerAccount(AccountModel? customerAccount) {
    if (customerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل!');
      return false;
    }
    return true;
  }

  bool validateSellerAccount(SellerModel? sellerAccount) {
    if (sellerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم البائع!');
      return false;
    }
    return true;
  }
}