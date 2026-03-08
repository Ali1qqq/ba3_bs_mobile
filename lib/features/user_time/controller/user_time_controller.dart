import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  Rx<UserWorkStatus> userStatus = UserWorkStatus.away.obs;

  Rx<RequestState> checkTimeState = RequestState.initial.obs;
  Rx<RequestState> logOutState = RequestState.initial.obs;

  @override
  void onInit() async {
    super.onInit();
    _userTimeServices = UserTimeServices();
    await _userTimeServices.init();
    debugPrint(getUserById.toJson().toString(), wrapWidth: 1024);
    _updateLastTimes();
  }

  List<String>? get userHolidays => getUserById.userHolidays
      ?.toList()
      .where(
        (element) =>
            element.split("-")[1] ==
            Timestamp.now().toDate().month.toString().padLeft(2, "0"),
      )
      .toList();

  List<String>? get userJetourDays => getUserById.userJetourWork
      ?.toList()
      .where(
        (element) =>
            element.split("-")[1] ==
            Timestamp.now().toDate().month.toString().padLeft(2, "0"),
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

  UserModel get getUserById =>
      read<UserManagementController>().loggedInUserModel!;

  Future<void> checkTime(BuildContext context) async {
    await _handleLog(
        context: context,
        onUpdate: (user) => _userTimeServices.toggleCheckInOut(user));
  }

  Future<void> _handleLog({
    required BuildContext context,
    required UserModel Function(UserModel) onUpdate,
  }) async {
    checkTimeState.value = RequestState.loading;
    await read<UserManagementController>().refreshLoggedInUser();
    bool isValid = await _validateLog(getUserById);
    if (!isValid) {
      AppUIUtils.onFailure("يجب ان تكون ضمن منطقة العمل");
      return;
    }

    final shifts = _userTimeServices.getSortedShifts(getUserById);
    final yesterday = _userTimeServices.yesterdayKey;
    final today = _userTimeServices.todayKey;
    final loginYesterdayList =
        getUserById.userTimeModel?[yesterday]?.logInDateList ?? [];
    final logoutYesterdayList =
        getUserById.userTimeModel?[yesterday]?.logOutDateList ?? [];
    final loginTodayList =
        getUserById.userTimeModel?[today]?.logInDateList ?? [];
    final logoutTodayList =
        getUserById.userTimeModel?[today]?.logOutDateList ?? [];

    final updated = onUpdate(getUserById);

    if ((loginYesterdayList.length > logoutYesterdayList.length) &&
        !_userTimeServices.validateLoginTime(shifts)) {
      final confirm =
          await _confirmAction(message: 'هل تريد تسجيل الخروج ليوم امس؟');

      if (!confirm) {
        checkTimeState.value = RequestState.success;
        return;
      }
      await _userTimeServices.init();

      //تسجيل الخروج ليوم امس فقط دون تسجيل دخول لليوم الحالي
      final result = await _usersRepo.save(updated);

      result.fold(
        (failure) async {
          checkTimeState.value = RequestState.error;
          await _updateLastTimes();
          AppUIUtils.onFailure(failure.message);
        },
        (_) async {
          checkTimeState.value = RequestState.success;
          await _updateLastTimes();
          AppUIUtils.onSuccess('تم تسجيل الخروج ليوم امس بنجاح');
        },
      );
      return;
    }

    if ((loginTodayList.length == logoutTodayList.length) &&
        !_userTimeServices.validateLoginTime(shifts)) {
      checkTimeState.value = RequestState.error;
      AppUIUtils.onFailure(
          " يجب تسجيل الدخول قبل بداية الشفت الحالي بـ 15 دقيقة أو أقل");
      return;
    } else {
      final confirm = await _confirmAction(
          message: (loginTodayList.length == logoutTodayList.length)
              ? 'هل تريد تسجيل الدخول لليوم الحالي؟'
              : 'هل تريد تسجيل الخروج لليوم الحالي؟');
      if (!confirm) {
        checkTimeState.value = RequestState.success;
        return;
      }
      await _userTimeServices.init();

      //تسجيل الدخول لليوم الحالي مع تسجيل الخروج ليوم امس اذا  كان بحاجة
      final result = await _usersRepo.save(updated);

      result.fold(
        (failure) async {
          checkTimeState.value = RequestState.error;
          await _updateLastTimes();
          AppUIUtils.onFailure(failure.message);
        },
        (_) async {
          checkTimeState.value = RequestState.success;
          await _updateLastTimes();
          AppUIUtils.onSuccess(userStatus.value == UserWorkStatus.online
              ? 'تم تسجيل الدخول بنجاح'
              : 'تم تسجيل الخروج بنجاح');
        },
      );
      return;
    }
  }

  Future<bool> _confirmAction(
      {String message = "هل أنت متأكد من تنفيذ العملية؟"}) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("تأكيد العملية"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
            },
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text("تأكيد"),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  Future<bool> _validateLog(UserModel u) async {
    // final today = _userTimeServices.todayKey;
    // final model = u.userTimeModel?[today];

    // final logInCount = model?.logInDateList?.length ?? 0;
    // final logOutCount = model?.logOutDateList?.length ?? 0;
    // final expected = (u.userWorkingHours?.length ?? 0) * 2;

    // // if (logInCount >= expected /*|| u.userWorkStatus == targetStatus*/) return false;
    // if (logOutCount + logInCount ==
    //     expected /*|| u.userWorkStatus == targetStatus*/) return false;
    if (await isWithinRegion() == false) return false;
    return true;
  }

  Future<void> _updateLastTimes() async {
    await read<UserManagementController>().refreshLoggedInUser();
    final today = _userTimeServices.todayKey;
    final loginList = getUserById.userTimeModel?[today]?.logInDateList ?? [];
    final logoutList = getUserById.userTimeModel?[today]?.logOutDateList ?? [];
    userStatus.value = getUserById.userWorkStatus ?? UserWorkStatus.away;
    if (loginList.isNotEmpty) {
      lastEnterTime.value = AppServiceUtils.formatDateTime(loginList.last);
    }

    if (logoutList.isNotEmpty && logoutList.length == loginList.length) {
      lastOutTime.value = AppServiceUtils.formatDateTime(logoutList.last);
    }
    if (logoutList.length < loginList.length) {
      lastOutTime.value = "لم يتم تسجيل خروج بعد";
    }
  }

  Future<bool> isWithinRegion() async {
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
                location,
                AppConstants.targetLatitude,
                AppConstants.targetLongitude,
                AppConstants.radiusInMeters) ||
            _userTimeServices.isWithinRegion(
                location,
                AppConstants.secondTargetLatitude,
                AppConstants.secondTargetLongitude,
                AppConstants.secondRadiusInMeters);
      },
    );

    return isWithinRegion;
  }

  String get getTotalLoginDelayTime {
    int delay = 0;

    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    getUserById.userTimeModel?.forEach((key, value) {
      final date = DateTime.parse(key);

      final isSameMonth =
          date.year == currentYear && date.month == currentMonth;

      final isNotToday = date.day != now.day ||
          date.month != now.month ||
          date.year != now.year;

      if (isSameMonth && isNotToday) {
        delay += value.totalLogInDelay ?? 0;
      }
    });

    return AppServiceUtils.convertMinutesAndFormat(delay);
  }

  String get getTotalOutEarlierTime {
    int late = 0;

    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    getUserById.userTimeModel?.forEach((key, value) {
      final date = DateTime.parse(key);

      final isSameMonth =
          date.year == currentYear && date.month == currentMonth;

      final isNotToday = date.day != now.day ||
          date.month != now.month ||
          date.year != now.year;

      if (isSameMonth && isNotToday) {
        late += value.totalOutEarlier ?? 0;
      }
    });

    return AppServiceUtils.convertMinutesAndFormat(late);
  }
}
