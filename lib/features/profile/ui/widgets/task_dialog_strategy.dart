import 'package:ba3_bs_mobile/features/profile/ui/widgets/sale_task_dialog.dart';
import 'package:ba3_bs_mobile/features/user_task/data/model/user_task_model.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/enums/enums.dart';
import 'general_task_dialog.dart';
import 'inventory_task_dialog.dart';

abstract class TaskDialogStrategy {
  Widget buildDialog(UserTaskModel task);
}

class InventoryTaskStrategy implements TaskDialogStrategy {
  @override
  Widget buildDialog(UserTaskModel task) {
    return InventoryTaskDialog(task: task);
  }
}

class SaleTaskStrategy implements TaskDialogStrategy {
  @override
  Widget buildDialog(UserTaskModel task) {
    return SaleTaskDialog(task: task);
  }
}

class GeneralTaskStrategy implements TaskDialogStrategy {
  @override
  Widget buildDialog(UserTaskModel task) {
    return GeneralTaskDialog(
      task: task,
    );
  }
}

class TaskDialogFactory {
  static TaskDialogStrategy getStrategy(TaskType taskType) {
    switch (taskType) {
      case TaskType.inventoryTask:
        return InventoryTaskStrategy();
      case TaskType.saleTask:
        return SaleTaskStrategy();
      default:
        return GeneralTaskStrategy();
    }
  }
}