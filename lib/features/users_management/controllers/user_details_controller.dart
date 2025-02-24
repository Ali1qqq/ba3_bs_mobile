import 'package:ba3_bs_mobile/core/helper/extensions/date_time/time_extensions.dart';
import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:get/get.dart';

import '../../../core/dialogs/custom_date_picker_dialog.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/network/error/failure.dart';
import '../../../core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../changes/controller/changes_controller.dart';
import '../data/models/user_model.dart';
import '../services/role_form_handler.dart';
import '../services/user_form_handler.dart';
import '../services/user_service.dart';

class UserDetailsController extends GetxController {
  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;

  late final UserFormHandler userFormHandler;
  late final RoleFormHandler roleFormHandler;

  // Services
  late final UserService _userService;

  Map<String, UserWorkingHours> workingHours = {};

  int get workingHoursLength => workingHours.length;

  Set<String> holidays = {};

  UserDetailsController(this._usersFirebaseRepo);

  int get holidaysLength => holidays.length;

  UserManagementController get allUserController => read<UserManagementController>();

  // UserModel? get selectedUserModel => allUserController.selectedUserModel;
  UserModel? selectedUserModel;

  UserModel getUserById(String userId) => selectedUserModel = allUserController.allUsers.firstWhere((user) => user.userId == userId);

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  void _initializeServices() {
    _userService = UserService();

    userFormHandler = UserFormHandler();
    roleFormHandler = RoleFormHandler();

    // userNavigator = UserNavigator(roleFormHandler, userFormHandler, _sharedPreferencesService);
  }

  setEnterTime(int index, Time time) {
    workingHours.values.elementAt(index).enterTime = time.formatToAmPm();
    update();
  }

  setOutTime(int index, Time time) {
    workingHours.values.elementAt(index).outTime = time.formatToAmPm();
    update();
  }

  void addWorkingHour() {
    workingHours[workingHoursLength.toString()] =
        UserWorkingHours(id: workingHoursLength.toString(), enterTime: "AM 12:00", outTime: "AM 12:00");
    update();
  }

  void deleteWorkingHour({required int key}) {
    workingHours.remove(key.toString());
    update();
  }

  void addHoliday() {
    Get.defaultDialog(
      title: 'أختر يوم',
      content: CustomDatePickerDialog(
        onClose: () {
          update();
          Get.back();
        },
        onTimeSelect: (dateRangePickerSelectionChangedArgs) {
          final selectedDateList = dateRangePickerSelectionChangedArgs.value as List<DateTime>;
          holidays.addAll(
            selectedDateList.map((e) => e.toIso8601String().split("T")[0]),
          );
        },
      ),
    );
  }

  void deleteHoliday({required String element}) {
    holidays.remove(element);
    update();
  }

  UserModel? _createUserModel() => _userService.createUserModel(
        userModel: selectedUserModel,
        userName: userFormHandler.userNameController.text,
        userPassword: userFormHandler.passController.text,
        userRoleId: userFormHandler.selectedRoleId.value,
        userSellerId: userFormHandler.selectedSellerId.value,
        workingHour: workingHours,
        userActiveState: userFormHandler.userActiveStatus.value,
        holidays: holidays.toList(),
      );

  Future<void> saveOrUpdateUser() async {
    // Validate the form first
    if (!userFormHandler.validate()) return;

    final updatedUserModel = _createUserModel();

    // Handle null user model
    if (updatedUserModel == null) {
      AppUIUtils.onFailure('من فضلك قم بادخال الصلاحيات و البائع!');
      return;
    }

    final result = await _usersFirebaseRepo.save(updatedUserModel);

    result.fold(
      (failure) => _handleFailure(failure),
      (userModel) => _onUserSaved(userModel),
    );
  }

  void _handleFailure(Failure failure) => AppUIUtils.onFailure(failure.message);

  void _onUserSaved(UserModel userModel) {
    AppUIUtils.onSuccess('تم الحفظ بنجاح');
    allUserController.getAllUsers();

    // Check if the user was newly saved
    final isSaved = selectedUserModel == null;
    if (isSaved) {
      _createChangeDocument(userModel.userId!);
    }
    update();
  }

  // Call the ChangesController to create the document
  Future<void> _createChangeDocument(String userId) async => await read<ChangesController>().createChangeDocument(userId);

  void initUserFormHandler(UserModel? user) {
    userFormHandler.init(user);
  }
}
