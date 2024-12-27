import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/user_time/data/repositories/user_time_repo.dart';
import 'package:ba3_bs_mobile/features/user_time/services/user_time_services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/firebase/implementations/filterable_data_source_repo.dart';
import '../../../core/utils/app_service_utils.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../users_management/controllers/user_management_controller.dart';
import '../../users_management/data/models/user_model.dart';

class UserTimeController extends GetxController {
  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;
  final UserTimeRepository _userTimeRepo;

  UserTimeController(this._usersFirebaseRepo, this._userTimeRepo);

  late final UserTimeServices _userTimeServices;

  Rx<String> lastEnterTime = "لم يتم تسجيل الدخول بعد".obs;
  Rx<String> lastOutTime = "لم يتم تسجيل الخروج بعد".obs;

  Rx<RequestState> logInState = RequestState.initial.obs;
  Rx<RequestState> logOutState = RequestState.initial.obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<bool> isWithinRegion() async {
    final result = await _userTimeRepo.getCurrentLocation();
    bool isWithinRegion = false;
    result.fold(
      (failure) {
        return AppUIUtils.onFailure(failure.message);
      },
      (location) {
        return isWithinRegion = _userTimeServices.isWithinRegion(location, AppStrings.targetLatitude, AppStrings.targetLongitude, AppStrings.radiusInMeters);
      },
    );

    return isWithinRegion;
  }

  void initialize() {
    _userTimeServices = UserTimeServices();
    getLastEnterTime();
    getLastOutTime();
  }

  Future<void> checkUserLog({required UserStatus logStatus, required Function(UserModel) onChecked, required String errorMessage}) async {
    if (logStatus == UserStatus.online) {
      logInState.value = RequestState.loading;
    } else {
      logOutState.value = RequestState.loading;
    }

    UserModel? userModel = getUserById();

    /// check if user in regin
    if (!await isWithinRegion()) {
      handleError('خطأ في المنطقة الجغرافية', logStatus);
      return;
    }

    /// check if user want to login again before logout
    /// or
    /// check if user want to logout again before login
    if (userModel!.userStatus != logStatus) {
      final updatedUserModel = onChecked(userModel);

      /// check if user want to log in
      if (logStatus == UserStatus.online) {
        _saveLogInTime(updatedUserModel);
      } else {
        _saveLogOutTime(updatedUserModel);
      }
    } else {
      handleError(errorMessage, logStatus);
    }
  }

  UserModel? getUserById() => read<UserManagementController>().loggedInUserModel!;

  Future<void> checkLogInAndSave() async {
    await checkUserLog(
      /// This is the user's status after the operation
      logStatus: UserStatus.online,

      /// After confirming the possibility of lo
      onChecked: (userModel) => _userTimeServices.addLoginTimeToUserModel(
        userModel: userModel,
      ),
      errorMessage: "يجب تسجيل الخروج أولا",
    );
  }

  Future<void> checkLogOutAndSave() async {
    await checkUserLog(
      /// This is the user's status after the operation
      logStatus: UserStatus.away,

      /// After confirming the possibility of lo
      onChecked: (userModel) => _userTimeServices.addLogOutTimeToUserModel(
        userModel: userModel,
      ),
      errorMessage: "يجب تسجيل الدخول أولا",
    );
  }

  void _saveLogOutTime(UserModel updatedUserModel) async {
    final result = await _usersFirebaseRepo.save(updatedUserModel);
    result.fold(
      (failure) {
        handleError(failure.message, UserStatus.away);
      },
      (fetchedUser) {
        handleSuccess('تم تسجيل الخروج بنجاح', UserStatus.away);
        setLastOutTime = AppServiceUtils.formatDateTime(_userTimeServices.getCurrentTime());
      },
    );
  }

  void _saveLogInTime(UserModel updatedUserModel) async {
    final result = await _usersFirebaseRepo.save(updatedUserModel);

    result.fold(
      (failure) {
        handleError(failure.message, UserStatus.online);
      },
      (fetchedUser) {
        handleSuccess('تم تسجيل الدخول بنجاح', UserStatus.online);

        setLastEnterTime = AppServiceUtils.formatDateTime(_userTimeServices.getCurrentTime());
      },
    );
  }

  getLastEnterTime() async {
    List<DateTime> enterTimeList = _userTimeServices.getEnterTimes(getUserById()) ?? [];
    if (enterTimeList.isNotEmpty) {
      setLastEnterTime = AppServiceUtils.formatDateTime(enterTimeList.last);
    }
  }

  getLastOutTime() async {
    List<DateTime> outTimeList = _userTimeServices.getOutTimes(getUserById()) ?? [];
    if (outTimeList.isNotEmpty) {
      setLastOutTime = AppServiceUtils.formatDateTime(outTimeList.last);
    }
  }

  void handleError(String errorMessage, UserStatus status) {
    if (status == UserStatus.online) {
      logInState.value = RequestState.error;
    } else {
      logOutState.value = RequestState.error;
    }
    AppUIUtils.onFailure(errorMessage);
  }

  void handleSuccess(String successMessage, UserStatus status) {
    if (status == UserStatus.online) {
      logInState.value = RequestState.success;
    } else {
      logOutState.value = RequestState.success;
    }
    AppUIUtils.onSuccess(successMessage);
  }

  set setLastEnterTime(String time) {
    lastEnterTime.value = time;
  }

  set setLastOutTime(String time) {
    lastOutTime.value = time;
  }
}
