import 'package:location/location.dart';

class LocationService {
  final Location _location = Location();
  LocationData? _cachedLocation;

  Future<bool> initialize() async {
    bool serviceEnabled;
    PermissionStatus permission;

    // Check service
    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    // Check permission
    permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission != PermissionStatus.granted) return false;
    }

    return true;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      final loc = await _location.getLocation();

      // Location package sometimes returns null values!
      if (loc.latitude == null || loc.longitude == null) {
        return null; // Avoid null check operator errors
      }

      _cachedLocation = loc;
      return _cachedLocation;
    } catch (e) {
      return null;
    }
  }

  Future<double?> getLatitude() async {
    final data = await getCurrentLocation();
    return data?.latitude;
  }

  Future<double?> getLongitude() async {
    final data = await getCurrentLocation();
    return data?.longitude;
  }
}