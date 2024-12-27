import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/user_time/data/repositories/user_time_repo.dart';
import 'package:ba3_bs_mobile/features/user_time/services/user_time_services.dart';
import 'package:get/get.dart';

import '../../../core/services/firebase/implementations/filterable_data_source_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
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
    _userTimeServices = UserTimeServices(this, _userTimeRepo, _usersFirebaseRepo);

    _userTimeServices.getLastEnterTime();
    _userTimeServices.getLastOutTime();
  }

  Future<void> checkSaveLogIn() async {
    await _userTimeServices.checkUserLog(
      requiredStatus: UserStatus.online,
      onSuccess: (userModel) => _userTimeServices.addLoginTimeToUserModel(
        userModel: userModel,
        dayName: _userTimeServices.getCurrentDayName(),
        timeNow: _userTimeServices.getCurrentTime(),
      ),
      errorMessage: "يجب تسجيل الخروج أولا",
    );
  }

  Future<void> checkSaveLogOut() async {
    await _userTimeServices.checkUserLog(
      requiredStatus: UserStatus.away,
      onSuccess: (userModel) => _userTimeServices.addLogOutTimeToUserModel(
        userModel: userModel,
        dayName: _userTimeServices.getCurrentDayName(),
        timeNow: _userTimeServices.getCurrentTime(),
      ),
      errorMessage: "يجب تسجيل الدخول أولا",
    );
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
