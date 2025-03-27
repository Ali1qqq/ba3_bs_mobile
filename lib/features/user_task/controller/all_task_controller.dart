import 'dart:developer';

import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/task_status_extension.dart';
import 'package:ba3_bs_mobile/core/styling/app_colors.dart';
import 'package:ba3_bs_mobile/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs_mobile/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs_mobile/features/materials/data/models/materials/material_model.dart';
import 'package:ba3_bs_mobile/features/user_task/service/task_form_handler.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/dialogs/material_task_count_dialog.dart';
import '../../../core/dialogs/product_selection_dialog_content.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/services/firebase/implementations/repos/uploader_storage_queryable_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../users_management/data/models/user_model.dart';
import '../data/model/user_task_model.dart';
import '../ui/add_task_screen.dart';
import '../ui/all_task_screen.dart';

class AllTaskController extends GetxController with FloatingLauncher {
  final UploaderStorageQueryableRepo<UserTaskModel> _userTaskRepo;

  AllTaskController(this._userTaskRepo);

  late TaskFormHandler taskFormHandler;

  @override
  void onInit() {
    super.onInit();
    initPage();
  }

  initPage() {
    fetchTasks();
    taskFormHandler = TaskFormHandler();
    taskFormHandler.init();
  }

  bool get isNewTask => selectedTask?.docId == null;

  final _userManagementController = read<UserManagementController>();

  UserTaskModel? selectedTask;

  List<UserTaskModel> userTaskList = [];

