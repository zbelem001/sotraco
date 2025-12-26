import '../models/user_model.dart';

class GeolocationService {
  LocationModel? _currentLocation;
  bool _isEnabled = false;

  // Position par défaut (Ouagadougou centre)
  final LocationModel _defaultLocation = LocationModel(
    latitude: 12.3714,
    longitude: -1.5197,
    timestamp: DateTime.now(),
  );

  LocationModel? get currentLocation => _currentLocation;
  bool get isEnabled => _isEnabled;

  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isEnabled = true;
    _currentLocation = _defaultLocation;
  }

  Future<LocationModel?> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (!_isEnabled) {
      return null;
    }

    // Simulation avec petites variations
    final random = DateTime.now().millisecond / 1000;
    _currentLocation = LocationModel(
      latitude: _defaultLocation.latitude + (random * 0.01),
      longitude: _defaultLocation.longitude + (random * 0.01),
      timestamp: DateTime.now(),
    );

    return _currentLocation;
  }

  Future<void> enableLocation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isEnabled = true;
  }

  Future<void> disableLocation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isEnabled = false;
  }

  double calculateDistance(LocationModel start, LocationModel end) {
    return start.calculateDistance(end);
  }

  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }
}
