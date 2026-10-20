import 'package:geolocator/geolocator.dart';
import '../core/network/api_client.dart';
import '../core/localization/app_locale.dart';
import 'system_notification_service.dart';

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

  /// Sends user GPS to backend geofencing engine to detect in-range partner stores
  Future<Map<String, dynamic>?> syncLocationWithBackend() async {
    try {
      Position? pos = await getCurrentLocation();
      double lat = pos?.latitude ?? 29.3759;
      double lng = pos?.longitude ?? 47.9774;

      final res = await ApiClient.instance.checkGeolocationProximity(lat, lng);
      if (res != null && (res["in_range_count"] as num? ?? 0) > 0) {
        final inRange = res["in_range_offers"] as List?;
        if (inRange != null && inRange.isNotEmpty) {
          final first = inRange.first as Map<String, dynamic>;
          final brand = first["brand_name"] ?? "Partner Store";
          final dist = (first["distance_meters"] as num?)?.round() ?? 50;
          final tag = first["discount_tag"] ?? "Exclusive Deal";
          await SystemNotificationService().showSystemNotification(
            id: 2001,
            title: isArabic ? "📍 $brand على بعد $dist م فقط!" : "📍 $brand is only $dist m away!",
            body: isArabic
                ? "$tag على جميع الطلبات. اضغط لفتح قسيمة وفرة بالرقم الوظيفي."
                : "$tag on all items. Tap to open Wafra voucher with your Worker ID.",
            payload: first["offer_id"]?.toString(),
          );
        }
      }
      return res;
    } catch (_) {
      return null;
    }
  }
}
