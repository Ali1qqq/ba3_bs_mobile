import 'dart:developer';

import 'package:pluto_grid/pluto_grid.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/pluto_auto_id_column.dart';
import '../../../../pluto/data/models/pluto_adaptable.dart';

class MatStatementModel implements PlutoAdaptable {
  final MatOrigin? matOrigin;

  final int? quantity;
  final int? defQuantity;

  final double? price;
  final DateTime? date;
  final String? note;
  final String? matId;
  final String? originId;
  final String? matName;

  MatStatementModel({
    this.matOrigin,
    this.quantity,
    this.note,
    this.date,
    this.price,
    this.matId,
    this.originId,
    this.matName,
    this.defQuantity,
  });

  /// Creates an instance from a JSON object.
  factory MatStatementModel.fromJson(Map<String, dynamic> json) {
    return MatStatementModel(
      matOrigin: MatOrigin.fromJson(json['matOriginType']),
      quantity: (json['quantity'] as num?)?.toInt(),
      note: json['note'] as String?,
      matId: json['matId'] as String?,
      originId: json['docId'] as String?,
      matName: json['matName'] as String?,
      date: DateTime.tryParse(json['date'] as String? ?? ''),
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'matOriginType': matOrigin?.toJson(),
      'quantity': quantity,
      'note': note,
      'matId': matId,
      'matName': matName,
      'docId': originId,
      'date': date?.toIso8601String(),
      'price': price,
    };
  }

  /// Creates a new instance with modified fields.
  MatStatementModel copyWith({
    final MatOrigin? matOrigin,
    final int? quantity,
    final int? defQuantity,
    final String? note,
    final String? originId,
    final double? price,
    final DateTime? date,
    final String? docId,
    final String? matId,
    final String? matName,
  }) {
    return MatStatementModel(
      matOrigin: matOrigin ?? this.matOrigin,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      date: date ?? this.date,
      price: price ?? this.price,
      matId: matId ?? this.matId,
      originId: docId ?? this.originId,
      matName: matName ?? this.matName,
      defQuantity: defQuantity ?? this.defQuantity,
    );
  }

  @override
  String toString() {
    return 'MatStatementItemModel(originId: $originId, matId: $matId, matName: $matName, amount: $quantity, matOriginType: ${matOrigin?.toJson()}, price: $price'
        ', date: $date, note: $note, defQuantity : $defQuantity)';
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([void _]) {
    return {
      PlutoColumn(hide: true, title: 'originId', field: 'originId', type: PlutoColumnType.text()):
          matOrigin?.originId ?? '',
      createAutoIdColumn(): '',
      PlutoColumn(title: 'التاريخ', field: 'التاريخ', type: PlutoColumnType.date()): date,
      PlutoColumn(title: 'فاتورة', field: 'فاتورة', type: PlutoColumnType.text()): originNameAndNumber,
      PlutoColumn(title: 'الكمية', field: 'الكمية', type: PlutoColumnType.number()): quantity,
      PlutoColumn(title: 'اسم المادة', field: 'اسم المادة', type: PlutoColumnType.text()): matName,
      PlutoColumn(title: 'السعر', field: 'السعر', type: PlutoColumnType.currency(name: 'AED')): price,
      PlutoColumn(title: 'البيان', field: 'البيان', type: PlutoColumnType.text()): note,
    };
  }

  String get originNameAndNumber {
    log('matOrigin!.originTypeId ${matOrigin!.originTypeId}');
    final originName = BillType.byTypeGuide(matOrigin!.originTypeId!).billPatternType.label;
    final originNumber = matOrigin!.originNumber!;

    return '$originName: $originNumber';
  }
}

class MatOrigin {
  /// Unique identifier for the bond entry, which is the same as the origin ID (e.g., billId).
  final String? originId;

  /// Refers to the origin entity type id of the bond entry (e.g., billTypeId for bills).
  final String? originTypeId;

  /// Refers to the type of the bond entry (bond, bill, cheque).
  final MatOriginType? originType;

  /// Refers to the number of origin of mat (billNumber).
  final int? originNumber;

  MatOrigin({
    this.originId,
    this.originTypeId,
    this.originType,
    this.originNumber,
  });

  factory MatOrigin.fromJson(Map<String, dynamic> json) {
    return MatOrigin(
      originId: json['originId'] as String?,
      originNumber: json['originNumber'] as int?,
      originTypeId: json['originTypeId'] as String?,
      originType: MatOriginType.byLabel(json['originType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originId': originId,
      'originNumber': originNumber,
      'originTypeId': originTypeId,
      'originType': originType?.label,
    };
  }

  MatOrigin copyWith({
    String? originId,
    int? originNumber,
    String? originTypeId,
    MatOriginType? originType,
  }) {
    return MatOrigin(
      originId: originId ?? this.originId,
      originNumber: originNumber ?? this.originNumber,
      originTypeId: originTypeId ?? this.originTypeId,
      originType: originType ?? this.originType,
    );
  }
}
