import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Check permissions and get current GPS location
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Calculate distance in meters & check if within 0-1000m range
  bool isWithinProximity({
    required double userLat,
    required double userLng,
    required double branchLat,
    required double branchLng,
    double maxDistanceMeters = 1000,
  }) {
    double distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      branchLat,
      branchLng,
    );
    return distanceInMeters <= maxDistanceMeters;
  }
}
