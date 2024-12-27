import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class UserTimeServices {
  DateTime getCurrentTime() => Timestamp.now().toDate();

  String getCurrentDayName() => getCurrentTime().toString().split(" ")[0];

  // add user logIn time
  UserModel addLoginTimeToUserModel({required UserModel userModel}) {
// Check if the current day exists in userTimeModel
    if (userModel.userTimeModel![getCurrentDayName()] != null) {
      userModel.userTimeModel![getCurrentDayName()] = userModel.userTimeModel![getCurrentDayName()]!.copyWith(
        logInDateList: [
          ...(userModel.userTimeModel![getCurrentDayName()]!.logInDateList ?? []), // Merge the old list with the new date
          getCurrentTime(),
        ],
      );
    } else {
      userModel.userTimeModel![getCurrentDayName()] = UserTimeModel(
        dayName: getCurrentDayName(),
        logInDateList: [getCurrentTime()],
      );
    }

    return userModel.copyWith(userStatus: UserStatus.online);
  }

  // add user logout time
  UserModel addLogOutTimeToUserModel({required UserModel userModel}) {
    if (userModel.userTimeModel![getCurrentDayName()] != null) {
      userModel.userTimeModel![getCurrentDayName()] = userModel.userTimeModel![getCurrentDayName()]!.copyWith(
        logOutDateList: [
          ...(userModel.userTimeModel![getCurrentDayName()]!.logOutDateList ?? []), // إضافة الوقت الحالي إلى القائمة الحالية
          getCurrentTime(),
        ],
      );
    }

    return userModel.copyWith(userStatus: UserStatus.away);
  }

  List<DateTime>? getEnterTimes(UserModel? userModel) {
    return userModel?.userTimeModel![getCurrentDayName()]?.logInDateList;
  }

  List<DateTime>? getOutTimes(UserModel? userModel) {
    return userModel?.userTimeModel![getCurrentDayName()]?.logOutDateList;
  }

  bool isWithinRegion(Position location, double targetLatitude, double targetLongitude, double radiusInMeters) {
    double distanceInMeters = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distanceInMeters <= radiusInMeters;
  }
}
