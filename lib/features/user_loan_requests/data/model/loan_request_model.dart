import 'package:cloud_firestore/cloud_firestore.dart';

class LoanRequestModel {
  String id;
  String userId;
  String userName;

  double amount;
  String reason;

  LoanStatus status;
  DateTime? createdAt;

  LoanRequestModel({
    this.id = '',
    this.userId = '',
    this.userName = '',
    this.amount = 0,
    this.reason = '',
    this.status = LoanStatus.pending,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'docId': id,
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'reason': reason,
      'status': status.name,
      'createdAt': Timestamp.now(),
    };
  }

  factory LoanRequestModel.fromJson(Map<String, dynamic> map) {
    return LoanRequestModel(
      id: map['docId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      reason: map['reason'] ?? '',
      createdAt: map['createdAt']?.toDate(),
      status: LoanStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LoanStatus.pending,
      ),
    );
  }
}

enum LoanStatus {
  pending,
  approved,
  rejected,
  repaid,
}
