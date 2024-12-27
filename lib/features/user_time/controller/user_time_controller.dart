import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/user_time/data/repositories/user_time_repo.dart';
import 'package:ba3_bs_mobile/features/user_time/services/user_time_services.dart';
import 'package:get/get.dart';

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

  void initialize() {
    _userTimeServices = UserTimeServices();

    getLastEnterTime();
    getLastOutTime();
  }

  Future<void> checkUserLog({required UserStatus requiredStatus, required Function(UserModel) onSuccess, required String errorMessage}) async {
    try {
      if (requiredStatus == UserStatus.online) {
        logInState.value = RequestState.loading;
      } else {
        logOutState.value = RequestState.loading;
      }

      UserModel? userModel = await getUserById();

      if (!await _userTimeRepo.checkLogin()) {
        handleError('خطأ في المنطقة الجغرافية', requiredStatus);
        return;
      }

      if (userModel!.userStatus == requiredStatus) {
        final updatedUserModel = onSuccess(userModel);
        if (requiredStatus == UserStatus.online) {
          _saveLogInTime(updatedUserModel);
        } else {
          _saveLogOutTime(updatedUserModel);
        }
      } else {
        handleError(errorMessage, requiredStatus);
      }
    } catch (e) {
      handleError("حدث خطأ أثناء العملية: $e", requiredStatus);
    }
  }

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

  Future<void> checkSaveLogIn() async {
    await checkUserLog(
      requiredStatus: UserStatus.online,
      onSuccess: (userModel) => _userTimeServices.addLoginTimeToUserModel(
        userModel: userModel,
        dayName: _userTimeRepo.getCurrentDayName(),
        timeNow: _userTimeRepo.getCurrentTime(),
      ),
      errorMessage: "يجب تسجيل الخروج أولا",
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

        setLastEnterTime = AppServiceUtils.formatDateTime(_userTimeRepo.getCurrentTime());
      },
    );
  }

  Future<void> checkSaveLogOut() async {
    await checkUserLog(
      requiredStatus: UserStatus.away,
      onSuccess: (userModel) => _userTimeServices.addLogOutTimeToUserModel(
        userModel: userModel,
        dayName: _userTimeRepo.getCurrentDayName(),
        timeNow: _userTimeRepo.getCurrentTime(),
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
        handleError('تم تسجيل الخروج بنجاح', UserStatus.away);
        setLastOutTime = AppServiceUtils.formatDateTime(_userTimeRepo.getCurrentTime());
      },
    );
  }

  getLastEnterTime() async {
    UserModel? userModel = await getUserById();
    List<DateTime> enterTimeList = _userTimeServices.getEnterTimes(userModel, _userTimeRepo.getCurrentDayName()) ?? [];
    if (enterTimeList.isNotEmpty) {
      setLastEnterTime = AppServiceUtils.formatDateTime(enterTimeList.last);
    }
  }

  getLastOutTime() async {
    UserModel? userModel = await getUserById();

    List<DateTime> outTimeList = _userTimeServices.getOutTimes(userModel, _userTimeRepo.getCurrentDayName()) ?? [];
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
    AppUIUtils.onFailure(successMessage);
  }

  set setLastEnterTime(String time) {
    lastEnterTime.value = time;
  }

  set setLastOutTime(String time) {
    lastOutTime.value = time;
  }
}
