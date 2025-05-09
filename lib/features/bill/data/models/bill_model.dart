import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/date_format_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/discount_addition_account_model.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/pluto_auto_id_column.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import 'bill_details.dart';
import 'bill_items.dart';
import 'invoice_record_model.dart';

class BillModel extends PlutoAdaptable with EquatableMixin {
  final String? billId;
  final BillTypeModel billTypeModel;

  final BillItems items;
  final BillDetails billDetails;
  final bool? freeBill;

  final Status status;

  BillModel({
    this.billId,
    required this.billTypeModel,
    required this.items,
    required this.billDetails,
    required this.status,
    required this.freeBill,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        billId: json['docId'],
        freeBill: json['freeBill'],
        billTypeModel: BillTypeModel.fromJson(json['billTypeModel']),
        billDetails: BillDetails.fromJson(json['billDetails']),
        items: BillItems.fromJson(json['items']),
        status: Status.byValue(json['status']),
      );

  factory BillModel.empty({required BillTypeModel billTypeModel, int lastBillNumber = 0, int? previousBillNumber}) => BillModel(
        billTypeModel: billTypeModel,
        status: Status.pending,
        freeBill: false,
        items: const BillItems(itemList: []),
        billDetails: BillDetails(
          billPayType: InvPayType.cash.index,
          billDate: DateTime.now(),
          previous: previousBillNumber ?? (lastBillNumber == 0 ? null : lastBillNumber),
          billNumber: lastBillNumber + 1,
        ),
      );

  factory BillModel.fromBillData({
    BillModel? billModel,
    String? note,
    String? orderNumber,
    String? customerPhone,
    String? billCustomerId,
    required String billAccountId,
    required Status status,
    required String billSellerId,
    required int billPayType,
    required DateTime billDate,
    required double billGiftsTotal,
    required double billDiscountsTotal,
    required double billAdditionsTotal,
    required double billTotal,
    required double billVatTotal,
    required double billFirstPay,
    required double billWithoutVatTotal,
    required BillTypeModel billTypeModel,
    required bool freeBill,
    required List<InvoiceRecordModel> billRecords,
  }) {
    final billDetails = BillDetails.fromBillData(
      existingDetails: billModel?.billDetails,
      billFirstPay: billFirstPay,
      billNote: note,
      orderNumber: orderNumber,
      customerPhone: customerPhone,
      billCustomerId: billCustomerId,
      billAccountId: billAccountId,
      billSellerId: billSellerId,
      billPayType: billPayType,
      billDate: billDate,
      billTotal: billTotal,
      billVatTotal: billVatTotal,
      billWithoutVatTotal: billWithoutVatTotal,
      billGiftsTotal: billGiftsTotal,
      billDiscountsTotal: billDiscountsTotal,
      billAdditionsTotal: billAdditionsTotal,
    );

    final items = BillItems.fromBillRecords(billRecords);

    return billModel == null
        ? BillModel(
            billTypeModel: billTypeModel,
            billDetails: billDetails,
            items: items,
            status: status,
            freeBill: freeBill,
          )
        : billModel.copyWith(
            billTypeModel: billTypeModel,
            billDetails: billDetails,
            items: items,
            status: status,
            freeBill: freeBill,
          );
  }

  factory BillModel.fromImportedJsonFile(Map<String, dynamic> billData, bool freeBill) {
    DateFormat dateFormat = DateFormat('yyyy-M-d');
    double billTotal = 0;
    double billVatTotal = 0;
    double billGiftsTotal = 0;

    return BillModel(
      status: Status.approved,
      freeBill: freeBill,
      billId: billData['B']['BillGuid'],
      items: BillItems(
        itemList: (billData['Items']['I'] is List<dynamic>)
            ? (billData['Items']['I'] as List<dynamic>).map((item) {
                /*       int vatRatio =  5;
                double itemSubTotal = double.parse(item['PriceDescExtra'].split(',').first)/ 1.05;*/
                int vatRatio = int.parse(item['VatRatio']);
                double itemSubTotal = double.parse(item['PriceDescExtra'].split(',').first);

                int itemQuantity = int.parse(item['QtyBonus'].split(',').first);
                int itemGiftsNumber = int.parse(item['QtyBonus'].split(',')[1]);

                // حساب المجموعات للعناصر داخل القائمة
                billTotal += AppServiceUtils.calcTotal(
                  itemQuantity,
                  itemSubTotal,
                  AppServiceUtils.calcVat(
                    vatRatio,
                    itemSubTotal,
                  ).toDouble(),
                );
                billGiftsTotal += AppServiceUtils.calcGiftPrice(
                  itemGiftsNumber,
                  itemSubTotal,
                );
                billVatTotal += AppServiceUtils.calcVat(
                  vatRatio,
                  itemSubTotal,
                ).toDouble();

                return BillItem(
                  itemGuid: item['MatPtr'],
                  itemQuantity: itemQuantity,
                  itemSubTotalPrice: itemSubTotal,
                  itemTotalPrice: AppServiceUtils.calcTotal(
                    itemQuantity,
                    itemSubTotal,
                    AppServiceUtils.calcVat(
                      vatRatio,
                      itemSubTotal,
                    ).toDouble(),
                  ).toString(),
                  itemGiftsPrice: AppServiceUtils.calcGiftPrice(
                    itemGiftsNumber,
                    itemSubTotal,
                  ),
                  itemGiftsNumber: itemGiftsNumber,
                  itemName: item['MatName'],
                  itemVatPrice: AppServiceUtils.calcVat(
                    vatRatio,
                    itemSubTotal,
                  ),
                );
              }).toList()
            : [
                () {
                  final item = billData['Items']['I'];

                  /*            int vatRatio =  5;
                  double itemSubTotal = double.parse(item['PriceDescExtra'].split(',').first)/ 1.05;*/
                  int vatRatio = int.parse(item['VatRatio']);
                  double itemSubTotal = double.parse(item['PriceDescExtra'].split(',').first);

                  int itemQuantity = int.parse(item['QtyBonus'].split(',').first);
                  int itemGiftsNumber = int.parse(item['QtyBonus'].split(',')[1]);
                  billTotal += AppServiceUtils.calcTotal(
                    itemQuantity,
                    itemSubTotal,
                    AppServiceUtils.calcVat(
                      vatRatio,
                      itemSubTotal,
                    ).toDouble(),
                  );
                  billGiftsTotal += AppServiceUtils.calcGiftPrice(
                    itemGiftsNumber,
                    itemSubTotal,
                  );
                  billVatTotal += AppServiceUtils.calcVat(
                    vatRatio,
                    itemSubTotal,
                  ).toDouble();

                  return BillItem(
                    itemGuid: item['MatPtr'],
                    itemQuantity: itemQuantity,
                    itemSubTotalPrice: itemSubTotal,
                    itemTotalPrice: AppServiceUtils.calcTotal(
                      itemQuantity,
                      itemSubTotal,
                      AppServiceUtils.calcVat(
                        vatRatio,
                        itemSubTotal,
                      ),
                    ).toString(),
                    itemGiftsPrice: AppServiceUtils.calcGiftPrice(
                      itemGiftsNumber,
                      itemSubTotal,
                    ),
                    itemGiftsNumber: itemGiftsNumber,
                    itemName: read<MaterialController>().getMaterialNameById(item['MatPtr'].toString()),
                    itemVatPrice: AppServiceUtils.calcVat(
                      vatRatio,
                      itemSubTotal,
                    ),
                  );
                }(),
              ],
      ),
      billDetails: BillDetails(
        billFirstPay: double.tryParse(billData['B']['BillFirstPay']) ?? 0.0,
        billGuid: billData['B']['BillGuid'],
        billPayType: int.parse(billData['B']['BillPayType']),
        billNumber: (billData['B']['BillNumber']),
        billDate: dateFormat.parse(billData['B']['BillDate'].toString().toYearMonthDayFormat()),
        billCustomerId: billData['B']['BillCustPtr'],
        billAccountId: billData['B']['BillCustAcc'],
        billSellerId: billData['B']['BillCostGuid'],
        billGiftsTotal: billGiftsTotal,
        billTotal: billTotal,
        billVatTotal: billVatTotal,
        billDiscountsTotal: 0,
        billAdditionsTotal: 0,
        billBeforeVatTotal: billTotal - billVatTotal,
        billNote: billData['B']['Note'],
        customerPhone: billData['B']['CustomerPhone'],
        orderNumber: billData['B']['OrderNumber'],
      ),
      billTypeModel: BillTypeModel(
          billTypeLabel: _billTypeByGuid(billData['B']['BillTypeGuid']).label,
          discountAdditionAccounts: {
            if (_billTypeByGuid(billData['B']['BillTypeGuid']).billPatternType.hasDiscountsAccount)
              BillAccounts.discounts: [
                DiscountAdditionAccountModel(
                  accName: _billTypeByGuid(billData['B']['BillTypeGuid']).accounts[BillAccounts.discounts]!.accName!,
                  percentage: 0,
                  amount: 0,
                  id: _billTypeByGuid(billData['B']['BillTypeGuid']).accounts[BillAccounts.discounts]!.id!,
                ),
              ],
            if (_billTypeByGuid(billData['B']['BillTypeGuid']).billPatternType.hasAdditionsAccount)
              BillAccounts.additions: [
                DiscountAdditionAccountModel(
                  accName: _billTypeByGuid(billData['B']['BillTypeGuid']).accounts[BillAccounts.additions]!.accName!,
                  percentage: 0,
                  amount: 0,
                  id: _billTypeByGuid(billData['B']['BillTypeGuid']).accounts[BillAccounts.additions]!.id!,
                ),
              ],
          },
          accounts: {
            BillAccounts.caches: AccountModel(
              id: billData['B']['BillCustAccId'],
              accName: billData['B']['BillCustAccName'],
            ),
            if (_billTypeByGuid(billData['B']['BillTypeGuid']).billPatternType.hasMaterialAccount)
              BillAccounts.materials: _billTypeByGuid(billData['B']['BillTypeGuid']).accounts[BillAccounts.materials]!,
            if (_billTypeByGuid(billData['B']['BillTypeGuid']).billPatternType.hasGiftsAccount)
              BillAccounts.gifts: _billTypeByGuid(billData['B']['BillTypeGuid']).accounts[BillAccounts.gifts]!,
            if (_billTypeByGuid(billData['B']['BillTypeGuid']).billPatternType.hasGiftsAccount)
              BillAccounts.exchangeForGifts: _billTypeByGuid(billData['B']['BillTypeGuid']).accounts[BillAccounts.exchangeForGifts]!,
            if (_billTypeByGuid(billData['B']['BillTypeGuid']).billPatternType.hasDiscountsAccount)
              BillAccounts.discounts: _billTypeByGuid(billData['B']['BillTypeGuid']).accounts[BillAccounts.discounts]!,
            if (_billTypeByGuid(billData['B']['BillTypeGuid']).billPatternType.hasAdditionsAccount)
              BillAccounts.additions: _billTypeByGuid(billData['B']['BillTypeGuid']).accounts[BillAccounts.additions]!,
            BillAccounts.store: AccountModel(accName: "المستودع الرئيسي", id: '6d9836d1-fccd-4006-804f-81709eecde57')
            /*AccountModel(
                id: billData['B']['BillStoreGuid'], accName: read<AccountsController>().getAccountNameById(billData['B']['BillStoreGuid'])),*/
          },
          id: billData['B']['BillTypeGuid'],
          fullName: _billTypeByGuid(billData['B']['BillTypeGuid']).value,
          latinFullName: _billTypeByGuid(billData['B']['BillTypeGuid']).label,
          latinShortName: _billTypeByGuid(billData['B']['BillTypeGuid']).label,
          shortName: _billTypeByGuid(billData['B']['BillTypeGuid']).value,
          billTypeId: billData['B']['BillTypeGuid'],
          color: _billTypeByGuid(billData['B']['BillTypeGuid']).color,
          billPatternType: _billTypeByGuid(billData['B']['BillTypeGuid']).billPatternType),
    );
  }

  Map<String, dynamic> toJson() => {
        'docId': billId,
        'billTypeModel': billTypeModel.toJson(),
        'billDetails': billDetails.toJson(),
        'items': items.toJson(),
        'status': status.value,
        'freeBill': freeBill,
      };

  BillModel copyWith({
    final String? billId,
    final BillTypeModel? billTypeModel,
    final BillItems? items,
    final BillDetails? billDetails,
    final Status? status,
    final bool? freeBill,
  }) =>
      BillModel(
        billId: billId ?? this.billId,
        billTypeModel: billTypeModel ?? this.billTypeModel,
        items: items ?? this.items,
        billDetails: billDetails ?? this.billDetails,
        status: status ?? this.status,
        freeBill: freeBill ?? this.freeBill,
      );

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([void type]) => {
        PlutoColumn(title: 'billId', field: AppConstants.billIdFiled, type: PlutoColumnType.text(), hide: true): billId ?? '',
        createAutoIdColumn(): '#',
        PlutoColumn(title: AppStrings.billStatus.tr, field: 'حالة الفاتورة', type: PlutoColumnType.text()): status.value,
        PlutoColumn(title: AppStrings.billNumber.tr, field: 'رقم الفاتورة', type: PlutoColumnType.number()): billDetails.billNumber ?? 0,
        PlutoColumn(title: AppStrings.date.tr, field: 'التاريخ', type: PlutoColumnType.date()): billDetails.billDate?.dayMonthYear ?? '',
        PlutoColumn(title: AppStrings.taxTotal.tr, field: 'مجموع الضريبة', type: PlutoColumnType.number()):
            AppServiceUtils.toFixedDouble(billDetails.billVatTotal),
        PlutoColumn(title: AppStrings.totalBeforeTax.tr, field: 'المجموع قبل الضريبة', type: PlutoColumnType.number()):
            AppServiceUtils.toFixedDouble(billDetails.billBeforeVatTotal),
        PlutoColumn(title: AppStrings.total.tr, field: 'المجموع الكلي', type: PlutoColumnType.number()):
            AppServiceUtils.toFixedDouble(billDetails.billTotal),
        PlutoColumn(title: AppStrings.discountTotal.tr, field: 'مجموع الحسم', type: PlutoColumnType.number()):
            AppServiceUtils.toFixedDouble(billDetails.billDiscountsTotal),
        PlutoColumn(title: AppStrings.additionsTotal.tr, field: 'مجموع الاضافات', type: PlutoColumnType.number()):
            AppServiceUtils.toFixedDouble(billDetails.billAdditionsTotal),
        PlutoColumn(title: AppStrings.giftsTotal.tr, field: 'مجموع الهدايا', type: PlutoColumnType.number()):
            billDetails.billGiftsTotal ?? 0,
        PlutoColumn(title: AppStrings.payType.tr, field: 'نوع الدفع', type: PlutoColumnType.text()):
            InvPayType.fromIndex(billDetails.billPayType ?? 0).label,
        PlutoColumn(title: AppStrings.customerAccount.tr, field: 'حساب العميل', type: PlutoColumnType.text()):
            billTypeModel.accounts?[BillAccounts.caches]?.accName ?? '',
        PlutoColumn(title: '${AppStrings.account.tr} ${AppStrings.seller.tr}', field: 'حساب البائع', type: PlutoColumnType.text()):
            read<SellersController>().getSellerNameById(billDetails.billSellerId),
        PlutoColumn(title: AppStrings.store.tr, field: 'المستودع', type: PlutoColumnType.text()):
            billTypeModel.accounts?[BillAccounts.store]?.accName ?? '',
        PlutoColumn(title: AppStrings.illustration.tr, field: 'وصف', type: PlutoColumnType.text()): billDetails.billNote ?? '',
      };

  List<Map<String, String>> get getAdditionsDiscountsRecords => _additionsDiscountsRecords;

  List<Map<String, String>> get _additionsDiscountsRecords {
    final partialTotal = _partialTotal;

    final discountTotal = AppServiceUtils.zeroToEmpty(billDetails.billDiscountsTotal);
    final additionTotal = AppServiceUtils.zeroToEmpty(billDetails.billAdditionsTotal);

    return [
      _createRecordRow(
        account: billTypeModel.accounts?[BillAccounts.discounts]?.accName ?? '',
        discountValue: discountTotal,
        discountRatio: _calculateRatio(billDetails.billDiscountsTotal ?? 0, partialTotal),
        additionValue: '',
        additionRatio: '',
      ),
      _createRecordRow(
        account: billTypeModel.accounts?[BillAccounts.additions]?.accName ?? '',
        discountValue: '',
        discountRatio: '',
        additionValue: additionTotal,
        additionRatio: _calculateRatio(billDetails.billAdditionsTotal ?? 0, partialTotal),
      ),
    ];
  }

  static BillType _billTypeByGuid(String typeGuide) => BillType.byTypeGuide(typeGuide);

  Map<String, String> _createRecordRow({
    required String account,
    required String discountValue,
    required String additionValue,
    required String discountRatio,
    required String additionRatio,
  }) =>
      {
        AppConstants.id: account,
        AppConstants.discount: discountValue,
        AppConstants.discountRatio: discountRatio,
        AppConstants.addition: additionValue,
        AppConstants.additionRatio: additionRatio,
      };

  String _calculateRatio(double value, double total) => total > 0 && value > 0 ? ((value / total) * 100).toStringAsFixed(0) : '';

  double get _partialTotal => (billDetails.billVatTotal ?? 0) + (billDetails.billBeforeVatTotal ?? 0);

  @override
  List<Object?> get props => [
        billId,
        billTypeModel,
        items,
        billDetails,
        status,
      ];
}