import 'package:ba3_bs_mobile/core/network/error/failure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/network/error/error_handler.dart';

class UserTimeRepository {
  DateTime getCurrentTime() => Timestamp.now().toDate();

  String getCurrentDayName() => getCurrentTime().toString().split(" ")[0];

  Future<Either<Failure, Position>> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return left(Failure(404, "site is not enabled")); // If the site is not enabled
      }

      // Check site permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return left(Failure(403, " permission is denied")); // If permission is denied
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return left(Failure(403, " permission is denied")); // If permission is permanently denied
      }

      // Get current location
      return right(
          await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high)));
    } catch (e) {
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
