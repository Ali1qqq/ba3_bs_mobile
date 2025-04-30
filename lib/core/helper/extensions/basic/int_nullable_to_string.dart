extension IntNullableToString on int? {
  String toFixedString() {
    return this?.toString() ?? "0";
  }
}
