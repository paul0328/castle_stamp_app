import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double fenceRadiusMeter = 500.0;

  static String formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.toStringAsFixed(0)} m';
  }

  static bool isWithinFence(double cLat, double cLng, Position userPos) {
    double distance = Geolocator.distanceBetween(userPos.latitude, userPos.longitude, cLat, cLng);
    return distance <= fenceRadiusMeter;
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Permissions are denied.');
    }
    return await Geolocator.getCurrentPosition();
  }
}
