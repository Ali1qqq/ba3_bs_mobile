class TargetModel {
  final double maxValue;
  final double minValue;
  final double midValue;

  TargetModel(this.maxValue, this.minValue, this.midValue);

  /// fromJson
  factory TargetModel.fromJson(Map<String, dynamic> json) {

    return TargetModel(
      (json['maxValue'] ??0).toDouble(),
      (json['minValue'] ??0).toDouble(),
      (json['midValue'] ??0).toDouble(),
    );
  }

  /// toJson
  Map<String, dynamic> toJson() {
    return {
      'maxValue': maxValue,
      'minValue': minValue,
      'midValue': midValue,
    };
  }

  /// copyWith
  TargetModel copyWith({
    double? maxValue,
    double? minValue,
    double? midValue,
  }) {
    return TargetModel(
      maxValue ?? this.maxValue,
      minValue ?? this.minValue,
      midValue ?? this.midValue,
    );
  }

  /// toString
  @override
  String toString() {
    return 'TargetModel(maxValue: $maxValue, minValue: $minValue, midValue: $midValue)';
  }
}