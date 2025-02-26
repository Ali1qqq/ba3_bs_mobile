class AttendanceData {
  final String date;
  final List<DateTime> logInTimes;
  final List<DateTime> logOutTimes;

  AttendanceData({required this.date, required this.logInTimes, required this.logOutTimes});

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      date: json['dayName'],
      logInTimes: (json['logInDateList'] as List?)?.map((e) => DateTime.parse(e)).toList() ?? [],
      logOutTimes: (json['logOutDateList'] as List?)?.map((e) => DateTime.parse(e)).toList() ?? [],
    );
  }
}

class DelayData {
  final double delayIn;
  final double delayOut;

  DelayData({required this.delayIn, required this.delayOut});
}

class AttendanceRecord {
  final String date;
  final double totalHours;
  final List<DelayData> delays;

  AttendanceRecord({
    required this.date,
    required this.totalHours,
    required this.delays,
  });
}