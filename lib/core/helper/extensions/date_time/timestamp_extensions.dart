import 'package:cloud_firestore/cloud_firestore.dart';

extension TimestampExtensions on Timestamp {
  DateTime get toDate =>
      DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
}
