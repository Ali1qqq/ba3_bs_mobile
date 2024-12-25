class UserModel {
  final String? userId;
  final String? userName;
  final String? userPassword;
  final String? userRoleId;
  final String? userSellerId;
  final List<DateTime>? userDateList;

  final List<DateTime>? logInDateList;

  final List<DateTime>? logOutDateList;

  UserModel({
    this.userId,
    this.userName,
    this.userPassword,
    this.userRoleId,
    this.userSellerId,
    this.userDateList,
    this.logInDateList,
    this.logOutDateList,
  });

  Map<String, dynamic> toJson() {
    return {
      'docId': userId,
      'userSellerId': userSellerId,
      'userName': userName,
      'userPassword': userPassword,
      'userRoleId': userRoleId,
      "userDateList": userDateList,
      "logOutDateList": logOutDateList,
      "logInDateList": logInDateList,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<DateTime> userDateList = [];
    List<DateTime> logInDateList = [];
    List<DateTime> logOutDateList = [];

    if (json['userDateList'] != null) {
      for (var element in (json['userDateList'] as List<dynamic>)) {
        if (element.runtimeType == DateTime) {
          userDateList.add(element);
        } else {
          userDateList.add(element.toDate());
        }
      }
    }
    if (json['logInDateList'] != null) {
      for (var element in (json['logInDateList'] as List<dynamic>)) {
        if (element.runtimeType == DateTime) {
          logInDateList.add(element);
        } else {
          logInDateList.add(element.toDate());
        }
      }
    }
    if (json['logOutDateList'] != null) {
      for (var element in (json['logOutDateList'] as List<dynamic>)) {
        if (element.runtimeType == DateTime) {
          logOutDateList.add(element);
        } else {
          logOutDateList.add(element.toDate());
        }
      }
    }

    return UserModel(
      userId: json['docId'],
      userSellerId: json['userSellerId'],
      userName: json['userName'],
      userPassword: json['userPassword'],
      userRoleId: json['userRoleId'],
      userDateList: userDateList,
      logInDateList: logInDateList,
      logOutDateList: logOutDateList,
    );
  }

  /// Creates a copy of this UserModel with updated fields.
  UserModel copyWith({
    String? userId,
    String? userName,
    String? userPassword,
    String? userRoleId,
    String? userSellerId,
    List<DateTime>? userDateList,
    List<DateTime>? logInDateList,
    List<DateTime>? logOutDateList,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPassword: userPassword ?? this.userPassword,
      userRoleId: userRoleId ?? this.userRoleId,
      userSellerId: userSellerId ?? this.userSellerId,
      userDateList: userDateList ?? this.userDateList,
      logInDateList: logInDateList ?? this.logInDateList,
      logOutDateList: logOutDateList ?? this.logOutDateList,
    );
  }
}
