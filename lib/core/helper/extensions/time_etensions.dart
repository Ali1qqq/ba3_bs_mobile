import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension TimeEtensions on TimeOfDay {
  String formatToAmPm() {
    return DateFormat('hh:mm a').format(
      DateTime(0, 1, 1, hour, minute),
    );
  }
}
