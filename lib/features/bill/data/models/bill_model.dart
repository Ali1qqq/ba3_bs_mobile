import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:ba3_bs_mobile/features/sellers/controllers/sellers_controller.dart';
import 'package:equatable/equatable.dart';
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
          billDate: DateTime.now().toString().split(" ")[0],
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
    required String billDate,
    required double billGiftsTotal,
    required double billDiscountsTotal,
    required double billAdditionsTotal,
    required double billTotal,
    required double billVatTotal,
    required double billWithoutVatTotal,
    required BillTypeModel billTypeModel,
    required List<InvoiceRecordModel> billRecordsItems,
  }) {
    final billDetails = BillDetails.fromBillData(
      existingDetails: billModel?.billDetails,
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

  factory BillModel.fromImportedJsonFile(Map<String, dynamic> billData) => BillModel(
        status: Status.approved,
        billDetails: BillDetails(
          billGuid: billData['B']['BillGuid'],
          billPayType: billData['B']['BillPayType'],
          billNumber: billData['B']['BillNumber'],
          billDate: billData['B']['BillDate'],
          billCustomerId: billData['B']['BillCustPtr'],
          note: billData['B']['Note'],
        ),
        billTypeModel: BillTypeModel(
          billTypeLabel: _billTypeLabel(billData['B']['BillTypeGuid']),
          accounts: {
            BillAccounts.caches: AccountModel(
              id: billData['B']['BillCustPtr'],
              accName: billData['B']['BillCustName'],
            ),
            BillAccounts.store: AccountModel(id: billData['B']['BillStoreGuid']),
          },
        ),
        items: BillItems(
          itemList: (billData['Items']['I'] as List<dynamic>)
              .map((item) => BillItem(
                    itemGuid: item['MatPtr'],
                    itemQuantity: (item['QtyBonus'].split(',').first as String).toInt ?? 0,
                    itemTotalPrice: item['PriceDescExtra'].split(',').first,
                    itemName: item['Note'],
                    itemVatPrice: AppServiceUtils.calcVat(
                      item['VatRatio'],
                      (item['PriceDescExtra'].split(',').first as String).toDouble,
                    ),
                  ))
              .toList(),
        ),
      );

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
        plutoAutoIdColumn(): '',
        PlutoColumn(title: 'حالة الفاتورة', field: 'حالة الفاتورة', type: PlutoColumnType.text()): status.value,
        PlutoColumn(title: 'رقم الفاتورة', field: 'رقم الفاتورة', type: PlutoColumnType.text()):
            billDetails.billNumber ?? '',
        PlutoColumn(title: 'نوع الفاتورة', field: 'نوع الفاتورة', type: PlutoColumnType.text()):
            BillType.byLabel(billTypeModel.billTypeLabel ?? '').value,
        PlutoColumn(title: 'التاريخ', field: 'التاريخ', type: PlutoColumnType.text()): billDetails.billDate ?? '',
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
        PlutoColumn(title: 'مجموع الهدايا', field: 'مجموع الهدايا', type: PlutoColumnType.text()):
            billDetails.billGiftsTotal ?? 0,
        PlutoColumn(title: 'نوع الدفع', field: 'نوع الدفع', type: PlutoColumnType.text()):
            InvPayType.fromIndex(billDetails.billPayType ?? 0).label,
        PlutoColumn(title: 'حساب العميل', field: 'حساب العميل', type: PlutoColumnType.text()):
            billTypeModel.accounts?[BillAccounts.caches]?.accName ?? '',
        PlutoColumn(title: 'حساب البائع', field: 'حساب البائع', type: PlutoColumnType.text()):
            read<SellerController>().getSellerNameById(billDetails.billSellerId),
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

  static String _billTypeLabel(String typeGuide) => BillType.byTypeGuide(typeGuide).label;

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

  String _calculateRatio(double value, double total) =>
      total > 0 && value > 0 ? ((value / total) * 100).toStringAsFixed(0) : '';

  double get _partialTotal => (billDetails.billVatTotal ?? 0) + (billDetails.billBeforeVatTotal ?? 0);

  @override
  List<Object?> get props => [
        billId,
        billTypeModel,
        items,
        billDetails,
      ];
}