  Future<void> fetchTasks() async {
    final result = await _userTaskRepo.getAll();
    log('fetchTasks');
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (tasks) {
        log('tasks ${tasks.length}');
        userTaskList.assignAll(tasks);
      },
    );
  }

  List<UserModel> get userList => _userManagementController.allUsers;

  bool isTaskLoading = false;

  void updatedSelectedUsers(String userId, bool value) {
    if (taskFormHandler.selectedUsers.contains(userId)) {
      taskFormHandler.selectedUsers.remove(userId);
    } else {
      taskFormHandler.selectedUsers.add(userId);
    }
    update();
  }

  bool checkUserStatus(String userId) {
    if (taskFormHandler.selectedUsers.contains(userId)) {
      return true;
    } else {
      return false;
    }
  }

  void selectOrDeselectAllUsers() {
    if (taskFormHandler.selectedUsers.isEmpty) {
      taskFormHandler.selectedUsers.addAll(userList.map((e) => e.userId!));
    } else {
      taskFormHandler.selectedUsers.clear();
    }
    update();
  }

  /// Adds a material to the list after selection and quantity input
  void addMaterialToList(BuildContext context) async {
    final materialController = read<MaterialController>();
    final searchedMaterials = materialController.searchOfProductByText(taskFormHandler.materialTextController.text);

    // Show failure message if no materials found
    if (searchedMaterials.isEmpty) {
      AppUIUtils.onFailure('لا يوجد مواد بهذا الاسم');
      return;
    }

    // Handle material selection (if multiple options exist)
    final selectedMaterial = await _handleMultipleMaterialsSelection(context, searchedMaterials);
    if (selectedMaterial == null) {
      AppUIUtils.onFailure('يرجى اختيار مادة');
      return;
    }
    if (!context.mounted) return;
    // Prompt the user for material quantity
    final quantity = await _getMaterialQuantity(context, selectedMaterial);
    if (quantity == null || quantity == 0) {
      AppUIUtils.onFailure('يرجى ادخال الكمية');
      return;
    }

    // Update material list with selected material and quantity
    _updateMaterialList(selectedMaterial, quantity);
    taskFormHandler.materialTextController.clear();
    update();
  }

  /// Handles selection of material if multiple options exist
  Future<MaterialModel?> _handleMultipleMaterialsSelection(BuildContext context, List<MaterialModel> searchedMaterials) async {
    if (searchedMaterials.length == 1) return searchedMaterials.first;

    final materialTextEditingController = TextEditingController();
    MaterialModel? selectedMaterial;

    await OverlayService.showDialog(
      context: context,
      height: .7.sh,
      width: .8.sw,
      content: ProductSelectionDialogContent(
        searchedMaterials: searchedMaterials,
        onRowSelected: (PlutoGridOnSelectedEvent onSelectedEvent) {
          // Retrieve selected material ID
          final materialId = onSelectedEvent.row?.cells[AppConstants.materialIdFiled]?.value;
          selectedMaterial = read<MaterialController>().getMaterialById(materialId);
          OverlayService.back();
        },
        onSubmitted: (_) async {},
        productTextController: materialTextEditingController,
      ),
      onCloseCallback: () => log('Product Selection Dialog Closed.'),
    );

    return selectedMaterial;
  }

  /// Prompts the user to enter the quantity of the selected material
  Future<int?> _getMaterialQuantity(BuildContext context, MaterialModel selectedMaterial) async {
    final materialTextEditingController = TextEditingController();

    if (!context.mounted) return null;

    await OverlayService.showDialog(
      context: context,
      height: 150,
      color: AppColors.backGroundColor,
      content: MaterialTaskCountDialog(
        searchedMaterials: [selectedMaterial],
        materialTextEditingController: materialTextEditingController,
      ),
    );

    return int.tryParse(materialTextEditingController.text);
  }

  /// Updates the material list by either adding a new material or updating the quantity of an existing one
  void _updateMaterialList(MaterialModel material, int quantity) {
    final docId = material.id!;
    int index = taskFormHandler.materialTaskList.indexWhere((m) => m.docId == docId);

    if (index != -1) {
      // Update existing material quantity
      taskFormHandler.materialTaskList[index] = taskFormHandler.materialTaskList[index].copyWith(
        quantity: (taskFormHandler.materialTaskList[index].quantity ?? 0) + quantity,
      );
      log("🔹 تم تحديث الكمية للمادة ذات ID: $docId إلى ${taskFormHandler.materialTaskList[index].quantity}");
    } else {
      // Add new material to the list
      taskFormHandler.materialTaskList.add(MaterialTaskModel(
        docId: docId,
        quantity: quantity,
        materialName: material.matName,
      ));
      log("✅ تم إضافة مادة جديدة ذات ID: $docId بكمية: $quantity");
    }
  }

  void removeMaterialFromList(int index) {
    taskFormHandler.materialTaskList.removeAt(index);
    update();
  }

  saveOrUpdateTask() async {
    if (!taskFormHandler.validate()) return;
    if (taskFormHandler.selectedUsers.isEmpty) {
      AppUIUtils.onFailure(AppStrings.pleaseAddUsers.tr);
      return;
    }

    late UserTaskModel userTaskModel;

    List<String> differentUser = [];
    if (selectedTask != null) {
      differentUser = taskFormHandler.selectedUsers.subtract(
        selectedTask!.assignedTo!,
        (p0) => p0,
      );
      differentUser.addAll(selectedTask!.assignedTo!.subtract(
        taskFormHandler.selectedUsers,
        (p0) => p0,
      ));

      userTaskModel = selectedTask!.copyWith(
        title: taskFormHandler.titleTextEditingController.text,
        assignedBy: read<UserManagementController>().loggedInUserModel!.userId,
        assignedTo: taskFormHandler.selectedUsers,
        createdAt: taskFormHandler.createDate.value,
        dueDate: taskFormHandler.dueDate.value,
        materialTask: taskFormHandler.materialTaskList,
        status: taskFormHandler.selectedStatus.value,
        taskType: taskFormHandler.selectedTaskType.value,
      );
    } else {
      differentUser.assignAll(taskFormHandler.selectedUsers);
      userTaskModel = UserTaskModel(
        title: taskFormHandler.titleTextEditingController.text,
        assignedBy: read<UserManagementController>().loggedInUserModel!.userId,
        assignedTo: taskFormHandler.selectedUsers,
        createdAt: taskFormHandler.createDate.value,
        dueDate: taskFormHandler.dueDate.value,
        materialTask: taskFormHandler.materialTaskList,
        status: taskFormHandler.selectedStatus.value,
        taskType: taskFormHandler.selectedTaskType.value,
      );
    }
    final result = await _userTaskRepo.save(userTaskModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (task) {
        read<UserManagementController>().addTaskToUser(task, differentUser);
        setSelectedTask(task);
        addOrUpdateTaskToList(task);
        return AppUIUtils.onSuccess('تم حفظ المهمة بنجاح');
      },
    );
  }

  void addOrUpdateTaskToList(UserTaskModel task) {
    // Check if task already exists in the list
    int index = userTaskList.indexWhere((t) => t.docId == task.docId);

    if (index != -1) {
      // If task exists, update it
      userTaskList[index] = task;
      log("🔄 تم تحديث المهمة ذات ID: ${task.docId}");
    } else {
      // If task does not exist, add it
      userTaskList.add(task);
      log("✅ تم إضافة مهمة جديدة ذات ID: ${task.docId}");
    }

    update(); // Notify UI about the change if using GetX
  }

  setSelectedTask(UserTaskModel? userTaskModel) {
    selectedTask = userTaskModel;
    taskFormHandler.init(userTaskModel: userTaskModel);
    update();
  }

  void lunchAddTaskScreen({required BuildContext context, String? userTaskId}) {
    setSelectedTask(userTaskList.firstWhereOrNull(
      (userTask) => userTask.docId == userTaskId,
    ));

    launchFloatingWindow(context: context, floatingScreen: AddTaskScreen());
    fetchTasks();
  }

  void lunchAllTaskScreen({required BuildContext context, String? userTaskId}) {
    fetchTasks();
    launchFloatingWindow(context: context, floatingScreen: AllTaskScreen());

    // taskFormHandler.init(userTaskModel: userTaskModel);
  }

  void deleteTask() async {
    final result = await _userTaskRepo.delete(selectedTask!.docId!);

    result.fold((failure) => AppUIUtils.onFailure(failure.message), (_) {
      userTaskList.removeWhere((userTask) => userTask.docId == selectedTask?.docId);
      read<UserManagementController>().addTaskToUser(selectedTask!, selectedTask!.assignedTo!);

      setSelectedTask(null);
      update();
      AppUIUtils.onSuccess('تم حذف المهمة بنجاح');
    });
  }

  Future<UserTaskModel> getTaskById(String id) async {
    if (userTaskList.isEmpty) {
      await fetchTasks();
    }
    return userTaskList.firstWhere((element) {
      return element.docId == id;
    });
  }

  UserTaskModel getTaskModelById(String id) {
    return userTaskList.firstWhere((element) {
      return element.docId == id;
    });
  }

  updateTask(UserTaskModel task) async {
    final result = await _userTaskRepo.save(task);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (task) {
        setSelectedTask(task);
        addOrUpdateTaskToList(task);
        return AppUIUtils.onSuccess('تم حفظ المهمة بنجاح');
      },
    );
  }

  Future<String> uploadImageTask(String imagePath) async {
    String imgUrl = '';
    final result = await _userTaskRepo.uploadImage(imagePath);

    result.fold((failure) => AppUIUtils.onFailure(failure.message), (imageUrl) async {
      imgUrl = imageUrl;
    });
    return imgUrl;
  }

  void uploadDateTask({required UserTaskModel task, required DateTime date, required TaskStatus status}) async {
    final updatedTask = status.isFinished ? task.copyWith(status: status, endedAt: date) : task.copyWith(status: status, updatedAt: date);
    await updateTask(updatedTask);
  }
}