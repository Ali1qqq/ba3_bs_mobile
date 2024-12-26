
import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UserTimeServices {

  // add user logIn time
  UserModel addLoginTimeToUserModel(UserModel userModel) {
    DateTime timeNow = Timestamp.now().toDate();
    String dayName = timeNow.toString().split(" ")[0];

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
  UserModel addLogOutTimeToUserModel(UserModel userModel) {
    DateTime timeNow = Timestamp.now().toDate();
    String dayName = timeNow.toString().split(" ")[0];

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

}
