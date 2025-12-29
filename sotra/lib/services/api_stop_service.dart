import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stop_model.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class ApiStopService {
  final String token;

  ApiStopService({required this.token});

  Map<String, String> get _headers => ApiConfig.headersWithAuth(token);

  // Récupérer tous les arrêts
  Future<List<StopModel>> getAllStops() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.stops}'),
        headers: _headers,
      ).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final stopsJson = data['stops'] as List;
        
        return stopsJson.map((json) => StopModel(
          stopId: (json['stop_id'] ?? '').toString(),
          name: json['stop_name'] ?? json['name'] ?? '',
          location: LocationModel(
            latitude: (json['latitude'] ?? 0.0).toDouble(),
            longitude: (json['longitude'] ?? 0.0).toDouble(),
            timestamp: DateTime.now(),
          ),
          linesServing: [],
        )).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur getAllStops: $e');
      return [];
    }
  }

  // Récupérer les arrêts proches
  Future<List<Map<String, dynamic>>> getNearbyStops({
    required double latitude,
    required double longitude,
    double radius = 1.0,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.stopsNearby}')
          .replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      });

      final response = await http.get(uri, headers: _headers)
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final stops = data['stops'] as List;
        
        return stops.map((json) => {
          'stop': StopModel(
            stopId: (json['stop_id'] ?? '').toString(),
            name: json['stop_name'] ?? json['name'] ?? '',
            location: LocationModel(
              latitude: (json['latitude'] ?? 0.0).toDouble(),
              longitude: (json['longitude'] ?? 0.0).toDouble(),
              timestamp: DateTime.now(),
            ),
            linesServing: [],
          ),
          'distance': (json['distance'] ?? 0.0).toDouble(),
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erreur getNearbyStops: $e');
      return [];
    }
  }

  // Récupérer un arrêt par ID
  Future<Map<String, dynamic>?> getStopById(String stopId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.stopById(stopId)}'),
        headers: _headers,
      ).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return {
          'stop': StopModel(
            stopId: (data['stop_id'] ?? '').toString(),
            name: data['stop_name'] ?? data['name'] ?? '',
            location: LocationModel(
              latitude: (data['latitude'] ?? 0.0).toDouble(),
              longitude: (data['longitude'] ?? 0.0).toDouble(),
              timestamp: DateTime.now(),
            ),
            linesServing: [],
          ),
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur getStopById: $e');
      return null;
    }
  }
}
