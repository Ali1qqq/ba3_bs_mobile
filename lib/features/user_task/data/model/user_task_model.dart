import 'package:ba3_bs_mobile/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/widgets/pluto_auto_id_column.dart';

class UserTaskModel implements PlutoAdaptable {
  String? docId;
  String? title;
  List<MaterialTaskModel>? materialTask;
  DateTime? dueDate;
  TaskStatus? status;
  List<String>? assignedTo;
  String? assignedBy;
  TaskType? taskType;
  String? taskImage;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? endedAt;

  UserTaskModel({
    this.docId,
    this.title,
    this.materialTask,
    this.dueDate,
    this.status,
    this.assignedTo,
    this.assignedBy,
    this.taskType,
    this.taskImage,
    this.createdAt,
    this.updatedAt,
    this.endedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'title': title,
      'materialTask': materialTask?.map((item) => item.toJson()).toList(),
      'dueDate': dueDate,
      'status': status?.value,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'taskType': taskType?.label,
      'taskImage': taskImage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'endedAt': endedAt,
    };
  }

  factory UserTaskModel.fromJson(Map<String, dynamic> json) {
    return UserTaskModel(
      docId: json['docId'] as String?,
      title: json['title'] as String?,
      materialTask: json['materialTask'] == null
          ? []
          : (json['materialTask'] as List<dynamic>).map((materialTaskJson) => MaterialTaskModel.fromJson(materialTaskJson)).toList(),
      dueDate: AppServiceUtils.convertToDateTime(json['dueDate']),
      status: TaskStatus.byValue(json['status'] ?? ''),
      assignedTo: (json['assignedTo'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      assignedBy: json['assignedBy'] as String?,
      taskType: TaskType.byValue(json['taskType'] ?? ''),
      // json['taskType'] as String?,
      taskImage: json['taskImage'] as String?,
      createdAt: AppServiceUtils.convertToDateTime(json['createdAt']),
      updatedAt: AppServiceUtils.convertToDateTime(json['updatedAt']),
      endedAt: AppServiceUtils.convertToDateTime(json['endedAt']),
    );
  }

  UserTaskModel copyWith({
    String? docId,
    String? title,
    List<MaterialTaskModel>? materialTask,
    DateTime? dueDate,
    TaskStatus? status,
    List<String>? assignedTo,
    String? assignedBy,
    TaskType? taskType,
    String? taskImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? endedAt,
  }) {
    return UserTaskModel(
      docId: docId ?? this.docId,
      title: title ?? this.title,
      materialTask: materialTask ?? this.materialTask,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      taskType: taskType ?? this.taskType,
      taskImage: taskImage ?? this.taskImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  String toString() {
    return 'UserTaskModel(docId: $docId, title: $title, materialTask: ${materialTask?.map(
              (e) => e.toJson(),
            ).toList()}, '
        'dueDate: $dueDate, status: $status, assignedTo: $assignedTo, assignedBy: $assignedBy, '
        'taskType: $taskType, taskImage: $taskImage, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    return {
      PlutoColumn(
        title: AppStrings.identificationNumber.tr,
        field: AppConstants.userTaskIdField,
        type: PlutoColumnType.text(),
        hide: true,
      ): docId,
      createAutoIdColumn(): '#',
      PlutoColumn(
        title: AppStrings.taskTitle.tr,
        field: 'عنوان المهمة',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): title,
      PlutoColumn(
        title: AppStrings.assignedBy.tr,
        field: 'اضيفت من قبل',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): read<UserManagementController>().getUserNameById(assignedBy!),
      PlutoColumn(
        title: AppStrings.assignedTo.tr,
        field: 'اضيفت الى',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): assignedTo
          ?.map(
            (e) => read<UserManagementController>().getUserNameById(e),
          )
          .join(' -- '),
      PlutoColumn(
        title: AppStrings.materialInTask.tr,
        field: 'مواد الجرد',
        width: 400,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): materialTask
          ?.map(
            (e) => "${e.materialName!} (${e.quantity}/${e.quantityInTask})",
          )
          .join(
            ' \\_/ ',
          ),
      PlutoColumn(
        title: AppStrings.createdDate.tr,
        field: 'تاريخ الانشاء',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.date(),
      ): createdAt,
      PlutoColumn(
        title: AppStrings.taskDeadline.tr,
        field: 'تاريخ التسليم',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.date(),
      ): dueDate,
      PlutoColumn(
        title: AppStrings.status.tr,
        field: 'الحالة',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): status?.value,
      PlutoColumn(
        title: AppStrings.taskType.tr,
        field: 'نوع المهمة',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): taskType?.label,
      PlutoColumn(
        title: AppStrings.updatedAt,
        field: 'تاريخ التعديل',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): updatedAt,
      PlutoColumn(
        title: AppStrings.endedDate.tr,
        field: AppStrings.endedDate,
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): endedAt,
    };
  }
}

class MaterialTaskModel {
  String? docId;
  String? materialName;
  int? quantity;
  int? quantityInTask;

  MaterialTaskModel({
    this.docId,
    this.materialName,
    this.quantity,
    this.quantityInTask,
  });

  Map<String, dynamic> toJson() {
    return {
      'docId': docId,
      'materialName': materialName,
      'quantity': quantity,
      'quantityInTask': quantityInTask,
    };
  }

  factory MaterialTaskModel.fromJson(Map<String, dynamic> json) {
    return MaterialTaskModel(
      docId: json['docId'] as String?,
      materialName: json['materialName'] as String?,
      quantity: json['quantity'] as int?,
      quantityInTask: json['quantityInTask'] as int?,
    );
  }

  MaterialTaskModel copyWith({
    String? docId,
    String? materialName,
    int? quantity,
    int? quantityInTask,
  }) {
    return MaterialTaskModel(
      docId: docId ?? this.docId,
      materialName: materialName ?? this.materialName,
      quantity: quantity ?? this.quantity,
      quantityInTask: quantityInTask ?? this.quantityInTask,
    );
  }

  @override
  String toString() {
    return 'MaterialTaskModel(docId: $docId, materialName: $materialName, quantity: $quantity, quantityInTask: $quantityInTask)';
  }
}