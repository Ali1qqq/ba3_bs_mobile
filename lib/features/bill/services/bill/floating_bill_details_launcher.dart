import 'package:get/get.dart';

import '../../../../core/helper/mixin/controller_initializer.dart';
import '../../../../core/helper/mixin/floating_launcher.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import '../../../materials/data/models/materials/material_model.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/bill_details_controller.dart';
import '../../controllers/bill/bill_search_controller.dart';
import '../../controllers/pluto/bill_details_pluto_controller.dart';
import '../../data/models/bill_model.dart';

/// Manages and initializes controllers for the Bill Details screen with floating window capabilities.
class FloatingBillDetailsLauncher extends GetxController with FloatingLauncher, ControllerInitializer {
  /// Initializes all required controllers for the Bill Details screen.
  Map<String, GetxController> setupControllers({required Map<String, dynamic> params}) {
    final tag = requireParam<String>(params, key: 'tag');

    final billTypeModel = requireParam<BillTypeModel>(params, key: 'billTypeModel');

    final billsFirebaseRepo = requireParam<CompoundDatasourceRepository<BillModel, BillTypeModel>>(params, key: 'billsFirebaseRepo');

    final serialNumbersRepo = requireParam<QueryableSavableRepository<SerialNumberModel>>(params, key: 'serialNumbersRepo');

    final billSearchControllerWithTag = createController<BillSearchController>(tag, controller: BillSearchController());

    final billDetailsPlutoControllerWithTag =
    createController<BillDetailsPlutoController>(tag, controller: BillDetailsPlutoController(billTypeModel));

    final billDetailsControllerWithTag = createController<BillDetailsController>(
      tag,
      controller: BillDetailsController(
        billsFirebaseRepo,
        serialNumbersRepo,
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
