import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:geolocator/geolocator.dart';

class UserTimeServices {
  // add user logIn time
  UserModel addLoginTimeToUserModel({required UserModel userModel, required String dayName, required DateTime timeNow}) {
// Check if the current day exists in userTimeModel
    if (userModel.userTimeModel![dayName] != null) {
      userModel.userTimeModel![dayName] = userModel.userTimeModel![dayName]!.copyWith(
        logInDateList: [
          ...(userModel.userTimeModel![dayName]!.logInDateList ?? []), // Merge the old list with the new date
          timeNow,
        ],
      );
    } else {
      userModel.userTimeModel![dayName] = UserTimeModel(
        dayName: dayName,
        logInDateList: [timeNow],
      );
    }

    return userModel.copyWith(userStatus: UserStatus.online);
  }

  // add user logout time
  UserModel addLogOutTimeToUserModel({required UserModel userModel, required String dayName, required DateTime timeNow}) {
    if (userModel.userTimeModel![dayName] != null) {
      userModel.userTimeModel![dayName] = userModel.userTimeModel![dayName]!.copyWith(
        logOutDateList: [
          ...(userModel.userTimeModel![dayName]!.logOutDateList ?? []), // إضافة الوقت الحالي إلى القائمة الحالية
          timeNow,
        ],
      );
    }

    return userModel.copyWith(userStatus: UserStatus.away);
  }

  List<DateTime>? getEnterTimes(UserModel? userModel, String dayName) {
    return userModel?.userTimeModel![dayName]?.logInDateList;
  }

  List<DateTime>? getOutTimes(UserModel? userModel, String dayName) {
    return userModel?.userTimeModel![dayName]?.logOutDateList;
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
