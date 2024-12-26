import 'package:ba3_bs_mobile/features/users_management/controllers/user_management_controller.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../login/data/repositories/user_repo.dart';
import '../../users_management/data/models/user_model.dart';

class UserTimeController extends GetxController {
  final UserManagementRepository _userRepository;

  UserTimeController( this._userRepository);

  void addUserTime(TimeType timeType) {
    UserModel userModel = read<UserManagementController>().loggedInUserModel!;
    if (timeType == TimeType.byLabel("دخول")) {
      _userRepository.logLoginTime(userModel.userId);
    } else {
      _userRepository.logLogoutTime(userModel.userId);
    }
  }
}
