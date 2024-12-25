class OldUserModel {
  String? userId, userName, userPin, userRole, userSellerId, userStatus;
  List? userFaceId = [];
  List<DateTime>? userDateList = [];
  List<DateTime>? logInDateList = [];
  List<DateTime>? logOutDateList = [];
  List<int>? userTimeList = [];

  OldUserModel({
    this.userId,
    this.userName,
    this.userPin,
    this.userRole,
    this.userSellerId,
    this.userFaceId,
    this.userStatus,
    this.userTimeList,
    this.userDateList,
    this.logInDateList,
    this.logOutDateList,
  });

  Map<String, dynamic> toJson() {
    return {
      'docId': userId,
      'userSellerId': userSellerId,
      'userName': userName,
      'userPin': userPin,
      'userRole': userRole,
      "userFaceId": userFaceId,
      "userStatus": userStatus,
      "userTimeList": userTimeList,
      "userDateList": userDateList,
      "logOutDateList": logOutDateList,
      "logInDateList": logInDateList,
    };
  }

  factory OldUserModel.fromJson(Map<String, dynamic> json) {
    List<DateTime> userDateList = [];
    List<DateTime> logInDateList = [];
    List<DateTime> logOutDateList = [];
    List<int> userTimeList = [];
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

    if (json['userTimeList'] != null) {
      for (var element in (json['userTimeList'] as List<dynamic>)) {
        userTimeList.add(int.parse(element.toString()));
      }
    }

    return OldUserModel(
      userId: json['docId'],
      userSellerId: json['userSellerId'],
      userName: json['userName'],
      userPin: json['userPin'],
      userRole: json['userRole'],
      userFaceId: json['userFaceId'],
      userStatus: json['userStatus'],
      userTimeList: userTimeList,
      userDateList: userDateList,
      logInDateList: logInDateList,
      logOutDateList: logOutDateList,
    );
  }
}
