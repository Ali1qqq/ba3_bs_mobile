import 'package:ba3_bs_mobile/core/helper/extensions/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_items.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/material_model.dart';
import 'package:ba3_bs_mobile/features/tax/data/models/tax_model.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bill/data/models/discount_addition_account_model.dart';
import '../../../bond/data/models/entry_bond_model.dart';

mixin BillEntryBondCreatingService {
  EntryBondModel createEntryBondModel({
    required EntryBondType originType,
    required BillModel billModel,
    required Map<Account, List<DiscountAdditionAccountModel>> discountsAndAdditions,
    required bool isSimulatedVat,
  }) {
    return EntryBondModel(
      origin: EntryBondOrigin(
        originId: billModel.billId,
        originType: originType,
        originTypeId: billModel.billTypeModel.billTypeId,
      ),
      items: generateBondItems(billModel: billModel, discountsAndAdditions: discountsAndAdditions, isSimulatedVat: isSimulatedVat),
    );
  }

  List<EntryBondItemModel> generateBondItems({
    required BillModel billModel,
    required Map<Account, List<DiscountAdditionAccountModel>> discountsAndAdditions,
    required bool isSimulatedVat,
  }) {
    final customerAccount = billModel.billTypeModel.accounts![BillAccounts.caches]!;

    final billType = BillType.byLabel(billModel.billTypeModel.billTypeLabel!);
    final isSales = billType == BillType.sales;

    final date = billModel.billDetails.billDate!.dayMonthYear;

    final itemBonds = _generateBillItemBonds(
      billId: billModel.billId!,
      accounts: billModel.billTypeModel.accounts!,
      customerAccount: customerAccount,
      billItems: billModel.items.itemList,
      date: date,
      isSales: isSales,
      isSimulatedVat: isSimulatedVat,
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
    required bool isSimulatedVat,
  }) {
    return billItems.expand((item) {
      return [
        if (accounts.containsKey(BillAccounts.materials) && item.itemQuantity > 0)
          _createMaterialBond(
            billId: billId,
            materialAccount: accounts[BillAccounts.materials]!,
            total: item.itemSubTotalPrice! * item.itemQuantity,
            quantity: item.itemQuantity,
            name: item.itemName!,
            date: date,
            isSales: isSales,
          ),
        if (item.itemQuantity > 0)
          ..._generateCustomerBonds(
              billId: billId, customerAccount: customerAccount, item: item, date: date, isSales: isSales, isSimulatedVat: isSimulatedVat),
        ..._createOptionalBonds(
          billId: billId,
          accounts: accounts,
          item: item,
          date: date,
          isSales: isSales,
          isSimulatedVat: isSimulatedVat,
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
    required bool isSimulatedVat,
  }) {
    final giftCount = item.itemGiftsNumber;
    final giftPrice = item.itemGiftsPrice;

    /// When isSimulatedVat is true, VAT is calculated as 5% of the total price for preview purposes only.
    /// Otherwise, the actual VAT value is used.
    final vat = isSimulatedVat ? _calculateSimulatedVat(item) : _calculateActualVat(item);

    return [
      if (vat > 0)
        _createVatBond(
          billId: billId,
          vat: vat,
          item: read<MaterialController>().materials.firstWhere(
                (mat) => mat.id == item.itemGuid,
              ),
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
          name: item.itemName!,
          date: date,
          isSales: isSales,
        ),
    ];
  }

  /// Helper function for calculating simulated VAT.
  double _calculateSimulatedVat(BillItem item) => ((double.parse(item.itemTotalPrice) / 1.05) * 0.05) * item.itemQuantity;

  /// Helper function for calculating the actual VAT value.
  double _calculateActualVat(BillItem item) => item.itemVatPrice! * item.itemQuantity;

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
    required bool isSimulatedVat,
  }) {
    /// هذه العملية لحساب الضريبة من المجموع الكلي ودائما تكون الضريبة نسبة 5% عند الاستعراض فقط
    final vat =
        isSimulatedVat ? ((double.parse(item.itemTotalPrice) / 1.05) * 0.05) * item.itemQuantity : item.itemVatPrice! * item.itemQuantity;
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
      if (vat > 0)
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
    required MaterialModel item,
    required int quantity,
    required String date,
    required bool isSales,
  }) {
    final bondType = isSales ? BondItemType.creditor : BondItemType.debtor;
    final accountId = item.matVatGuid == null ? VatEnums.withVat.taxAccountGuid : VatEnums.byGuid(item.matVatGuid!).taxAccountGuid;
    final note = 'ضريبة ${getNote(isSales)} عدد $quantity من ${item.matName}';

    return _createBondItem(
      amount: vat,
      billId: billId,
      bondType: bondType,
      accountName: 'ضريبة القيمة المضافة',
      accountId: accountId,
      note: note,
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
