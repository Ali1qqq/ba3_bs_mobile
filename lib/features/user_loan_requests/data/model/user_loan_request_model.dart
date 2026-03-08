import 'package:ba3_bs_mobile/features/user_loan_requests/data/model/loan_request_model.dart';

class UserLoanRequestModel {
  final String id;
  final double amount;
  final LoanStatus status;

  UserLoanRequestModel({
    this.id = '',
    this.amount = 0,
    this.status = LoanStatus.pending,
  });

  factory UserLoanRequestModel.fromJson(Map<String, dynamic> map) {
    return UserLoanRequestModel(
      id: map['docId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      status: LoanStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LoanStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docId': id,
      'amount': amount,
      'status': status.name,
    };
  }
}
