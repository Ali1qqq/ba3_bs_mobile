import '../data/models/user_model.dart';

class UserService {
  UserModel? createUserModel({
    UserModel? userModel,
    required String userName,
    required String userPassword,
    String? userRoleId,
    String? userSellerId,
  }) {
    if (userRoleId == null || userSellerId == null) {
      return null;
    }

    final UserModel newUserModel;

    if (userModel == null) {
      newUserModel = UserModel(
        userName: userName,
        userPassword: userPassword,
        userRoleId: userRoleId,
        userSellerId: userSellerId,
      );
    } else {
      newUserModel = userModel.copyWith(
        userName: userName,
        userPassword: userPassword,
        userRoleId: userRoleId,
        userSellerId: userSellerId,
      );
    }
    return newUserModel;
  }
}
