import '../helper/enums/enums.dart';

String generateId(RecordType recordType) {
  var epoch = DateTime.now().microsecondsSinceEpoch.toString();
  switch (recordType) {
    case RecordType.bond:
      return "bon$epoch";
    case RecordType.invoice:
      return "inv$epoch";
    case RecordType.product:
      return "prod$epoch";
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
