import 'package:ba3_bs_mobile/features/bill/data/models/bill_items.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bill/data/models/discount_addition_account_model.dart';
import '../../../bond/data/models/entry_bond_model.dart';

mixin BillBondService {
  EntryBondModel createEntryBondModel({
    required EntryBondType originType,
    required BillModel billModel,
    required Map<Account, List<DiscountAdditionAccountModel>> discountsAndAdditions,
  }) {
    return EntryBondModel(
      origin: EntryBondOrigin(
        originId: billModel.billId,
        originType: originType,
        originTypeId: billModel.billTypeModel.billTypeId,
      ),
      items: generateBondItems(billModel: billModel, discountsAndAdditions: discountsAndAdditions),
    );
  }

  List<EntryBondItemModel> generateBondItems({
    required BillModel billModel,
    required Map<Account, List<DiscountAdditionAccountModel>> discountsAndAdditions,
  }) {
    final customerAccount = billModel.billTypeModel.accounts![BillAccounts.caches]!;

    final billType = BillType.byLabel(billModel.billTypeModel.billTypeLabel!);
    final isSales = billType == BillType.sales;

    final date = billModel.billDetails.billDate!;

    final itemBonds = _generateBillItemBonds(
      billId: billModel.billId!,
      accounts: billModel.billTypeModel.accounts!,
      customerAccount: customerAccount,
      billItems: billModel.items.itemList,
      date: date,
      isSales: isSales,
    );

    final adjustmentBonds = _generateAdjustmentBonds(
      discountsAndAdditions: discountsAndAdditions,
      billId: billModel.billId!,
      customerAccount: customerAccount,
      date: date,
      isSales: isSales,
    );

    return [...itemBonds, ...adjustmentBonds];
  }

  List<EntryBondItemModel> _generateBillItemBonds({
    required String billId,
    required Map<Account, AccountModel> accounts,
    required AccountModel customerAccount,
    required List<BillItem> billItems,
    required String date,
    required bool isSales,
  }) {
    return billItems.expand((item) {
      return [
        if (accounts.containsKey(BillAccounts.materials))
          _createMaterialBond(
            billId: billId,
            materialAccount: accounts[BillAccounts.materials]!,
            total: item.itemSubTotalPrice! * item.itemQuantity,
            quantity: item.itemQuantity,
            name: item.itemName,
            date: date,
            isSales: isSales,
          ),
        ..._generateCustomerBonds(
          billId: billId,
          customerAccount: customerAccount,
          item: item,
          date: date,
          isSales: isSales,
        ),
        ..._createOptionalBonds(
          billId: billId,
          accounts: accounts,
          item: item,
          date: date,
          isSales: isSales,
        ),
      ];
    }).toList();
  }

  List<EntryBondItemModel> _createOptionalBonds({
    required String billId,
    required Map<Account, AccountModel> accounts,
    required BillItem item,
    required String date,
    required bool isSales,
  }) {
    final giftCount = item.itemGiftsNumber;
    final giftPrice = item.itemGiftsPrice;
    final vat = item.itemVatPrice! * item.itemQuantity;

    return [
      if (vat > 0)
        _createVatBond(
          billId: billId,
          vat: vat,
          name: item.itemName,
          quantity: item.itemQuantity,
          date: date,
          isSales: isSales,
        ),
      if (_shouldHandleGifts(accounts, giftCount, giftPrice))
        ..._createGiftBonds(
          billId: billId,
          accounts: accounts,
          giftCount: giftCount!,
          giftPrice: giftPrice!,
          name: item.itemName,
          date: date,
          isSales: isSales,
        ),
    ];
  }

  EntryBondItemModel _createMaterialBond({
    required String billId,
    required AccountModel materialAccount,
    required double total,
    required int quantity,
    required String name,
    required String date,
    required bool isSales,
  }) {
    return _createBondItem(
      amount: total,
      billId: billId,
      bondType: isSales ? BondItemType.creditor : BondItemType.debtor,
      accountName: materialAccount.accName,
      accountId: materialAccount.id,
      note: '${getNote(isSales)} عدد $quantity من $name',
      date: date,
    );
  }

  List<EntryBondItemModel> _generateCustomerBonds({
    required String billId,
    required AccountModel customerAccount,
    required BillItem item,
    required String date,
    required bool isSales,
  }) {
    final vat = item.itemVatPrice! * item.itemQuantity;
    final total = item.itemSubTotalPrice! * item.itemQuantity;

    return [
      _createBondItem(
        amount: total,
        billId: billId,
        bondType: isSales ? BondItemType.debtor : BondItemType.creditor,
        accountName: customerAccount.accName,
        accountId: customerAccount.id,
        note: '${getNote(isSales)} عدد ${item.itemQuantity} من ${item.itemName}',
        date: date,
      ),
      _createBondItem(
        amount: vat,
        billId: billId,
        bondType: isSales ? BondItemType.debtor : BondItemType.creditor,
        accountName: customerAccount.accName,
        accountId: customerAccount.id,
        note: 'ضريبة ${getNote(isSales)} عدد ${item.itemQuantity} من ${item.itemName}',
        date: date,
      ),
    ];
  }

  EntryBondItemModel _createVatBond({
    required String billId,
    required double vat,
    required String name,
    required int quantity,
    required String date,
    required bool isSales,
  }) {
    return _createBondItem(
      amount: vat,
      billId: billId,
      bondType: isSales ? BondItemType.creditor : BondItemType.debtor,
      accountName: 'ضريبة القيمة المضافة',
      accountId: 'a5c04527-63e8-4373-92e8-68d8f88bdb16',
      note: 'ضريبة ${getNote(isSales)} عدد $quantity من $name',
      date: date,
    );
  }

  bool _shouldHandleGifts(Map<Account, AccountModel> accounts, int? giftCount, double? giftPrice) {
    return giftCount != null &&
        giftCount > 0 &&
        giftPrice != null &&
        giftPrice > 0 &&
        accounts.containsKey(BillAccounts.gifts) &&
        accounts.containsKey(BillAccounts.exchangeForGifts);
  }

  List<EntryBondItemModel> _createGiftBonds({
    required String billId,
    required Map<Account, AccountModel> accounts,
    required int giftCount,
    required double giftPrice,
    required String name,
    required String date,
    required bool isSales,
  }) {
    final totalGifts = giftPrice * giftCount;
    final giftAccount = accounts[BillAccounts.gifts]!;
    final settlementAccount = accounts[BillAccounts.exchangeForGifts]!;

    return [
      _createBondItem(
        amount: totalGifts,
        billId: billId,
        bondType: isSales ? BondItemType.debtor : BondItemType.creditor,
        accountName: giftAccount.accName,
        accountId: giftAccount.id,
        note: 'هدايا ${getNote(isSales)} عدد $giftCount من $name',
        date: date,
      ),
      _createBondItem(
        amount: totalGifts,
        billId: billId,
        bondType: isSales ? BondItemType.creditor : BondItemType.debtor,
        accountName: settlementAccount.accName,
        accountId: settlementAccount.id,
        note: 'مقابل هدايا ${getNote(isSales)} عدد $giftCount من $name',
        date: date,
      ),
    ];
  }

  List<EntryBondItemModel> _generateAdjustmentBonds({
    required Map<Account, List<DiscountAdditionAccountModel>> discountsAndAdditions,
    required String billId,
    required AccountModel customerAccount,
    required String date,
    required bool isSales,
  }) {
    return [
      if (discountsAndAdditions.containsKey(BillAccounts.discounts))
        ..._createDiscountOrAdditionBonds(
          models: discountsAndAdditions[BillAccounts.discounts]!,
          billId: billId,
          date: date,
          customerAccount: customerAccount,
          notePrefix: 'حسم ${getNote(isSales)}',
          positiveBondType: isSales ? BondItemType.debtor : BondItemType.creditor,
          oppositeBondType: isSales ? BondItemType.creditor : BondItemType.debtor,
        ),
      if (discountsAndAdditions.containsKey(BillAccounts.additions))
        ..._createDiscountOrAdditionBonds(
          models: discountsAndAdditions[BillAccounts.additions]!,
          billId: billId,
          date: date,
          customerAccount: customerAccount,
          notePrefix: 'اضافة ${getNote(isSales)}',
          positiveBondType: isSales ? BondItemType.creditor : BondItemType.debtor,
          oppositeBondType: isSales ? BondItemType.debtor : BondItemType.creditor,
        ),
    ];
  }

  List<EntryBondItemModel> _createDiscountOrAdditionBonds({
    required String billId,
    required String date,
    required AccountModel customerAccount,
    required List<DiscountAdditionAccountModel> models,
    required String notePrefix,
    required BondItemType positiveBondType,
    required BondItemType oppositeBondType,
  }) =>
      [
        for (final model in models) ...[
          _createBondItem(
            amount: model.amount,
            billId: billId,
            bondType: positiveBondType,
            accountName: model.accName,
            accountId: model.id,
            note: '$notePrefix لحساب ${model.accName}',
            date: date,
          ),
          _createBondItem(
            amount: model.amount,
            billId: billId,
            bondType: oppositeBondType,
            accountName: customerAccount.accName,
            accountId: customerAccount.id,
            note: '$notePrefix لحساب ${model.accName}',
            date: date,
          ),
        ],
      ];

  EntryBondItemModel _createBondItem({
    required double? amount,
    required String? billId,
    required BondItemType? bondType,
    required String? accountName,
    required String? accountId,
    required String? note,
    required String? date,
  }) =>
      EntryBondItemModel(
        bondItemType: bondType,
        amount: amount,
        accountId: accountId,
        accountName: accountName,
        note: note,
        originId: billId,
        date: date,
      );

  String getNote(bool isSales) {
    if (isSales) {
      return 'بيع';
    } else {
      return 'شراء';
    }
  }
}
