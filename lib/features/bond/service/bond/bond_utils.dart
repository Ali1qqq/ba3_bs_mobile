import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';

import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../sellers/data/models/seller_model.dart';
import '../../data/models/bond_model.dart';

class BondUtils {
  BondModel appendEmptyBondModel(List<BondModel> bonds, BondType bondTyp) {
    final int lastBondNumber = bonds.isNotEmpty ? bonds.last.payNumber! : 0;

    final emptyBondModel = BondModel.empty(
      bondType: bondTyp,
      lastBondNumber: lastBondNumber,
    );

    bonds.add(emptyBondModel);
    return emptyBondModel;
  }

  List<BondModel> appendEmptyBillModelNew(BondType bondType, int lastBondNumber) {
    final List<BondModel> bonds = [];
    final emptyBillModel = BondModel.empty(bondType: bondType, lastBondNumber: lastBondNumber);

    bonds.add(emptyBillModel);
    return bonds;
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
