import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_fromat_extension.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/date_time_extensions.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs_mobile/features/bill/data/models/discount_addition_account_model.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
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

  final Status status;

  BillModel({
    this.billId,
    required this.billTypeModel,
    required this.items,
    required this.billDetails,
    required this.status,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        billId: json['docId'],
        billTypeModel: BillTypeModel.fromJson(json['billTypeModel']),
        billDetails: BillDetails.fromJson(json['billDetails']),
        items: BillItems.fromJson(json['items']),
        status: Status.byValue(json['status']),
      );

  factory BillModel.empty({required BillTypeModel billTypeModel, int lastBillNumber = 0}) => BillModel(
        billTypeModel: billTypeModel,
        status: Status.pending,
        items: const BillItems(itemList: []),
        billDetails: BillDetails(
          billPayType: InvPayType.cash.index,
          billDate: DateTime.now(),
          billNumber: lastBillNumber + 1,
        ),
      );

  factory BillModel.fromBillData({
    BillModel? billModel,
    String? note,
    required String billCustomerId,
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
    required List<InvoiceRecordModel> billRecordsItems,
  }) {
    final billDetails = BillDetails.fromBillData(
      existingDetails: billModel?.billDetails,
      billFirstPay: billFirstPay,
      note: note,
      billCustomerId: billCustomerId,
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

    final items = BillItems.fromBillRecords(billRecordsItems);

    return billModel == null
        ? BillModel(
            billTypeModel: billTypeModel,
            billDetails: billDetails,
            items: items,
            status: status,
          )
        : billModel.copyWith(
            billTypeModel: billTypeModel,
            billDetails: billDetails,
            items: items,
            status: status,
          );
  }

  factory BillModel.fromImportedJsonFile(Map<String, dynamic> billData) {
    DateFormat dateFormat = DateFormat('yyyy-M-d');
    double billTotal = 0;
    double billVatTotal = 0;
    double billGiftsTotal = 0;
    return BillModel(
      status: Status.approved,
      billId: billData['B']['BillGuid'],
      items: BillItems(
        itemList: (billData['Items']['I'] is List<dynamic>)
            ? (billData['Items']['I'] as List<dynamic>).map((item) {
                // حساب المجموعات للعناصر داخل القائمة
                billTotal += AppServiceUtils.calcTotal(
                  int.parse(item['QtyBonus'].split(',').first),
                  double.parse(item['PriceDescExtra'].split(',').first),
                  AppServiceUtils.calcVat(
                    int.parse(item['VatRatio']),
                    double.parse(item['PriceDescExtra'].split(',').first),
                  ).toDouble(),
                );
                billGiftsTotal += AppServiceUtils.calcGiftPrice(
                  int.parse(item['QtyBonus'].split(',')[1]),
                  double.parse(item['PriceDescExtra'].split(',').first),
                );
                billVatTotal += AppServiceUtils.calcVat(
                  int.parse(item['VatRatio']),
                  double.parse(item['PriceDescExtra'].split(',').first),
                ).toDouble();

                return BillItem(
                  itemGuid: item['MatPtr'],
                  itemQuantity: int.parse(item['QtyBonus'].split(',').first),
                  itemSubTotalPrice: double.parse(item['PriceDescExtra'].split(',').first),
                  itemTotalPrice: AppServiceUtils.calcTotal(
                    int.parse(item['QtyBonus'].split(',').first),
                    double.parse(item['PriceDescExtra'].split(',').first),
                    AppServiceUtils.calcVat(
                      int.parse(item['VatRatio']),
                      double.parse(item['PriceDescExtra'].split(',').first),
                    ).toDouble(),
                  ).toString(),
                  itemGiftsPrice: AppServiceUtils.calcGiftPrice(
                    int.parse(item['QtyBonus'].split(',')[1]),
                    double.parse(item['PriceDescExtra'].split(',').first),
                  ),
                  itemGiftsNumber: int.parse(item['QtyBonus'].split(',')[1]),
                  itemName: item['MatName'],
                  itemVatPrice: AppServiceUtils.calcVat(
                    int.parse(item['VatRatio']),
                    double.parse(item['PriceDescExtra'].split(',').first),
                  ),
                );
              }).toList()
            : [
                () {
                  final item = billData['Items']['I'];
                  billTotal += AppServiceUtils.calcTotal(
                    int.parse(item['QtyBonus'].split(',').first),
                    double.parse(item['PriceDescExtra'].split(',').first),
                    AppServiceUtils.calcVat(
                      int.parse(item['VatRatio']),
                      double.parse(item['PriceDescExtra'].split(',').first),
                    ).toDouble(),
                  );
                  billGiftsTotal += AppServiceUtils.calcGiftPrice(
                    int.parse(item['QtyBonus'].split(',')[1]),
                    double.parse(item['PriceDescExtra'].split(',').first),
                  );
                  billVatTotal += AppServiceUtils.calcVat(
                    int.parse(item['VatRatio']),
                    double.parse(item['PriceDescExtra'].split(',').first),
                  ).toDouble();

                  return BillItem(
                    itemGuid: item['MatPtr'],
                    itemQuantity: int.parse(item['QtyBonus'].split(',').first),
                    itemSubTotalPrice: double.parse(item['PriceDescExtra'].split(',').first),
                    itemTotalPrice: AppServiceUtils.calcTotal(
                      int.parse(item['QtyBonus'].split(',').first),
                      double.parse(item['PriceDescExtra'].split(',').first),
                      AppServiceUtils.calcVat(
                        int.parse(item['VatRatio']),
                        double.parse(item['PriceDescExtra'].split(',').first),
                      ),
                    ).toString(),
                    itemGiftsPrice: AppServiceUtils.calcGiftPrice(
                      int.parse(item['QtyBonus'].split(',')[1]),
                      double.parse(item['PriceDescExtra'].split(',').first),
                    ),
                    itemGiftsNumber: int.parse(item['QtyBonus'].split(',')[1]),
                    itemName: read<MaterialController>().getMaterialNameById(item['MatPtr'].toString()),
                    itemVatPrice: AppServiceUtils.calcVat(
                      int.parse(item['VatRatio']),
                      double.parse(item['PriceDescExtra'].split(',').first),
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
        billCustomerId: billData['B']['BillCustAcc'],
        billSellerId: billData['B']['BillCostGuid'],
        billGiftsTotal: billGiftsTotal,
        billTotal: billTotal,
        billVatTotal: billVatTotal,
        billDiscountsTotal: 0,
        billAdditionsTotal: 0,
        billBeforeVatTotal: billTotal - billVatTotal,
        note: billData['B']['Note'].toString(),
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
              id: billData['B']['BillCustPtr'],
              accName: billData['B']['BillCustName'],
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
            BillAccounts.store: AccountModel(
                id: billData['B']['BillStoreGuid'], accName: read<AccountsController>().getAccountNameById(billData['B']['BillStoreGuid'])),
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
      };

  BillModel copyWith({
    final String? billId,
    final BillTypeModel? billTypeModel,
    final BillItems? items,
    final BillDetails? billDetails,
    final Status? status,
  }) =>
      BillModel(
        billId: billId ?? this.billId,
        billTypeModel: billTypeModel ?? this.billTypeModel,
        items: items ?? this.items,
        billDetails: billDetails ?? this.billDetails,
        status: status ?? this.status,
      );

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([void type]) => {
        PlutoColumn(title: 'billId', field: 'billId', type: PlutoColumnType.text(), hide: true): billId ?? '',
        createAutoIdColumn(): '',
        PlutoColumn(title: 'حالة الفاتورة', field: 'حالة الفاتورة', type: PlutoColumnType.text()): status.value,
        PlutoColumn(title: 'رقم الفاتورة', field: 'رقم الفاتورة', type: PlutoColumnType.number()): billDetails.billNumber ?? 0,
        PlutoColumn(title: 'نوع الفاتورة', field: 'نوع الفاتورة', type: PlutoColumnType.text()):
            BillType.byLabel(billTypeModel.billTypeLabel ?? '').value,
        PlutoColumn(title: 'التاريخ', field: 'التاريخ', type: PlutoColumnType.date()): billDetails.billDate?.dayMonthYear ?? '',
        PlutoColumn(title: 'مجموع الضريبة', field: 'مجموع الضريبة', type: PlutoColumnType.text()):
            AppServiceUtils.toFixedDouble(billDetails.billVatTotal),
        PlutoColumn(title: 'المجموع قبل الضريبة', field: 'المجموع قبل الضريبة', type: PlutoColumnType.text()):
            AppServiceUtils.toFixedDouble(billDetails.billBeforeVatTotal),
        PlutoColumn(title: 'المجموع الكلي', field: 'المجموع الكلي', type: PlutoColumnType.text()):
            AppServiceUtils.toFixedDouble(billDetails.billTotal),
        PlutoColumn(title: 'مجموع الحسم', field: 'مجموع الحسم', type: PlutoColumnType.text()):
            AppServiceUtils.toFixedDouble(billDetails.billDiscountsTotal),
        PlutoColumn(title: 'مجموع الاضافات', field: 'مجموع الاضافات', type: PlutoColumnType.text()):
            AppServiceUtils.toFixedDouble(billDetails.billAdditionsTotal),
        PlutoColumn(title: 'مجموع الهدايا', field: 'مجموع الهدايا', type: PlutoColumnType.text()): billDetails.billGiftsTotal ?? 0,
        PlutoColumn(title: 'نوع الدفع', field: 'نوع الدفع', type: PlutoColumnType.text()):
            InvPayType.fromIndex(billDetails.billPayType ?? 0).label,
        PlutoColumn(title: 'حساب العميل', field: 'حساب العميل', type: PlutoColumnType.text()):
            billTypeModel.accounts?[BillAccounts.caches]?.accName ?? '',
        PlutoColumn(title: 'حساب البائع', field: 'حساب البائع', type: PlutoColumnType.text()):
            read<SellersController>().getSellerNameById(billDetails.billSellerId),
        PlutoColumn(title: 'المستودع', field: 'المستودع', type: PlutoColumnType.text()):
            billTypeModel.accounts?[BillAccounts.store]?.accName ?? '',
        PlutoColumn(title: 'وصف', field: 'وصف', type: PlutoColumnType.text()): billDetails.note ?? '',
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
      ];
}
