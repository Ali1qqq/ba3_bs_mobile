import 'dart:async';
import 'dart:developer';

import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:get/get.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/firebase/implementations/repos/listen_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../materials/data/models/materials/material_model.dart';
import '../../users_management/controllers/user_management_controller.dart';
import '../../users_management/data/models/user_model.dart';
import '../data/model/changes_model.dart';

/// Controller to manage and process changes streamed from a repository.
class ChangesController extends GetxController {
  /// Repository for listening to changes.
  final ListenDataSourceRepository<ChangesModel> _repository;

  /// Tracks the currently received change in real-time.
  final Rx<ChangesModel?> currentChange = Rx<ChangesModel?>(null);

  /// Stream subscription for listening to changes.
  late StreamSubscription<ChangesModel> _subscription;

  /// Constructor to initialize with a repository for listening to changes.
  ChangesController(this._repository);

  @override
  void onInit() {
    super.onInit();
    listenToChanges();
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }

  Future<void> createChangeDocument(String userId) async {
    final changesModel = ChangesModel(
      targetUserId: userId,
      changeItems: {},
    );

    // Call the repository to save the new change document
    final result = await _repository.save(changesModel);

    result.fold(
      (failure) => AppUIUtils.onFailure('فشل في حفظ التغيير: ${failure.message}'),
      (success) => AppUIUtils.onSuccess('تم حفظ التغيير بنجاح'),
    );
  }

  /// Starts listening to changes for the logged-in user.
  void listenToChanges() {
    final userManagementController = read<UserManagementController>();
    final UserModel? loggedInUserModel = userManagementController.loggedInUserModel;

    if (loggedInUserModel?.userId == null) {
      log("Error: Logged-in user or user ID is null.");
      return;
    }

    final result = _repository.listenDoc(loggedInUserModel!.userId!);

    result.fold(
      (failure) => log("Error subscribing to changes: ${failure.message}"),
      (documentStream) {
        _subscription = documentStream
            .distinct() // Avoid duplicate events.
            .listen(
              _processChange,
              onError: (error) => log("Error in stream subscription: $error"),
            );
      },
    );
  }

  /// Processes an incoming change from the stream.
  void _processChange(ChangesModel change) {
    try {
      currentChange.value = change;
      log("Processing change for current user: ${change.targetUserId}");
      log('change items: ${change.changeItems.length}');

      List<MaterialModel> materialsToSave = [];
      List<MaterialModel> materialsToDelete = [];
      List<MaterialModel> materialsToUpdate = [];

      // Iterate over the changeItems and classify each one
      change.changeItems.forEach((collection, changes) {
        for (final changeItem in changes) {
          _handleChangeItem(changeItem, materialsToSave, materialsToDelete, materialsToUpdate); // Collect items for update or delete
        }
      });

      // After processing all items, call saveMaterials and deleteMaterials to handle both
      saveMaterials(materialsToSave);
      deleteMaterials(materialsToDelete);
      updateMaterials(materialsToUpdate);

      deleteChanges(change);
    } catch (e, stack) {
      log("Error processing change: $e\n$stack");
    }
  }

  Future<void> deleteChanges(ChangesModel change) async {
    final result = await _repository.delete(change.targetUserId);

    result.fold(
      (failure) => AppUIUtils.onFailure('فشل في حذف التغييرات: ${failure.message}'),
      (success) => {},
    );
  }

  /// Determines how to process a specific change item based on its type and collection.
  void _handleChangeItem(ChangeItem changeItem, List<MaterialModel> materialsToSave, List<MaterialModel> materialsToDelete,
      List<MaterialModel> materialsToUpdate) {
    final targetCollection = changeItem.target.targetCollection;
    final changeType = changeItem.target.changeType;

    if (targetCollection == ChangeCollection.materials) {
      if (changeType == ChangeType.add) {
        _handleAddMaterial(changeItem, materialsToSave); // Add/Update goes to materialsToSave
      } else if (changeType == ChangeType.remove) {
        _handleDelete(changeItem, materialsToDelete); // Delete goes to materialsToDelete
      } else if (changeType == ChangeType.update) {
        _handleUpdateMaterial(changeItem, materialsToUpdate); // Delete goes to materialsToDelete
      }
    }
  }

  /// Handles an add or update operation for a specific change item.
  void _handleAddMaterial(ChangeItem changeItem, List<MaterialModel> materialsToSave) {
    // Assuming changeItem contains the required material data for saving
    MaterialModel material = _extractMaterialsFromChangeItem(changeItem);
    materialsToSave.add(material); // Add to the materials list for saving
    log("Add/Update operation for item(${changeItem.target.targetCollection}): ${changeItem.change}");
  }

  void _handleUpdateMaterial(ChangeItem changeItem, List<MaterialModel> materialsToUpdate) {
    // Assuming changeItem contains the required material data for saving
    MaterialModel material = _extractMaterialsFromChangeItem(changeItem);
    materialsToUpdate.add(material); // Update to the materials list for saving
    log("Add/Update operation for item(${changeItem.target.targetCollection}): ${changeItem.change}");
  }

  /// Extract and transform changeItem to a MaterialModel instance
  MaterialModel _extractMaterialsFromChangeItem(ChangeItem changeItem) => MaterialModel.fromJson(changeItem.change);

  /// Saves the materials after all change items have been processed.
  void saveMaterials(List<MaterialModel> materialsToSave) {
    if (materialsToSave.isNotEmpty) {
      final materialController = read<MaterialController>();
      materialController.saveAllMaterial(materialsToSave); // Save all materials at once
    }
  }

  /// Saves the materials after all change items have been processed.
  void updateMaterials(List<MaterialModel> materialsToUpdate) {
    if (materialsToUpdate.isNotEmpty) {
      final materialController = read<MaterialController>();
      materialController.updateAllMaterial(materialsToUpdate); // Save all materials at once
    }
  }

  /// Handles a delete operation for a specific change item.
  void _handleDelete(ChangeItem changeItem, List<MaterialModel> materialsToDelete) {
    // Assuming we need to handle deletions separately
    // We can add the material to the materialsToDelete list
    log("Delete operation for item(${changeItem.target.targetCollection}): ${changeItem.change}");
    MaterialModel materialToDelete = _extractMaterialsFromChangeItem(changeItem);
    materialsToDelete.add(materialToDelete); // Add to materialsToDelete
  }

  /// Deletes materials after all deletions have been processed.
  void deleteMaterials(List<MaterialModel> materialsToDelete) {
    if (materialsToDelete.isNotEmpty) {
      // Handle delete logic here
      final materialController = read<MaterialController>();
      materialController.deleteAllMaterial(materialsToDelete); // Save/delete all materials at once
    }
  }

  /// Updates the listener when the logged-in user changes.
  void updateListenerForNewUser(UserModel? newUser) {
    _subscription.cancel(); // Cancel the existing subscription.
    if (newUser?.userId != null) {
      listenToChanges();
    }
  }
}