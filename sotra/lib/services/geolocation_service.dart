import 'package:geolocator/geolocator.dart';
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
    await _checkLocationPermission();
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _isEnabled = false;
      return false;
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _isEnabled = false;
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _isEnabled = false;
      return false;
    }

    _isEnabled = true;
    return true;
  }

  Future<LocationModel?> getCurrentLocation() async {
    try {
      final hasPermission = await _checkLocationPermission();
      
      if (!hasPermission) {
        // Retourner la position par défaut si pas de permission
        _currentLocation = _defaultLocation;
        return _currentLocation;
      }

      // Obtenir la position GPS réelle
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLocation = LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
      );

      return _currentLocation;
    } catch (e) {
      // En cas d'erreur, retourner la position par défaut
      _currentLocation = _defaultLocation;
      return _currentLocation;
    }
  }

  Future<void> enableLocation() async {
    await _checkLocationPermission();
  }

  Future<void> disableLocation() async {
    _isEnabled = false;
  }

  // Obtenir la distance entre deux points
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
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
