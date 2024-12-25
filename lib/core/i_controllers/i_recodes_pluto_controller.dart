import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IRecodesPlutoController<T> extends GetxController {
  /// Main table's state manager.
  PlutoGridStateManager get recordsTableStateManager;

  /// Generates a list of invoice records from the table data.
  List<T> get generateRecords;
}
