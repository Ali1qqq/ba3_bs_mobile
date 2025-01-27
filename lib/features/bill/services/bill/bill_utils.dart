import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../../sellers/data/models/seller_model.dart';
import '../../data/models/bill_model.dart';

class BillUtils {
  BillModel appendEmptyBillModel(List<BillModel> bills, BillTypeModel billTypeModel) {
    final int lastBillNumber = bills.isNotEmpty ? bills.last.billDetails.billNumber! : 0;

    final emptyBillModel = BillModel.empty(billTypeModel: billTypeModel, lastBillNumber: lastBillNumber);

    bills.add(emptyBillModel);
    return emptyBillModel;
  }

  List<BillModel> appendEmptyBillModelNew(BillTypeModel billTypeModel, int lastBillNumber) {
    final List<BillModel> bills = [];
    final emptyBillModel = BillModel.empty(billTypeModel: billTypeModel, lastBillNumber: lastBillNumber);

    bills.add(emptyBillModel);
    return bills;
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
