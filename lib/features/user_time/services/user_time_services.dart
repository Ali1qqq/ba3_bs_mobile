import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/user_time/controller/user_time_controller.dart';
import 'package:ba3_bs_mobile/features/user_time/data/repositories/user_time_repo.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/firebase/implementations/filterable_data_source_repo.dart';
import '../../../core/utils/app_service_utils.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../users_management/controllers/user_management_controller.dart';

class UserTimeServices {
  final UserTimeController _userTimeController;

  final UserTimeRepository _userTimeRepository;

  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;

  UserTimeServices(this._userTimeController, this._userTimeRepository, this._usersFirebaseRepo);

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

  Future<void> checkUserLog({required UserStatus requiredStatus, required Function(UserModel) onSuccess, required String errorMessage}) async {
    try {
      if (requiredStatus == UserStatus.online) {
        _userTimeController.logInState.value = RequestState.loading;
      } else {
        _userTimeController.logOutState.value = RequestState.loading;
      }

      UserModel? userModel = await getUserById();

      if (!await _userTimeRepository.checkLogin()) {
        _userTimeController.handleError('خطأ في المنطقة الجغرافية', requiredStatus);
        return;
      }

      if (userModel!.userStatus == requiredStatus) {
        final updatedUserModel = onSuccess(userModel);
        if (requiredStatus == UserStatus.online) {
          saveLogInTime(updatedUserModel);
        } else {
          saveLogOutTime(updatedUserModel);
        }
      } else {
        _userTimeController.handleError(errorMessage, requiredStatus);
      }
    } catch (e) {
      _userTimeController.handleError("حدث خطأ أثناء العملية: $e", requiredStatus);
    }
  }

  void saveLogOutTime(UserModel updatedUserModel) async {
    final result = await _usersFirebaseRepo.save(updatedUserModel);
    result.fold(
      (failure) {
        _userTimeController.handleError(failure.message, UserStatus.away);
      },
      (fetchedUser) {
        _userTimeController.handleError('تم تسجيل الخروج بنجاح', UserStatus.away);
        _userTimeController.setLastOutTime = AppServiceUtils.formatDateTime(getCurrentTime());
      },
    );
  }

  void saveLogInTime(UserModel updatedUserModel) async {
    final result = await _usersFirebaseRepo.save(updatedUserModel);

    result.fold(
      (failure) {
        _userTimeController.handleError(failure.message, UserStatus.online);
      },
      (fetchedUser) {
        _userTimeController.handleError('تم تسجيل الدخول بنجاح', UserStatus.online);

        _userTimeController.setLastEnterTime = AppServiceUtils.formatDateTime(getCurrentTime());
      },
    );
  }

  DateTime getCurrentTime() => Timestamp.now().toDate();

  String getCurrentDayName() => getCurrentTime().toString().split(" ")[0];

  Future<UserModel?> getUserById() async {
    late UserModel userModel;
    UserModel currentUser = read<UserManagementController>().loggedInUserModel!;
    final result = await _usersFirebaseRepo.getById(currentUser.userId!);
    result.fold(
      (failure) {
        return AppUIUtils.onFailure(failure.message);
      },
      (fetchedUser) {
        userModel = fetchedUser;
      },
    );

    return userModel;
  }

  Future<DateTime?> getLastEnterTime() async {
    DateTime? lastEnterTime;
    UserModel? userModel = await getUserById();
    List<DateTime> enterTimeList = getEnterTimes(userModel, getCurrentDayName()) ?? [];
    if (enterTimeList.isNotEmpty) {
      _userTimeController.setLastEnterTime = AppServiceUtils.formatDateTime(enterTimeList.last);
      lastEnterTime = enterTimeList.last;
    }
    return lastEnterTime;
  }

  Future<DateTime?> getLastOutTime() async {
    DateTime? lastOutTime;
    UserModel? userModel = await getUserById();

    List<DateTime> outTimeList = getOutTimes(userModel, getCurrentDayName()) ?? [];
    if (outTimeList.isNotEmpty) {
      _userTimeController.setLastOutTime = AppServiceUtils.formatDateTime(outTimeList.last);
      lastOutTime = outTimeList.last;
    }
    return lastOutTime;
  }
}
