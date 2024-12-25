import 'package:dartz/dartz.dart';

import '../../../../core/network/error/error_handler.dart';
import '../../../../core/network/error/failure.dart';
import '../datasources/user_management_service.dart';
import '../models/role_model.dart';
import '../models/user_model.dart';

class UserManagementRepository {
  final UserManagementService _userService;

  UserManagementRepository(this._userService);

  Map<String, OldUserModel> allUsers = {};

  // Get all roles
  Future<Either<Failure, Map<String, OldRoleModel>>> getAllRoles() async {
    try {
      final allRoles = await _userService.fetchAllRoles();
      return Right(allRoles);
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }

  // Initialize or reset a user (for adding or editing)
  OldUserModel initializeUser({String? userId}) {
    if (userId != null && allUsers.containsKey(userId)) {
      return OldUserModel.fromJson(allUsers[userId]!.toJson());
    }
    return OldUserModel();
  }

  // Check user by PIN and update the user status
  Future<Either<Failure, OldUserModel?>> checkUserByPin(String userPin) async {
    try {
      final user = await _userService.fetchUserByPin(userPin);
      return Right(user);
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }

  // Check card number and get the associated user
  Future<Either<Failure, OldUserModel?>> checkCard(String cardNumber) async {
    try {
      final card = await _userService.fetchCardByNumber(cardNumber);
      if (card != null) {
        final user = await _userService.fetchUserById(card.userId);
        return Right(user);
      }
      return const Right(null);
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }

  // Add or update a user
  Future<Either<Failure, Unit>> saveUser(OldUserModel user) async {
    try {
      await _userService.saveUser(user);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }

  // Add or update a role
  Future<Either<Failure, Unit>> saveRole(OldRoleModel role) async {
    try {
      await _userService.saveRole(role);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }

  // Log user's time report
  Future<Either<Failure, Unit>> logTimeReport(String userId, DateTime date) async {
    try {
      await _userService.logTimeReport(userId: userId, date: date);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> startTimeReport(String userId, {DateTime? customDate}) async {
    customDate ??= DateTime.now();
    try {
      await _userService.startTimeReport(userId, customDate);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }

  // Send user's time report
  Future<Either<Failure, Unit>> sendTimeReport(String userId, {int? customTime}) async {
    try {
      await _userService.sendTimeReport(userId, customTime);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }

  // Log user's login time
  Future<Either<Failure, Unit>> logLoginTime(String? userId) async {
    try {
      await _userService.logLoginTime(userId);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }

  // Log user's logout time
  Future<Either<Failure, Unit>> logLogoutTime(String? userId) async {
    try {
      await _userService.logLogoutTime(userId);
      return const Right(unit);
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }
}
