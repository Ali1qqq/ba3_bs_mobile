import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/pluto_auto_id_column.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../../pluto/data/models/pluto_adaptable.dart';

/// Represents a bond entry with associated details and items.
class EntryBondModel {
  /// List of bond items associated with this bond entry.
  final List<EntryBondItemModel>? items;

  /// Refers to the origin entity of the bond entry (e.g., billTypeId for invoices).
  final EntryBondOrigin? origin;

  EntryBondModel({this.items, this.origin});

  /// Creates an instance from a JSON object.
  factory EntryBondModel.fromJson(Map<String, dynamic> json) {
    return EntryBondModel(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => EntryBondItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      origin: EntryBondOrigin.fromJson(json['origin']),
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((item) => item.toJson()).toList(),
      'origin': origin?.toJson(),
    };
  }

  /// Creates a new instance with modified fields.
  EntryBondModel copyWith({
    List<EntryBondItemModel>? items,
    EntryBondOrigin? origin,
  }) {
    return EntryBondModel(
      items: items ?? this.items,
      origin: origin ?? this.origin,
    );
  }
}

/// Represents a single bond item within a bond entry.
class EntryBondItemModel implements PlutoAdaptable {
  /// Type of the bond item, defined by an enum.
  final BondItemType? bondItemType;

  /// The monetary amount associated with this bond item.
  final double? amount;

  /// The account related to this bond item.
  final String? accountId;

  /// The account related to this bond item.
  final String? accountName;

  /// Additional notes or comments for this bond item.
  final String? note;

  /// Refers to the bond entry ID that this item belongs to.
  final String? originId;

  final String? date;

  EntryBondItemModel({
    this.bondItemType,
    this.amount,
    this.accountId,
    this.accountName,
    this.note,
    this.originId,
    this.date,
  });

  /// Creates an instance from a JSON object.
  factory EntryBondItemModel.fromJson(Map<String, dynamic> json) {
    return EntryBondItemModel(
      bondItemType: BondItemType.byLabel(json['bondItemType']),
      amount: (json['amount'] as num?)?.toDouble(),
      accountId: json['accountId'] as String?,
      accountName: json['accountName'] as String?,
      note: json['note'] as String?,
      originId: json['originId'] as String?,
      date: json['date'] as String?,
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'bondItemType': bondItemType?.label,
      'amount': amount,
      'accountId': accountId,
      'accountName': accountName,
      'note': note,
      'originId': originId,
      'date': date,
    };
  }

  /// Creates a new instance with modified fields.
  EntryBondItemModel copyWith({
    BondItemType? bondItemType,
    double? amount,
    String? accountId,
    String? accountName,
    String? note,
    String? originId,
    String? date,
  }) {
    return EntryBondItemModel(
      bondItemType: bondItemType ?? this.bondItemType,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      accountName: accountName ?? this.accountName,
      note: note ?? this.note,
      originId: originId ?? this.originId,
      date: date ?? this.date,
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([void _]) {
    final accountsController = read<AccountsController>();
    return {
      PlutoColumn(hide: true, title: 'originId', field: 'originId', type: PlutoColumnType.text()): originId ?? '',
      plutoAutoIdColumn(): '',
      PlutoColumn(
          title: 'مدين',
          field: 'مدين',
          type: PlutoColumnType.currency(
            format: '#,##0.00 AED',
            locale: 'en_AE',
            symbol: 'AED',
          )): bondItemType == BondItemType.debtor ? amount : 0,
      PlutoColumn(
          title: 'دائن',
          field: 'دائن',
          type: PlutoColumnType.currency(
            format: '#,##0.00 AED',
            locale: 'en_AE',
            symbol: 'AED',
          )): bondItemType == BondItemType.creditor ? amount : 0,
      PlutoColumn(title: 'الحساب', field: 'الحساب', type: PlutoColumnType.text()):
          accountsController.getAccountNameById(accountId),
      PlutoColumn(title: 'التاريخ', field: 'التاريخ', type: PlutoColumnType.date()): date,
      PlutoColumn(title: 'البيان', field: 'البيان', type: PlutoColumnType.text()): note,
    };
  }
}

class EntryBondOrigin {
  /// Unique identifier for the bond entry, which is the same as the origin ID (e.g., billId).
  final String? originId;

  /// Refers to the origin entity type id of the bond entry (e.g., billTypeId for bills).
  final String? originTypeId;

  /// Refers to the type of the bond entry (bond, bill, cheque).
  final EntryBondType? originType;

  EntryBondOrigin({
    this.originId,
    this.originTypeId,
    this.originType,
  });

  factory EntryBondOrigin.fromJson(Map<String, dynamic> json) {
    return EntryBondOrigin(
      originId: json['originId'] as String?,
      originTypeId: json['originTypeId'] as String?,
      originType: EntryBondType.byLabel(json['originType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originId': originId,
      'originTypeId': originTypeId,
      'originType': originType?.label,
    };
  }

  EntryBondOrigin copyWith({
    String? originId,
    String? originTypeId,
    EntryBondType? originType,
  }) {
    return EntryBondOrigin(
      originId: originId ?? this.originId,
      originTypeId: originTypeId ?? this.originTypeId,
      originType: originType ?? this.originType,
    );
  }
}
