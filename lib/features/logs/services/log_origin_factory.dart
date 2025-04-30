import '../data/models/log_model.dart';

/// Enum representing the origin/source type of a log entry.
enum LogOrigin { bill, cheque, bond, material, account }

/// Factory class to resolve the LogOrigin based on the content of a LogModel.
class LogOriginFactory {
  /// Determines the LogOrigin type from a given [log]
  static LogOrigin resolve(LogModel log) {
    final sourceType = log.sourceType;
    final note = log.note;

    if (sourceType.contains('فاتورة') ||
        sourceType.contains('تسوية') ||
        note.contains('بضاعة أول المدة')) {
      return LogOrigin.bill;
    } else if (sourceType.contains('شيكات')) {
      return LogOrigin.cheque;
    } else if (sourceType.contains('سند') ||
        sourceType.contains('القيد الافتتاحي')) {
      return LogOrigin.bond;
    } else if (sourceType.contains('مادة') ||
        note.contains('مادة') ||
        note.contains('الباركود')) {
      return LogOrigin.material;
    } else if (sourceType.contains('حساب') || note.contains('حساب')) {
      return LogOrigin.account;
    } else {
      throw UnimplementedError(
          "No LogOrigin registered for source type ${log.sourceType}");
    }
  }
}
