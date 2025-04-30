import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../accounts/data/models/account_model.dart';
import '../../bill/data/models/bill_model.dart';
import '../../bond/data/models/entry_bond_model.dart';
import '../../materials/data/models/materials/material_model.dart';
import '../../users_management/controllers/user_management_controller.dart';
import '../data/models/log_model.dart';

/// Type definition gor a generic function that creates a [LogModel]
///  from a specific data model (e.g., BillModel, AccountModel, etc.)
typedef LogModelCreator<T> = LogModel Function({
  required String userName,
  required T item,
  required LogEventType eventType,
  int? sourceNumber,
});

/// Map that holds model-specific log model factories
/// Each entry defines how to convert a specific type (T) into a LogModel
final Map<Type, LogModelCreator> _logModelFactories = {
  EntryBondModel: (
      {required String userName,
      required dynamic item,
      required LogEventType eventType,
      int? sourceNumber}) {
    if (sourceNumber == null) {
      throw ArgumentError("Source number is required for EntryBondModel");
    }

    return LogModel.fromEntryBondModel(
      userName: userName,
      entry: item as EntryBondModel,
      eventType: eventType,
      sourceNumber: sourceNumber,
    );
  },
  BillModel: (
      {required String userName,
      required dynamic item,
      required LogEventType eventType,
      int? sourceNumber}) {
    return LogModel.fromBillModel(
      userName: userName,
      bill: item as BillModel,
      eventType: eventType,
    );
  },
  AccountModel: (
      {required String userName,
      required dynamic item,
      required LogEventType eventType,
      int? sourceNumber}) {
    return LogModel.fromAccountModel(
      userName: userName,
      account: item as AccountModel,
      eventType: eventType,
    );
  },
  MaterialModel: (
      {required String userName,
      required dynamic item,
      required LogEventType eventType,
      int? sourceNumber}) {
    return LogModel.fromMaterialModel(
      userName: userName,
      material: item as MaterialModel,
      eventType: eventType,
    );
  },
};

/// A factory class responsible for creating LogModel instances dynamically
/// based on the model type (T) using appropriate factory function
class LogModelFactory {
  /// Creates a LogModel for the given [item] using its registered factory
  static LogModel create<T>(
      {required T item, required LogEventType eventType, int? sourceNumber}) {
    /// Get the username of the currently logged-in user
    final userName =
        read<UserManagementController>().loggedInUserModel!.userName!;

    // Lookup the corresponding factory for the given type T
    final factory = _logModelFactories[T];
    if (factory != null) {
      // If factory exists, create the log using it
      return factory(
          userName: userName,
          item: item,
          eventType: eventType,
          sourceNumber: sourceNumber);
    }

    // Throw if there's no factory registered for this type
    throw UnimplementedError(
        "No LogModel factory registered for type ${T.toString()}");
  }
}
