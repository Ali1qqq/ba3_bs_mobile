import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../sellers/data/models/seller_model.dart';
import '../../data/models/bond_model.dart';

class BondUtils {
  BondModel appendEmptyBondModel(List<BondModel> bonds, BondType bondTyp) {
    final int lastBillNumber = bonds.isNotEmpty ? bonds.last.payNumber! : 0;

    final emptyBillModel = BondModel.empty(
      bondType: bondTyp,
      lastBondNumber: lastBillNumber,
    );

    bonds.add(emptyBillModel);
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
