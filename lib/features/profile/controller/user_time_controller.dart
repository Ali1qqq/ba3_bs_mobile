import 'package:ba3_bs_mobile/core/constants/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import '../../../core/utils/app_service_utils.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../user_time/data/repositories/user_time_repo.dart';
import '../../user_time/services/user_time_services.dart';
import '../../users_management/controllers/user_management_controller.dart';
import '../../users_management/data/models/user_model.dart';

class UserTimeController extends GetxController {
  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;
  final UserTimeRepository _userTimeRepo;

  UserTimeController(this._usersFirebaseRepo, this._userTimeRepo);

  late final UserTimeServices _userTimeServices;

  Rx<String> lastEnterTime = AppStrings.notLoggedToday.tr.obs;
  Rx<String> lastOutTime = AppStrings.notLoggedToday.tr.obs;

  Rx<RequestState> logInState = RequestState.initial.obs;
  Rx<RequestState> logOutState = RequestState.initial.obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  List<String>? get userHolidays => getUserById()
      ?.userHolidays
      ?.toList()
      .where(
        (element) => element.split("-")[1] == Timestamp.now().toDate().month.toString().padLeft(2, "0"),
      )
      .toList();

  List<String>? get userHolidaysWithDay => userHolidays
      ?.map(
        (date) => AppServiceUtils.getDayNameAndMonthName(date),
      )
      .toList();

  int get userHolidaysLength => userHolidays?.length ?? 0;

  Future<bool> isWithinRegion() async {
    final result = await _userTimeRepo.getCurrentLocation();
    bool isWithinRegion = false;
    result.fold(
      (failure) {
        return AppUIUtils.onFailure(failure.message);
      },
      (location) {
        return isWithinRegion = _userTimeServices.isWithinRegion(
                location, AppConstants.targetLatitude, AppConstants.targetLongitude, AppConstants.radiusInMeters) ||
            _userTimeServices.isWithinRegion(
                location, AppConstants.secondTargetLatitude, AppConstants.secondTargetLongitude, AppConstants.secondRadiusInMeters);
      },
    );

    return isWithinRegion;
  }

  void initialize() {
    _userTimeServices = UserTimeServices();
    getLastEnterTime();
    getLastOutTime();
  }

  Future<void> checkUserLog(
      {required UserWorkStatus logStatus, required Function(UserModel) onChecked, required String errorMessage}) async {
    if (logStatus == UserWorkStatus.online) {
      logInState.value = RequestState.loading;
    } else {
      logOutState.value = RequestState.loading;
    }
    await read<UserManagementController>().refreshLoggedInUser();

    UserModel? userModel = getUserById();

    /// we don't need it in diskTop app
    /*   /// check if user in regin
    if (!await isWithinRegion()) {
      handleError('خطأ في المنطقة الجغرافية', logStatus);
      return;
    }*/

    /// check if user want to login again before logout
    /// or
    /// check if user want to logout again before login
    if (userModel!.userWorkStatus != logStatus) {
      final updatedUserModel = onChecked(userModel);

      /// check if user want to log in
      if (logStatus == UserWorkStatus.online) {
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
      logStatus: UserWorkStatus.online,

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
      logStatus: UserWorkStatus.away,

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
        handleError(failure.message, UserWorkStatus.away);
      },
      (fetchedUser) {
        handleSuccess('تم تسجيل الخروج بنجاح', UserWorkStatus.away);
        setLastOutTime = AppServiceUtils.formatDateTime(_userTimeServices.getCurrentTime());
      },
    );
  }

  void _saveLogInTime(UserModel updatedUserModel) async {
    final result = await _usersFirebaseRepo.save(updatedUserModel);

    result.fold(
      (failure) {
        handleError(failure.message, UserWorkStatus.online);
      },
      (fetchedUser) {
        handleSuccess('تم تسجيل الدخول بنجاح', UserWorkStatus.online);

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

  void handleError(String errorMessage, UserWorkStatus status) {
    if (status == UserWorkStatus.online) {
      logInState.value = RequestState.error;
    } else {
      logOutState.value = RequestState.error;
    }
    AppUIUtils.onFailure(errorMessage);
  }

  void handleSuccess(String successMessage, UserWorkStatus status) {
    if (status == UserWorkStatus.online) {
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