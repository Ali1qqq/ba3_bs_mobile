import 'package:ba3_bs_mobile/core/constants/app_constants.dart';
import 'package:ba3_bs_mobile/core/models/query_filter.dart';
import 'package:ba3_bs_mobile/core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import 'package:ba3_bs_mobile/features/user_loan_requests/data/model/loan_request_model.dart';
import 'package:ba3_bs_mobile/features/user_loan_requests/data/model/user_loan_request_model.dart';
import 'package:ba3_bs_mobile/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../core/services/get_x/shared_preferences_service.dart';
import '../../../core/utils/app_ui_utils.dart';

class LoanController extends GetxController {
  final FilterableDataSourceRepository<LoanRequestModel> _loanRepo;
  final RemoteDataSourceRepository<UserModel> _userRepo;

  LoanController(this._loanRepo, this._userRepo);

  RxList<LoanRequestModel> loans = <LoanRequestModel>[].obs;

  final Rx<RequestState> getLoansState = RequestState.initial.obs;
  final Rx<RequestState> addLoanState = RequestState.initial.obs;
  final Rx<RequestState> updateLoanState = RequestState.initial.obs;
  final Rx<RequestState> deleteLoanState = RequestState.initial.obs;

  late String userId;
  late UserModel? user;

  final sharedPreferencesService = Get.find<SharedPreferencesService>();

  final RxDouble amount = 0.0.obs;
  final RxString reason = "".obs;

  @override
  void onInit() {
    super.onInit();
    userId = sharedPreferencesService.getString(AppConstants.userIdKey) ?? "";
    getUser();
    fetchLoans();
  }

  /// 🔥 Fetch loans
  Future<void> fetchLoans() async {
    getLoansState.value = RequestState.loading;

    final result = await _loanRepo.fetchWhere(
      queryFilters: [QueryFilter(field: 'userId', value: userId)],
    );

    result.fold(
      (failure) {
        getLoansState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (data) {
        loans.assignAll(data);
        getLoansState.value = RequestState.success;
      },
    );
  }

  Future<void> getUser() async {
    final userResult = await _userRepo.getById(userId);

    userResult.fold(
      (failure) {
        AppUIUtils.onFailure(failure.message);
      },
      (data) {
        user = data;
      },
    );
  }

  /// 🔥 Add Loan
  Future<void> addLoan() async {
    if (amount.value <= 0) {
      AppUIUtils.onFailure("الرجاء إدخال مبلغ صحيح");
      return;
    }

    addLoanState.value = RequestState.loading;

    final loan = LoanRequestModel(
      id: const Uuid().v4(),
      userId: userId,
      userName: user?.userName ?? "",
      amount: amount.value,
      reason: reason.value.trim(),
      status: LoanStatus.pending,
    );

    final result = await _loanRepo.save(loan);

    await result.fold(
      (failure) async {
        addLoanState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (savedLoan) async {
        final userResult = await _userRepo.getById(userId);

        await userResult.fold(
          (failure) async {
            addLoanState.value = RequestState.error;
            AppUIUtils.onFailure(failure.message);
          },
          (user) async {
            final updatedLoans = user.userLoanRequests ?? [];

            updatedLoans.add(
              UserLoanRequestModel(
                id: savedLoan.id,
                amount: savedLoan.amount,
                status: savedLoan.status,
              ),
            );

            final updatedUser = user.copyWith(userLoanRequests: updatedLoans);

            await _userRepo.save(updatedUser);

            loans.add(savedLoan);

            addLoanState.value = RequestState.success;

            Navigator.of(Get.context!).pop();

            AppUIUtils.onSuccess("تم إرسال طلب السلفة بنجاح");
          },
        );
      },
    );
  }

  /// 🔥 Update Loan
  Future<void> updateLoanStatus(
    String loanId,
    LoanStatus newStatus,
  ) async {
    updateLoanState.value = RequestState.loading;

    final loan = loans.firstWhereOrNull((e) => e.id == loanId);

    if (loan == null) return;

    loan.status = newStatus;

    /// 1️⃣ Update loan_requests collection
    final loanResult = await _loanRepo.save(loan);

    await loanResult.fold(
      (failure) async {
        updateLoanState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (_) async {
        /// 2️⃣ Update user array
        final userResult = await _userRepo.getById(userId);

        await userResult.fold(
          (failure) async {
            updateLoanState.value = RequestState.error;
            AppUIUtils.onFailure(failure.message);
          },
          (user) async {
            UserLoanRequestModel updatedLoan = UserLoanRequestModel(
              id: loanId,
              amount: loan.amount,
              status: newStatus,
            );

            List<UserLoanRequestModel>? updatedLoans = user.userLoanRequests
                ?.map((e) => (e.id == loanId ? updatedLoan : e))
                .toList();

            UserModel updatedUser =
                user.copyWith(userLoanRequests: updatedLoans);

            await _userRepo.save(updatedUser);

            /// 3️⃣ refresh local list
            loans.refresh();

            updateLoanState.value = RequestState.success;

            AppUIUtils.onSuccess("تم تحديث حالة الطلب");
          },
        );
      },
    );
  }

  /// 🔥 Delete Loan
  Future<void> deleteLoan(String loanId) async {
    deleteLoanState.value = RequestState.loading;

    final deleteResult = await _loanRepo.delete(loanId);

    await deleteResult.fold(
      (failure) async {
        deleteLoanState.value = RequestState.error;
        AppUIUtils.onFailure(failure.message);
      },
      (_) async {
        final userResult = await _userRepo.getById(userId);

        await userResult.fold(
          (failure) async {
            deleteLoanState.value = RequestState.error;
            AppUIUtils.onFailure(failure.message);
          },
          (user) async {
            final updatedLoans =
                user.userLoanRequests?.where((e) => e.id != loanId).toList();

            final updatedUser = user.copyWith(userLoanRequests: updatedLoans);

            await _userRepo.save(updatedUser);

            loans.removeWhere((e) => e.id == loanId);

            deleteLoanState.value = RequestState.success;

            AppUIUtils.onSuccess("تم حذف طلب السلفة");
          },
        );
      },
    );
  }
}
