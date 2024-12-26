import 'package:ba3_bs_mobile/core/helper/enums/enums.dart';
import 'package:ba3_bs_mobile/features/user_time/data/repositories/user_time_repo.dart';
import 'package:ba3_bs_mobile/features/user_time/services/user_time_services.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:get/get.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/firebase/implementations/filterable_data_source_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../users_management/data/models/user_model.dart';

class UserTimeController extends GetxController {
  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;
  final UserTimeRepository _userTimeRepo;

  UserTimeController(this._usersFirebaseRepo, this._userTimeRepo);

  late final UserTimeServices _userTimeServices;

  Rx<RequestState> logInState = RequestState.initial.obs;
  Rx<RequestState> logOutState = RequestState.initial.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    initialize();
  }

  void initialize() {
    _userTimeServices = UserTimeServices();
  }

  saveLogInTime() async {
    logInState.value = RequestState.loading;

    final UserModel updatedUserModel = _userTimeServices.addLoginTimeToUserModel(read<UserManagementController>().loggedInUserModel!);
    if (await _userTimeRepo.checkLogin()) {
      final result = await _usersFirebaseRepo.save(updatedUserModel);

      result.fold(
        (failure) {
          logInState.value = RequestState.error;
          return AppUIUtils.onFailure(failure.message);
        },
        (fetchedUser) {
          logInState.value = RequestState.success;
          return AppUIUtils.onSuccess('تم تسجيل الدخول بنجاح');
        },
      );
    } else {
      logInState.value = RequestState.error;
      AppUIUtils.onFailure('خطأ في المنطة الجغرافية');
    }
  }

  void saveLogOutTime() async {
    logOutState.value = RequestState.loading;

    final UserModel updatedUserModel = _userTimeServices.addLogOutTimeToUserModel(read<UserManagementController>().loggedInUserModel!);
    if (await _userTimeRepo.checkLogin()) {
      final result = await _usersFirebaseRepo.save(updatedUserModel);

      result.fold(
        (failure) {
          logOutState.value = RequestState.error;
          return AppUIUtils.onFailure(failure.message);
        },
        (fetchedUser) {
          logOutState.value = RequestState.success;
          return AppUIUtils.onSuccess('تم تسجيل الخروج بنجاح');
        },
      );
    } else {
      logOutState.value = RequestState.error;
      AppUIUtils.onFailure('خطأ في المنطة الجغرافية');
    }
  }

/* // Fetch roles using the repository
  Future<void> updateUserLogin(UserModel userModel) async {

    final result = await _usersFirebaseRepo.save(userModel);

    result.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (updatedUser)=> AppUIUtils.onSuccess('تم تسجيل الدخول بنجاح'),
    );

    update();
  }
  // Log login time
  Future<void> logInTime() async {
    UserModel? loggedInUserModel = read<UserManagementController>().loggedInUserModel;
    if (loggedInUserModel != null) {
      final result = await _userTimeServices.logLoginTime(loggedInUserModel);
      result.fold(
        (failure) => Get.snackbar("Error", "جرب طفي التطبيق ورجاع شغلو او تأكد من اتصال النت  ${failure.message} \n"),
        (success) => Get.snackbar("Success", "Login time logged successfully!"),
      );
    }
  }

  // Log logout time
  Future<void> logOutTime() async {
    UserModel? loggedInUserModel = read<UserManagementController>().loggedInUserModel;
    if (loggedInUserModel != null) {
      final result = await _userTimeServices.logLogoutTime(loggedInUserModel);
      result.fold(
        (failure) => Get.snackbar("Error", "جرب طفي التطبيق ورجاع شغلو او تأكد من اتصال النت  ${failure.message} \n"),
        (success) => Get.snackbar("Success", "Logout time logged successfully!"),
      );
    }
  }*/
}
