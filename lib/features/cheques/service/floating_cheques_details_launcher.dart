import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import 'package:get/get.dart';

import '../../../../core/helper/mixin/controller_initializer.dart';

import '../controllers/cheques/cheques_details_controller.dart';
import '../controllers/cheques/cheques_search_controller.dart';
import '../data/models/cheques_model.dart';

class FloatingChequesDetailsLauncher extends GetxController with FloatingLauncher, ControllerInitializer {
  /// Initializes and manages controllers for the Cheques Details screen with floating window capabilities.
  Map<String, GetxController> setupControllers({required Map<String, dynamic> params}) {
    final tag = requireParam<String>(params, 'tag');

    final chequesType = requireParam<ChequesType>(params, 'chequesType');

    final chequesSearchController = requireParam<ChequesSearchController>(params, 'chequesSearchController');
    final chequesFirebaseRepo = requireParam<CompoundDatasourceRepository<ChequesModel, ChequesType>>(params, 'chequesFirebaseRepo');

    final chequesSearchControllerWithTag =
        getOrCreateController<ChequesSearchController>(tag, controllerBuilder: () => chequesSearchController);

    final chequesDetailsControllerWithTag = getOrCreateController<ChequesDetailsController>(
      tag,
      controllerBuilder: () => ChequesDetailsController(
        chequesFirebaseRepo,
        chequesSearchController: chequesSearchControllerWithTag,
        chequesType: chequesType,
      ),
    );

    return {
      'chequesDetailsController': chequesDetailsControllerWithTag,
      'chequesSearchController': chequesSearchControllerWithTag,
    };
  }
}

// [GETX] "ChequesDetailsControllerChequesController_[#5de9f]" onDelete() called
// [GETX] "ChequesDetailsControllerChequesController_[#5de9f]" deleted from memory
// [GETX] "ChequesDetailsPlutoControllerChequesController_[#5de9f]" onDelete() called
// [GETX] "ChequesDetailsPlutoControllerChequesController_[#5de9f]" deleted from memory
// [GETX] "ChequesSearchControllerChequesController_[#5de9f]" onDelete() called
// [GETX] "ChequesSearchControllerChequesController_[#5de9f]" deleted from memory
// [GETX] "FloatingWindowController" deleted from memory
