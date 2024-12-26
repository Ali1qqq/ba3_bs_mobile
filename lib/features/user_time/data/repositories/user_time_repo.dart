import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_strings.dart';

class UserTimeRepository {



  bool isWithinRegion(Position location, double targetLatitude, double targetLongitude, double radiusInMeters) {
    double distanceInMeters = Geolocator.distanceBetween(
      location.latitude,
      location.longitude,
      targetLatitude,
      targetLongitude,
    );

    return distanceInMeters <= radiusInMeters;
  }

  Future<bool> checkLogin() async {
    Position? location = await getCurrentLocation();

    if (location != null) {
      return isWithinRegion(location, AppStrings.targetLatitude, AppStrings.targetLongitude, AppStrings.radiusInMeters);
    } else {
      // can't get location
      return false;
    }
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null; // If the site is not enabled
    }

    // Check site permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null; // If permission is denied
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null; // If permission is permanently denied
    }

    // Get current location
    return await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
  }






}
