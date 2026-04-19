import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/models/query_filter.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import 'package:ba3_bs_mobile/core/services/get_x/shared_preferences_service.dart';
import 'package:ba3_bs_mobile/features/user_time/data/models/leave_requests_model.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';

class LeaveController extends GetxController {
  final FilterableDataSourceRepository<LeaveRequestModel> _leaveRepo;
  final RemoteDataSourceRepository<UserModel> _userRepo;

  LeaveController(this._leaveRepo, this._userRepo);

  RxList<LeaveRequestModel> leaves = <LeaveRequestModel>[].obs;

  final Rx<RequestState> getLeavesState = RequestState.initial.obs;
  final Rx<RequestState> addLeaveState = RequestState.initial.obs;
  final Rx<RequestState> updateLeaveState = RequestState.initial.obs;
  final Rx<RequestState> deleteLeaveState = RequestState.initial.obs;

  late String userId;
  late UserModel? user;
  final sharedPreferencesService = Get.find<SharedPreferencesService>();

  final RxString startDate = "".obs;
  final RxString endDate = "".obs;
  final Rx<LeaveType> selectedType = LeaveType.sick.obs;

  @override
  void onInit() {
    super.onInit();
    userId = sharedPreferencesService.getString(AppConstants.userIdKey) ?? "";
    getUser();
    fetchLeaves();
  }

  /// 🔥 Fetch from user document (array)
  Future<void> fetchLeaves() async {
    getLeavesState.value = RequestState.loading;

    final result = await _leaveRepo.fetchWhere(
      queryFilters: [QueryFilter(field: 'userId', value: userId)],
    );

    result.fold(
      (failure) {
        getLeavesState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (data) {
        getLeavesState.value = RequestState.success;
        leaves.assignAll(data);
      },
    );
  }

  Future<void> deleteLeave(String leaveId) async {
    final bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد أنك تريد حذف طلب الإجازة؟"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text("حذف"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    deleteLeaveState.value = RequestState.loading;

    /// 1️⃣ حذف من leave_requests collection
    final deleteResult = await _leaveRepo.delete(leaveId);

    await deleteResult.fold(
      (failure) async {
        deleteLeaveState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (_) async {
        /// 2️⃣ تحديث user document (حذف من array)
        final userResult = await _userRepo.getById(userId);

        await userResult.fold(
          (failure) async {
            deleteLeaveState.value = RequestState.error;
            AppUIUtils.onFailure(failure.message);
          },
          (user) async {
            final updatedLeaves =
                user.userLeaveRequests?.where((e) => e.id != leaveId).toList();

            final updatedUser = user.copyWith(userLeaveRequests: updatedLeaves);

            await _userRepo.save(updatedUser);

            /// 3️⃣ تحديث الليست المحلية
            leaves.removeWhere((e) => e.id == leaveId);

            deleteLeaveState.value = RequestState.success;

            AppUIUtils.onSuccess("تم حذف طلب الإجازة بنجاح");
          },
        );
      },
    );
  }

  getUser() async {
    final userResult = await _userRepo.getById(userId);

    await userResult.fold((failure) async {
      addLeaveState.value = RequestState.error;
      AppUIUtils.onFailure(failure.message);
    }, (data) async {
      user = data;
    });
  }

  /// 🔥 Add Leave (save in leave_requests + update user array)
  Future<void> addLeave() async {
    if (startDate.value.isEmpty || endDate.value.isEmpty) {
      AppUIUtils.onFailure(
        'الرجاء اختيار تاريخ البداية والنهاية',
      );
      return;
    }
    final start = DateTime.parse(startDate.value);
    final end = DateTime.parse(endDate.value).add(const Duration(days: 1));

    if (start.isAfter(end)) {
      AppUIUtils.onFailure(
          'تاريخ البداية يجب أن يكون قبل او يساوي تاريخ النهاية');
      return;
    }
    addLeaveState.value = RequestState.loading;

    final leave = LeaveRequestModel(
      id: const Uuid().v4(),
      userId: userId,
      userName: user?.userName ?? "",
      startDate: startDate.value.trim(),
      endDate: endDate.value.trim(),
      leaveType: selectedType.value,
      status: LeaveStatus.pending,
    );

    /// 1️⃣ Save in leave_requests collection
    final leaveResult = await _leaveRepo.save(leave);

    await leaveResult.fold(
      (failure) async {
        addLeaveState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (savedLeave) async {
        /// 2️⃣ Update user document array
        final userResult = await _userRepo.getById(userId);

        await userResult.fold(
          (failure) async {
            addLeaveState.value = RequestState.error;
            AppUIUtils.onFailure(failure.message);
          },
          (user) async {
            UserLeaveRequestModel leaveRequestModel = UserLeaveRequestModel(
              id: savedLeave.id,
              startDate: savedLeave.startDate,
              endDate: savedLeave.endDate,
              leaveType: savedLeave.leaveType,
              status: savedLeave.status,
            );
            final List<UserLeaveRequestModel> updatedLeaves =
                user.userLeaveRequests ?? [];
            updatedLeaves.add(leaveRequestModel);

            UserModel updatedUser =
                user.copyWith(userLeaveRequests: updatedLeaves);
            await _userRepo.save(updatedUser);

            leaves.add(savedLeave);

            addLeaveState.value = RequestState.success;
            Navigator.of(Get.context!).pop();

            AppUIUtils.onSuccess(
              "تم إرسال طلب الإجازة بنجاح",
            );
          },
        );
      },
    );
  }

  /// 🔥 Update status in both places
  Future<void> updateLeaveStatus(
    String leaveId,
    LeaveStatus newStatus,
  ) async {
    updateLeaveState.value = RequestState.loading;

    final leave = leaves.firstWhereOrNull((e) => e.id == leaveId);
    if (leave == null) return;

    leave.status = newStatus;

    /// 1️⃣ Update leave_requests collection
    final leaveResult = await _leaveRepo.save(leave);

    await leaveResult.fold(
      (failure) async {
        updateLeaveState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (_) async {
        /// 2️⃣ Update user array
        final userResult = await _userRepo.getById(userId);

        await userResult.fold(
          (failure) async {
            updateLeaveState.value = RequestState.error;
            AppUIUtils.onFailure(failure.message);
          },
          (user) async {
            UserLeaveRequestModel userLeaveRequestModel = UserLeaveRequestModel(
              id: leaveId,
              startDate: leave.startDate,
              endDate: leave.endDate,
              leaveType: leave.leaveType,
              status: newStatus,
            );
            List<UserLeaveRequestModel>? updatedLeaves = user.userLeaveRequests
                ?.map((e) => (e.id == leaveId ? userLeaveRequestModel : e))
                .toList();

            UserModel updatedUser =
                user.copyWith(userLeaveRequests: updatedLeaves);

            await _userRepo.save(updatedUser);

            leaves.refresh();
            updateLeaveState.value = RequestState.success;
          },
        );
      },
    );
  }

  int calculateDays(String start, String end) {
    try {
      final startDate = DateTime.parse(start);
      final endDate = DateTime.parse(end);
      return endDate.difference(startDate).inDays + 1;
    } catch (e) {
      return 0;
    }
  }
}
