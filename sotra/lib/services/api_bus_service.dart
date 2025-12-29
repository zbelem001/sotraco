import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bus_model.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class ApiBusService {
  final String token;

  ApiBusService({required this.token});

  Map<String, String> get _headers => ApiConfig.headersWithAuth(token);

  // Récupérer tous les bus
  Future<List<BusModel>> getAllBuses() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.buses}'),
        headers: _headers,
      ).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final busesJson = data['buses'] as List;
        
        return busesJson.map((json) => BusModel(
          busId: (json['bus_id'] ?? '').toString(),
          lineId: (json['line_id'] ?? '').toString(),
          currentLocation: json['latitude'] != null && json['longitude'] != null
              ? LocationModel(
                  latitude: (json['latitude'] ?? 0.0).toDouble(),
                  longitude: (json['longitude'] ?? 0.0).toDouble(),
                  timestamp: DateTime.now(),
                )
              : null,
          direction: json['direction'] ?? '',
          speed: (json['speed'] ?? 0.0).toDouble(),
          lastUpdateTime: json['last_update'] != null
              ? DateTime.parse(json['last_update'])
              : DateTime.now(),
          isActive: json['is_active'] ?? true,
        )).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur getAllBuses: $e');
      return [];
    }
  }

  // Récupérer les bus proches
  Future<List<Map<String, dynamic>>> getNearbyBuses({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.busesNearby}')
          .replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      });

      final response = await http.get(uri, headers: _headers)
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final buses = data['buses'] as List;
        
        return buses.map((json) => {
          'bus': BusModel(
            busId: (json['bus_id'] ?? '').toString(),
            lineId: (json['line_id'] ?? '').toString(),
            currentLocation: json['latitude'] != null && json['longitude'] != null
                ? LocationModel(
                    latitude: (json['latitude'] ?? 0.0).toDouble(),
                    longitude: (json['longitude'] ?? 0.0).toDouble(),
                    timestamp: DateTime.now(),
                  )
                : null,
            direction: json['direction'] ?? '',
            speed: (json['speed'] ?? 0.0).toDouble(),
            lastUpdateTime: json['last_update'] != null
                ? DateTime.parse(json['last_update'])
                : DateTime.now(),
            isActive: json['is_active'] ?? true,
          ),
          'distance': (json['distance'] ?? 0.0).toDouble(),
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erreur getNearbyBuses: $e');
      return [];
    }
  }

  // Mettre à jour la position d'un bus
  Future<BusModel?> updateBusLocation({
    required String busId,
    required double latitude,
    required double longitude,
    double? speed,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.busLocation(busId)}'),
        headers: _headers,
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          if (speed != null) 'speed': speed,
        }),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final location = data['location'];
        
        return BusModel(
          busId: (data['bus_id'] ?? busId).toString(),
          lineId: (data['line_id'] ?? '').toString(),
          currentLocation: location != null
              ? LocationModel(
                  latitude: (location['latitude'] ?? latitude).toDouble(),
                  longitude: (location['longitude'] ?? longitude).toDouble(),
                  timestamp: DateTime.now(),
                )
              : null,
          direction: data['direction'] ?? '',
          speed: (location?['speed'] ?? speed ?? 0.0).toDouble(),
          lastUpdateTime: location?['timestamp'] != null
              ? DateTime.parse(location['timestamp'])
              : DateTime.now(),
          isActive: data['is_active'] ?? true,
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur updateBusLocation: $e');
      return null;
    }
  }
}
