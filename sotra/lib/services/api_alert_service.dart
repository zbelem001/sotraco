import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alert_model.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

class ApiAlertService {
  final String token;

  ApiAlertService({required this.token});

  Map<String, String> get _headers => ApiConfig.headersWithAuth(token);

  // Récupérer toutes les alertes
  Future<List<AlertModel>> getAllAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.alerts}'),
        headers: _headers,
      ).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final alertsJson = data['alerts'] as List;
        
        return alertsJson.map((json) => AlertModel(
          alertId: (json['alert_id'] ?? '').toString(),
          type: _parseAlertType(json['alert_type']),
          description: json['description'] ?? '',
          location: LocationModel(
            latitude: (json['latitude'] ?? 0.0).toDouble(),
            longitude: (json['longitude'] ?? 0.0).toDouble(),
            timestamp: DateTime.now(),
          ),
          lineId: json['line_id']?.toString(),
          createdBy: (json['user_id'] ?? '').toString(),
          timestamp: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
          validityDuration: json['expires_at'] != null
              ? DateTime.parse(json['expires_at']).difference(
                  json['created_at'] != null 
                      ? DateTime.parse(json['created_at'])
                      : DateTime.now()
                )
              : const Duration(hours: 2),
          votes: json['votes'] ?? 0,
        )).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur getAllAlerts: $e');
      return [];
    }
  }

  // Récupérer les alertes proches
  Future<List<Map<String, dynamic>>> getNearbyAlerts({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.alertsNearby}')
          .replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      });

      final response = await http.get(uri, headers: _headers)
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final alerts = data['alerts'] as List;
        
        return alerts.map((json) => {
          'alert': AlertModel(
            alertId: (json['alert_id'] ?? '').toString(),
            type: _parseAlertType(json['alert_type']),
            description: json['description'] ?? '',
            location: LocationModel(
              latitude: (json['latitude'] ?? 0.0).toDouble(),
              longitude: (json['longitude'] ?? 0.0).toDouble(),
              timestamp: DateTime.now(),
            ),
            lineId: json['line_id']?.toString(),
            createdBy: (json['user_id'] ?? '').toString(),
            timestamp: json['created_at'] != null
                ? DateTime.parse(json['created_at'])
                : DateTime.now(),
            validityDuration: const Duration(hours: 2),
            votes: json['votes'] ?? 0,
          ),
          'distance': (json['distance'] ?? 0.0).toDouble(),
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erreur getNearbyAlerts: $e');
      return [];
    }
  }

  // Créer une alerte
  Future<AlertModel?> createAlert({
    required AlertType type,
    required String description,
    required double latitude,
    required double longitude,
    String? lineId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.alerts}'),
        headers: _headers,
        body: jsonEncode({
          'alert_type': type.toString().split('.').last,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          if (lineId != null) 'line_id': lineId,
        }),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body)['alert'];
        
        return AlertModel(
          alertId: (data['alert_id'] ?? '').toString(),
          type: type,
          description: description,
          location: LocationModel(
            latitude: latitude,
            longitude: longitude,
            timestamp: DateTime.now(),
          ),
          lineId: lineId,
          createdBy: data['user_id'] ?? '',
          timestamp: DateTime.now(),
          validityDuration: const Duration(hours: 2),
          votes: 0,
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur createAlert: $e');
      return null;
    }
  }

  // Voter pour une alerte
  Future<bool> voteAlert({
    required String alertId,
    required String voteType, // 'confirm' ou 'deny'
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.alertVote(alertId)}'),
        headers: _headers,
        body: jsonEncode({
          'vote_type': voteType,
        }),
      ).timeout(ApiConfig.connectTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Erreur voteAlert: $e');
      return false;
    }
  }

  AlertType _parseAlertType(String? type) {
    if (type == null) return AlertType.other;
    
    switch (type) {
      case 'bus_full':
        return AlertType.busFull;
      case 'breakdown':
        return AlertType.breakdown;
      case 'accident':
        return AlertType.accident;
      case 'stop_moved':
        return AlertType.stopMoved;
      case 'road_blocked':
        return AlertType.roadBlocked;
      default:
        return AlertType.other;
    }
  }
}
