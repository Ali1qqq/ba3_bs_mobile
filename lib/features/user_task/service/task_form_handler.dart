import 'package:ba3_bs_mobile/features/user_task/data/model/user_task_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/validators/app_validator.dart';

class TaskFormHandler with AppValidator {
  final formKey = GlobalKey<FormState>();
  TextEditingController titleTextEditingController = TextEditingController();
  TextEditingController materialTextController = TextEditingController();
  Rx<DateTime> dueDate = DateTime.now().obs;
  Rx<DateTime> updateDate = DateTime.now().obs;
  Rx<DateTime> createDate = DateTime.now().obs;
  Rx<TaskStatus> selectedStatus = TaskStatus.initial.obs;
  Rx<TaskType> selectedTaskType = TaskType.generalTask.obs;
  List<String> selectedUsers = [];
  List<MaterialTaskModel> materialTaskList = [];

  void init({UserTaskModel? userTaskModel}) {
    if (userTaskModel != null) {
      titleTextEditingController.text = userTaskModel.title!;

      dueDate.value = userTaskModel.dueDate!;
      updateDate.value = userTaskModel.updatedAt ?? DateTime.now();
      createDate.value = userTaskModel.createdAt!;
      selectedStatus = userTaskModel.status!.obs;
      selectedTaskType = userTaskModel.taskType!.obs;
      selectedUsers.assignAll(userTaskModel.assignedTo!);
      materialTaskList.assignAll(userTaskModel.materialTask!);
    } else {
      clear();
    }
  }

  void clear() {
    titleTextEditingController.clear();
    materialTextController.clear();
    dueDate = DateTime.now().obs;
    updateDate = DateTime.now().obs;
    createDate = DateTime.now().obs;
    selectedStatus = TaskStatus.initial.obs;
    selectedTaskType = TaskType.generalTask.obs;
    selectedUsers.clear();
    materialTaskList.clear();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void setTaskStatus(TaskStatus value) {
    selectedStatus.value = value;
  }

  void setTaskType(TaskType value) {
    selectedTaskType.value = value;
  }

  void setDueDate(DateTime date) {
    dueDate.value = date;
  }

  void setCreateDate(DateTime date) {
    createDate.value = date;
  }
}