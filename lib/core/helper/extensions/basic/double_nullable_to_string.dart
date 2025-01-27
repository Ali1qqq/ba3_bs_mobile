extension DoubleNullableToString on double? {
  String toFixedString() {

    return this?.toString() ?? "0";
  }
}