import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';

class UserModel {
  final String? userId;
  final String? userName;
  final String? userPassword;
  final String? userRoleId;
  final String? userSellerId;

  final UserStatus? userStatus;

  final Map<String, UserTimeModel>? userTimeModel;

  UserModel({
    this.userId,
    this.userName,
    this.userPassword,
    this.userRoleId,
    this.userSellerId,
    this.userTimeModel,
    this.userStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'docId': userId,
      'userSellerId': userSellerId,
      'userName': userName,
      'userPassword': userPassword,
      'userRoleId': userRoleId,
      'userStatus': userStatus!.label,
      "userTime": Map.fromEntries(userTimeModel!.entries.map((e) => MapEntry(e.key, e.value.toJson())).toList()),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, UserTimeModel> userTime = <String, UserTimeModel>{};
    (json['userTime'] ?? {}).forEach((k, v) {
      userTime[k] = UserTimeModel.fromJson(v);
    });
    return UserModel(
      userId: json['docId'],
      userSellerId: json['userSellerId'],
      userName: json['userName'],
      userPassword: json['userPassword'],
      userRoleId: json['userRoleId'],
      userStatus: UserStatus.byLabel(json['userStatus'] ?? UserStatus.away.label),
      userTimeModel: userTime,
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
    Map<String, UserTimeModel>? userTimeModel,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPassword: userPassword ?? this.userPassword,
      userRoleId: userRoleId ?? this.userRoleId,
      userSellerId: userSellerId ?? this.userSellerId,
      userTimeModel: userTimeModel ?? this.userTimeModel,
      userStatus: userStatus ?? this.userStatus,
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
