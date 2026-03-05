import 'package:cloud_firestore/cloud_firestore.dart';

class LeaveRequestModel {
  String id;
  String userId;
  String userName;

  String startDate;
  String endDate;
  LeaveType leaveType;
  LeaveStatus status;

  LeaveRequestModel({
    this.userName = '',
    this.id = '',
    this.userId = '',
    this.startDate = '',
    this.endDate = '',
    this.leaveType = LeaveType.sick,
    this.status = LeaveStatus.pending,
  });

  Map<String, dynamic> toJson() {
    return {
      'docId': id,
      'userId': userId,
      'userName': userName,
      'startDate': startDate,
      'endDate': endDate,
      'leaveType': leaveType.name,
      'status': status.name,
      'createdAt': Timestamp.now(),
    };
  }

  factory LeaveRequestModel.fromJson(Map<String, dynamic> map) {
    return LeaveRequestModel(
      id: map['docId'] ?? '',
      userId: map['userId'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      userName: map['userName'] ?? '',
      leaveType: LeaveType.values.firstWhere(
        (e) => e.name == map['leaveType'],
        orElse: () => LeaveType.sick,
      ),
      status: LeaveStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => LeaveStatus.pending,
      ),
    );
  }
}

enum LeaveType {
  sick,
  paid,
  unpaid,
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
}
