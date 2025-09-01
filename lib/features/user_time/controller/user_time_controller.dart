import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
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
  final FilterableDataSourceRepository<UserModel> _usersRepo;
  final UserTimeRepository _timeRepo;

  UserTimeController(this._usersRepo, this._timeRepo);

  late final UserTimeServices _userTimeServices;

  Rx<String> lastEnterTime = AppStrings.notLoggedToday.tr.obs;
  Rx<String> lastOutTime = AppStrings.notLoggedToday.tr.obs;

  Rx<RequestState> logInState = RequestState.initial.obs;
  Rx<RequestState> logOutState = RequestState.initial.obs;

  @override
  void onInit() {
    super.onInit();
    _userTimeServices = UserTimeServices();
    _updateLastTimes();
  }

  List<String>? get userHolidays => getUserById.userHolidays
      ?.toList()
      .where(
        (element) => element.split("-")[1] == Timestamp.now().toDate().month.toString().padLeft(2, "0"),
      )
      .toList();

  List<String>? get userJetourDays => getUserById.userJetourWork
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

  List<String>? get userJetourWorkWithDay => userJetourDays
      ?.map(
        (date) => AppServiceUtils.getDayNameAndMonthName(date),
      )
      .toList();

  int get userHolidaysLength => userHolidays?.length ?? 0;

  int get userJetourLength => userJetourWorkWithDay?.length ?? 0;

  UserModel get getUserById => read<UserManagementController>().loggedInUserModel!;

  Future<void> logIn(BuildContext context) async {
    await _handleLog(
      context: context,
      newStatus: UserWorkStatus.online,
      onUpdate: (user) => _userTimeServices.addLoginTimeToUserModel(userModel: user),
      errorMsg: "يجب تسجيل الخروج أولاً",
      state: logInState,
    );
  }

  Future<void> logOut(BuildContext context) async {
    await _handleLog(
      context: context,
      newStatus: UserWorkStatus.away,
      onUpdate: (u) => _userTimeServices.addLogOutTimeToUserModel(userModel: u),
      errorMsg: "يجب تسجيل الدخول أولاً",
      state: logOutState,
    );
  }

  Future<void> _handleLog({
    required BuildContext context,
    required UserWorkStatus newStatus,
    required UserModel Function(UserModel) onUpdate,
    required String errorMsg,
    required Rx<RequestState> state,
  }) async {
    await read<UserManagementController>().refreshLoggedInUser();

    if (!_validateLog(getUserById, newStatus)) {
      AppUIUtils.onFailure('تجاوزت حد اوقات الدخول لهذا اليوم');
      return;
    }

    /// we don't need it in diskTop app
    /*   /// check if user in regin
    if (!await isWithinRegion()) {
      AppUIUtils.onFailure('خطأ في المنطقة الجغرافية');
      return;
    }*/

    state.value = RequestState.loading;

    final updated = onUpdate(getUserById);
    final result = await _usersRepo.save(updated);

    result.fold(
      (failure) {
        state.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (_) {
        state.value = RequestState.success;
        AppUIUtils.onSuccess(newStatus == UserWorkStatus.online ? 'تم تسجيل الدخول بنجاح' : 'تم تسجيل الخروج بنجاح');
        _updateLastTimes();
      },
    );
  }

  bool _validateLog(UserModel u, UserWorkStatus targetStatus) {
    final today = _userTimeServices.getCurrentDayName();
    final model = u.userTimeModel?[today];

    final logInCount = model?.logInDateList?.length ?? 0;
    final logOutCount = model?.logOutDateList?.length ?? 0;
    final expected = u.userWorkingHours?.length ?? 0;

    if (logInCount >= expected /*|| u.userWorkStatus == targetStatus*/) return false;
    if (logOutCount >= expected /*|| u.userWorkStatus == targetStatus*/) return false;

    return true;
  }

  void _updateLastTimes() {
    final today = _userTimeServices.getCurrentDayName();
    final loginList = getUserById.userTimeModel?[today]?.logInDateList ?? [];
    final logoutList = getUserById.userTimeModel?[today]?.logOutDateList ?? [];

    if (loginList.isNotEmpty) {
      lastEnterTime.value = AppServiceUtils.formatDateTime(loginList.last);
    }

    if (logoutList.isNotEmpty) {
      lastOutTime.value = AppServiceUtils.formatDateTime(logoutList.last);
    }
  }

  Future<bool> isWithinRegion(BuildContext context) async {
    final result = await _timeRepo.getCurrentLocation();
    bool isWithinRegion = false;
    result.fold(
      (failure) {
        return AppUIUtils.onFailure(
          failure.message,
        );
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

  String get getTotalLoginDelayTime {
    return AppServiceUtils.convertMinutesAndFormat((getUserById.userTimeModel?.values.fold(
          0,
          (previousValue, element) => previousValue! + (element.totalLogInDelay ?? 0),
        ) ??
        0));
  }

  String get getTotalOutEarlierTime {
    return AppServiceUtils.convertMinutesAndFormat((getUserById.userTimeModel?.values.fold(
          0,
          (previousValue, element) => previousValue! + (element.totalOutEarlier ?? 0),
        ) ??
        0));
  }
}