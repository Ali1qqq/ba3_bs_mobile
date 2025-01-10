import 'dart:developer';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/firebase/implementations/repos/listen_datasource_repo.dart';
import '../../users_management/controllers/user_management_controller.dart';
import '../../users_management/data/models/user_model.dart';

import '../data/model/changes_model.dart';

class ChangesController extends GetxController {
  final ListenDataSourceRepository<ChangesModel> _repository;

  final Rx<ChangesModel?> currentChange = Rx<ChangesModel?>(null);

  ChangesController(this._repository);

  void listenToChanges() {
    UserModel loggedInUserModel = read<UserManagementController>().loggedInUserModel!;

    final result = _repository.listenDoc(loggedInUserModel.userId!);

    result.fold(
      (failure) {
        log("Error subscribing to changes: ${failure.message}");
      },
      (documentStream) {
        documentStream.listen(
          (change) {
            currentChange.value = change;
            log("Change ID: ${change.changeId}");

            if (change.changeCollection == ChangeCollection.bills) {
              if (change.changeType == ChangeType.addOrUpdate) {
                handleAddOrUpdate(change);
              } else {
                handleDelete(change);
              }
            }
          },
          onError: (error) {
            log("Error in stream subscription: $error");
          },
        );
      },
    );
  }

  void handleAddOrUpdate(ChangesModel change) {
    // Handle add/update logic
  }

  void handleDelete(ChangesModel change) {
    // Handle delete logic
  }
}
