import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../helper/enums/enums.dart';

String generateId(RecordType recordType) {
  var epoch = DateTime
      .now()
      .microsecondsSinceEpoch
      .toString();
  switch (recordType) {
    case RecordType.bond:
      return "bon$epoch";
    case RecordType.bills:
      return "bil$epoch";
    case RecordType.material:
      return "mat$epoch";
    case RecordType.account:
      return "acc$epoch";
    case RecordType.pattern:
      return "pat$epoch";
    case RecordType.store:
      return "store$epoch";
    case RecordType.cheque:
      return "cheq$epoch";
    case RecordType.costCenter:
      return "CoCe$epoch";
    case RecordType.sellers:
      return "seller$epoch";
    case RecordType.user:
      return "user$epoch";
    case RecordType.role:
      return "role$epoch";
    case RecordType.task:
      return "task$epoch";
    case RecordType.inventory:
      return "inventory$epoch";
    case RecordType.entryBond:
      return "entryBond$epoch";
    case RecordType.accCustomer:
      return "accCustomer$epoch";
    case RecordType.warrantyInv:
      return "warrantyInv$epoch";
    case RecordType.changes:
      return "changes$epoch";
    case RecordType.fProduct:
      return "fProduct$epoch";
    case RecordType.undefined:
      return epoch;
  }
}

PlutoColumn buildPlutoColumn({
  required String title,
  required String field,
  required PlutoColumnType type,
  double width = 150,
  bool isReadOnly = false,
  bool isEditable = true,
  bool hasContextMenu = true,
  bool isResizable = true,
  bool isFullyHidden = false,
  bool isUIHidden = false,
  bool Function(PlutoRow, PlutoCell)? readOnlyCondition,
  Widget Function(PlutoColumnRendererContext)? customRenderer,
}) =>
    PlutoColumn(
      title: title,
      field: field,
      type: type,
      width: isUIHidden ? 0 : width,
      readOnly: isUIHidden ? true : isReadOnly,
      enableEditingMode: isUIHidden ? false : isEditable,
      enableContextMenu: isUIHidden ? false : hasContextMenu,
      enableDropToResize: isUIHidden ? false : isResizable,
      hide: isFullyHidden,
      checkReadOnly: readOnlyCondition,
      renderer: customRenderer,
    );
