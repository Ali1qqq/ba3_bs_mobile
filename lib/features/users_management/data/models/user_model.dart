import '../../../../core/helper/enums/enums.dart';

class UserModel {
  final String? userId;
  final String? userName;
  final String? userPassword;
  final String? userRoleId;
  final String? userSellerId;

  final UserStatus? userStatus;

  final List<String>? userHolidays;
  final Map<String, UserWorkingHours>? userWorkingHours;

  final Map<String, UserTimeModel>? userTimeModel;

  UserModel({
    this.userId,
    this.userName,
    this.userPassword,
    this.userRoleId,
    this.userSellerId,
    this.userTimeModel,
    this.userStatus,
    this.userHolidays,
    this.userWorkingHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'docId': userId,
      'userSellerId': userSellerId,
      'userName': userName,
      'userPassword': userPassword,
      'userRoleId': userRoleId,
      if (userStatus != null) 'userStatus': userStatus?.label,
      if (userHolidays != null) 'userHolidays': userHolidays?.toList(),
      if (userWorkingHours != null)
        'userWorkingHours':
            Map.fromEntries(userWorkingHours!.entries.map((e) => MapEntry(e.key, e.value.toJson())).toList()),
      if (userTimeModel != null)
        "userTime": Map.fromEntries(userTimeModel!.entries.map((e) => MapEntry(e.key, e.value.toJson())).toList()),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, UserTimeModel> userTimeModel = <String, UserTimeModel>{};
    (json['userTime'] ?? {}).forEach((k, v) {
      userTimeModel[k] = UserTimeModel.fromJson(v);
    });

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
      userStatus: UserStatus.byLabel(json['userStatus'] ?? UserStatus.away.label),
      userTimeModel: userTimeModel,
    );
  }

  /// Creates a copy of this UserModel with updated fields.
  UserModel copyWith({
    String? userId,
    String? userName,
    String? userPassword,
    String? userRoleId,
    String? userSellerId,
    UserStatus? userStatus,
    List<String>? userHolidays,
    Map<String, UserTimeModel>? userTimeModel,
    Map<String, UserWorkingHours>? userWorkingHours,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPassword: userPassword ?? this.userPassword,
      userRoleId: userRoleId ?? this.userRoleId,
      userSellerId: userSellerId ?? this.userSellerId,
      userTimeModel: userTimeModel ?? this.userTimeModel,
      userStatus: userStatus ?? this.userStatus,
      userHolidays: userHolidays ?? this.userHolidays,
      userWorkingHours: userWorkingHours ?? this.userWorkingHours,
    );
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

  UserTimeModel({
    this.dayName,
    this.logInDateList,
    this.logOutDateList,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayName': dayName,
      if (logInDateList != null) 'logInDateList': logInDateList!.map((e) => e.toIso8601String()).toList(),
      if (logOutDateList != null) 'logOutDateList': logOutDateList!.map((e) => e.toIso8601String()).toList(),
    };
  }

  factory UserTimeModel.fromJson(Map<String, dynamic> json) {
    return UserTimeModel(
      dayName: json['dayName'] as String?,
      logInDateList: (json['logInDateList'] as List<dynamic>?)?.map((e) => DateTime.parse(e as String)).toList(),
      logOutDateList: (json['logOutDateList'] as List<dynamic>?)?.map((e) => DateTime.parse(e as String)).toList(),
    );
  }

  UserTimeModel copyWith({
    String? dayName,
    List<DateTime>? logInDateList,
    List<DateTime>? logOutDateList,
  }) {
    return UserTimeModel(
      dayName: dayName ?? this.dayName,
      logInDateList: logInDateList ?? this.logInDateList,
      logOutDateList: logOutDateList ?? this.logOutDateList,
    );
  }
}
