import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:ba3_bs_mobile/core/helper/extensions/task_status_extension.dart';
import 'package:ba3_bs_mobile/core/utils/app_service_utils.dart';
import 'package:ba3_bs_mobile/features/pluto/data/models/pluto_adaptable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/widgets/pluto_auto_id_column.dart';
import '../../../user_task/data/model/user_task_model.dart';

class UserModel implements PlutoAdaptable {
  final String? userId;
  final String? userName;
  final String? userPassword;
  final String? userRoleId;
  final String? userSellerId;
  final String? loginDelay;
  final String? logoutDelay;
  final bool? haveHoliday;

  final UserWorkStatus? userWorkStatus;
  final UserActiveStatus? userActiveStatus;

  final List<String>? userHolidays;
  final List<UserTaskModel>? userTaskList;
  final Map<String, UserWorkingHours>? userWorkingHours;

  final Map<String, UserTimeModel>? userTimeModel;

  UserModel({
    this.userId,
    this.userName,
    this.userPassword,
    this.userRoleId,
    this.userSellerId,
    this.userTimeModel,
    this.userWorkStatus,
    this.userActiveStatus,
    this.userHolidays,
    this.userWorkingHours,
    this.haveHoliday,
    this.loginDelay,
    this.logoutDelay,
    this.userTaskList,
  });

