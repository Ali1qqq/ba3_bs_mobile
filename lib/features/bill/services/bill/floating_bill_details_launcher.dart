import 'package:get/get.dart';

import '../../../../core/helper/mixin/controller_initializer.dart';
import '../../../../core/helper/mixin/floating_launcher.dart';
import '../../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../controllers/bill/bill_details_controller.dart';
import '../../controllers/bill/bill_search_controller.dart';
import '../../controllers/pluto/bill_details_pluto_controller.dart';
import '../../data/models/bill_model.dart';

/// Manages and initializes controllers for the Bill Details screen with floating window capabilities.
class FloatingBillDetailsLauncher extends GetxController with FloatingLauncher, ControllerInitializer {
  /// Initializes all required controllers for the Bill Details screen.
  Map<String, GetxController> setupControllers({required Map<String, dynamic> params}) {
    final tag = requireParam<String>(params, 'tag');

    final billDetailsPlutoController = requireParam<BillDetailsPlutoController>(params, 'billDetailsPlutoController');
    final billSearchController = requireParam<BillSearchController>(params, 'billSearchController');
    final billsFirebaseRepo = requireParam<DataSourceRepository<BillModel>>(params, 'billsFirebaseRepo');

    final billSearchControllerWithTag =
        getOrCreateController<BillSearchController>(tag, controllerBuilder: () => billSearchController);

    final billDetailsPlutoControllerWithTag =
        getOrCreateController<BillDetailsPlutoController>(tag, controllerBuilder: () => billDetailsPlutoController);

    final billDetailsControllerWithTag = getOrCreateController<BillDetailsController>(
      tag,
      controllerBuilder: () => BillDetailsController(
        billsFirebaseRepo,
        billDetailsPlutoController: billDetailsPlutoControllerWithTag,
        billSearchController: billSearchControllerWithTag,
      ),
    );

    return {
      'billDetailsController': billDetailsControllerWithTag,
      'billDetailsPlutoController': billDetailsPlutoControllerWithTag,
      'billSearchController': billSearchControllerWithTag,
    };
  }
}
