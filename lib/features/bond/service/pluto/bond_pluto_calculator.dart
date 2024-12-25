import 'package:ba3_bs_mobile/core/i_controllers/i_pluto_controller.dart';
import 'package:pluto_grid/pluto_grid.dart';

class BillPlutoCalculator {
  final IPlutoController controller;

  BillPlutoCalculator(this.controller);

  PlutoGridStateManager get mainTableStateManager => controller.recordsTableStateManager;
}