  Map<String, dynamic> toJson() {
    return {
      'docId': userId,
      'userSellerId': userSellerId,
      'userName': userName,
      'userPassword': userPassword,
      'userRoleId': userRoleId,
      'userTaskList': userTaskList
          ?.map(
            (e) => e.toJson(),
          )
          .toList(),
      if (userActiveStatus != null) 'userActiveStatus': userActiveStatus?.label,
      if (userWorkStatus != null) 'userWorkStatus': userWorkStatus?.label,
      if (userHolidays != null) 'userHolidays': userHolidays?.toList(),
      if (userWorkingHours != null)
        'userWorkingHours': Map.fromEntries(userWorkingHours!.entries.map((e) => MapEntry(e.key, e.value.toJson())).toList()),
      if (userTimeModel != null) "userTime": Map.fromEntries(userTimeModel!.entries.map((e) => MapEntry(e.key, e.value.toJson())).toList()),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, UserTimeModel> userTimeModel = <String, UserTimeModel>{};

    (json['userTime'] ?? {}).forEach((k, v) {
      userTimeModel[k] = UserTimeModel.fromJson(v);
    });

    var sortedEntries = userTimeModel.entries.toList()..sort((a, b) => a.value.dayName!.compareTo(b.value.dayName!));

    userTimeModel = Map.fromEntries(sortedEntries);

    Map<String, UserWorkingHours> userDailyTime = <String, UserWorkingHours>{};

    (json['userWorkingHours'] ?? {}).forEach(
      (String workingHourId, dynamic userWorkingHourJson) {
        userDailyTime[workingHourId] = UserWorkingHours.fromJson(userWorkingHourJson);
      },
    );

    return UserModel(
      userId: json['docId'],
      userSellerId: json['userSellerId'],
      userName: json['userName'],
      userPassword: json['userPassword'],
      userRoleId: json['userRoleId'],
      userHolidays: List<String>.from(json['userHolidays'] ?? []),
      userWorkingHours: userDailyTime,
      userWorkStatus: UserWorkStatus.byLabel(json['userWorkStatus'] ?? UserWorkStatus.away.label),
      userActiveStatus: json['userActiveStatus'] != null ? UserActiveStatus.byLabel(json['userActiveStatus']) : UserActiveStatus.inactive,
      userTimeModel: userTimeModel,
      userTaskList: (json['userTaskList'] as List<dynamic>?)?.map((e) => UserTaskModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Creates a copy of this UserModel with updated fields.
  UserModel copyWith({
    final String? userId,
    final String? userName,
    final String? userPassword,
    final String? userRoleId,
    final String? userSellerId,
    final UserWorkStatus? userWorkStatus,
    final UserActiveStatus? userActiveStatus,
    final List<String>? userHolidays,
    final List<UserTaskModel>? userTaskList,
    final Map<String, UserTimeModel>? userTimeModel,
    final Map<String, UserWorkingHours>? userWorkingHours,
    final String? loginDelay,
    final String? logoutDelay,
    final bool? haveHoliday,
  }) =>
      UserModel(
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userPassword: userPassword ?? this.userPassword,
        userRoleId: userRoleId ?? this.userRoleId,
        userSellerId: userSellerId ?? this.userSellerId,
        userTimeModel: userTimeModel ?? this.userTimeModel,
        userWorkStatus: userWorkStatus ?? this.userWorkStatus,
        userActiveStatus: userActiveStatus ?? this.userActiveStatus,
        userHolidays: userHolidays ?? this.userHolidays,
        userWorkingHours: userWorkingHours ?? this.userWorkingHours,
        loginDelay: loginDelay ?? this.loginDelay,
        logoutDelay: logoutDelay ?? this.logoutDelay,
        haveHoliday: haveHoliday ?? this.haveHoliday,
        userTaskList: userTaskList ?? this.userTaskList,
      );

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    Color getStatusColor(String status) {
      return status == UserWorkStatus.online.label ? Colors.lightGreen : Colors.redAccent;
    }

    Widget buildStatusCell(String status) {
      return Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: getStatusColor(status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }

    bool hasHolidayToday() {
      return userHolidays?.contains(currentDate) ?? false;
    }

    return {
      PlutoColumn(
        title: AppStrings.identificationNumber.tr,
        field: AppConstants.userIdFiled,
        type: PlutoColumnType.text(),
        hide: true,
      ): userId,
      createAutoIdColumn(): '#',
      PlutoColumn(
        title: AppStrings.employeeName.tr,
        field: 'اسم الموظف',
        width: 200,
        frozen: PlutoColumnFrozen.start,
        type: PlutoColumnType.text(),
      ): userName,
      PlutoColumn(
        title: AppStrings.lastCheckInTime.tr,
        field: 'اخر دخول',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): hasHolidayToday()
          ? AppStrings.holiday.tr
          : AppServiceUtils.formatDateTimeFromString(AppServiceUtils.getLastLogin(userTimeModel)?.toIso8601String()),
      PlutoColumn(
        title: AppStrings.lastCheckOutTime.tr,
        field: 'اخر خروج',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): hasHolidayToday()
          ? AppStrings.holiday.tr
          : AppServiceUtils.formatDateTimeFromString(AppServiceUtils.getLastLogout(userTimeModel)?.toIso8601String()),
      PlutoColumn(
        title: AppStrings.holidaysForThisMonth.tr,
        field: 'عطل هذا الشهر',
        width: 400,
        renderer: (context) => Center(
          child: Text(
            context.cell.value.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): userHolidays?.where((date) => date.split("-")[1] == DateTime.now().month.toString().padLeft(2, '0')).toList().join(" , "),
      PlutoColumn(
        title: AppStrings.status.tr,
        field: 'الحالة',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        renderer: (context) => buildStatusCell(context.cell.value.toString()),
        type: PlutoColumnType.text(),
      ): hasHolidayToday() ? AppStrings.holiday.tr : userWorkStatus?.label,
      PlutoColumn(
        title: AppStrings.delayedEntry.tr,
        field: 'تأخير الدخول',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): AppServiceUtils.convertMinutesAndFormat((userTimeModel?.values.fold(
            0,
            (previousValue, element) => previousValue! + (element.totalLogInDelay ?? 0),
          ) ??
          0)),
      PlutoColumn(
        title: AppStrings.earlyExit.tr,
        field: 'الخروج المبكر',
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): AppServiceUtils.convertMinutesAndFormat((userTimeModel?.values.fold(
            0,
            (previousValue, element) => previousValue! + (element.totalOutEarlier ?? 0),
          ) ??
          0)),
      PlutoColumn(
        title: "${AppStrings.tasksEnded.tr} / ${AppStrings.tasksFailed}",
        field: AppStrings.tasks,
        width: 200,
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): "${userTaskList?.where((element) => element.status.isDone).length} /  ${userTaskList?.where((element) => element.status.isFailed).length}",
    };
  }
}

class UserWorkingHours {
  String? id;
  String? enterTime;
  String? outTime;

  UserWorkingHours({
    this.id,
    this.enterTime,
    this.outTime,
  });

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enterTime': enterTime,
      'outTime': outTime,
    };
  }

  // Create object from JSON
  factory UserWorkingHours.fromJson(Map<String, dynamic> json) {
    return UserWorkingHours(
      id: json['id'] as String?,
      enterTime: json['enterTime'] as String?,
      outTime: json['outTime'] as String?,
    );
  }

  // Create a copy of the object with modified fields
  UserWorkingHours copyWith({
    String? id,
    String? enterTime,
    String? outTime,
  }) {
    return UserWorkingHours(
      id: id ?? this.id,
      enterTime: enterTime ?? this.enterTime,
      outTime: outTime ?? this.outTime,
    );
  }
}

class UserTimeModel {
  final String? dayName;
  final List<DateTime>? logInDateList;
  final List<DateTime>? logOutDateList;
  int? totalLogInDelay;
  int? totalOutEarlier;

  UserTimeModel({
    this.dayName,
    this.logInDateList,
    this.logOutDateList,
    this.totalLogInDelay,
    this.totalOutEarlier,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayName': dayName,
      if (logInDateList != null) 'logInDateList': logInDateList!.map((e) => e.toIso8601String()).toList(),
      if (logOutDateList != null) 'logOutDateList': logOutDateList!.map((e) => e.toIso8601String()).toList(),
      if (totalLogInDelay != null) 'totalLogInDelay': totalLogInDelay,
      if (totalOutEarlier != null) 'totalOutEarlier': totalOutEarlier,
    };
  }

  factory UserTimeModel.fromJson(Map<String, dynamic> json) {
    return UserTimeModel(
      dayName: json['dayName'] as String?,
      totalLogInDelay: json['totalLogInDelay'] ?? 0,
      totalOutEarlier: json['totalOutEarlier'] ?? 0,
      logInDateList: (json['logInDateList'] as List<dynamic>?)?.map((e) => DateTime.parse(e as String)).toList(),
      logOutDateList: (json['logOutDateList'] as List<dynamic>?)?.map((e) => DateTime.parse(e as String)).toList(),
    );
  }

  UserTimeModel copyWith({
    String? dayName,
    List<DateTime>? logInDateList,
    List<DateTime>? logOutDateList,
    int? totalLogInDelay,
    int? totalOutEarlier,
  }) {
    return UserTimeModel(
      dayName: dayName ?? this.dayName,
      logInDateList: logInDateList ?? this.logInDateList,
      logOutDateList: logOutDateList ?? this.logOutDateList,
      totalLogInDelay: totalLogInDelay ?? this.totalLogInDelay,
      totalOutEarlier: totalOutEarlier ?? this.totalOutEarlier,
    );
  }

  UserTimeModel copyWithAddTime({
    int? totalLogInDelay,
    int? totalOutEarlier,
  }) {
    return UserTimeModel(
      dayName: dayName,
      logInDateList: logInDateList,
      logOutDateList: logOutDateList,
      totalLogInDelay: totalLogInDelay != null ? totalLogInDelay + (this.totalLogInDelay ?? 0) : this.totalLogInDelay,
      totalOutEarlier: totalOutEarlier != null ? totalOutEarlier + (this.totalOutEarlier ?? 0) : this.totalOutEarlier,
    );
  }
}

String get currentDate => DateTime.now().toString().split(" ")[0];