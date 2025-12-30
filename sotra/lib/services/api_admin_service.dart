import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiAdminService {
  final String token;
  static const Duration _timeout = Duration(seconds: 15);
  
  ApiAdminService({required this.token});

  // Get admin statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/stats'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading stats: $e');
    }
  }

  // Get all users
  Future<Map<String, dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/users'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading users: $e');
    }
  }

  // Update user
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId'),
        headers: ApiConfig.headersWithAuth(token),
        body: json.encode(data),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/users/$userId'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // Get all lines
  Future<Map<String, dynamic>> getLines() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/lines'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load lines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading lines: $e');
    }
  }

  // Get all stops
  Future<Map<String, dynamic>> getStops() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/stops'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load stops: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading stops: $e');
    }
  }

  // Create line
  Future<Map<String, dynamic>> createLine(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/lines'),
        headers: ApiConfig.headersWithAuth(token),
        body: json.encode(data),
      ).timeout(_timeout);

      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': response.body};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Update line
  Future<bool> updateLine(String lineId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/admin/lines/$lineId'),
        headers: ApiConfig.headersWithAuth(token),
        body: json.encode(data),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating line: $e');
    }
  }

  // Delete line
  Future<bool> deleteLine(String lineId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/lines/$lineId'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting line: $e');
    }
  }

  // Create stop
  Future<Map<String, dynamic>> createStop(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/stops'),
        headers: ApiConfig.headersWithAuth(token),
        body: json.encode(data),
      ).timeout(_timeout);

      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': response.body};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Update stop
  Future<bool> updateStop(String stopId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/admin/stops/$stopId'),
        headers: ApiConfig.headersWithAuth(token),
        body: json.encode(data),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating stop: $e');
    }
  }

  // Delete stop
  Future<bool> deleteStop(String stopId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/stops/$stopId'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting stop: $e');
    }
  }

  // Add stop to line
  Future<bool> addStopToLine(String lineId, String stopId, int orderIndex) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/lines/$lineId/stops'),
        headers: ApiConfig.headersWithAuth(token),
        body: json.encode({
          'stop_id': stopId,
          'order_index': orderIndex,
        }),
      ).timeout(_timeout);

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error adding stop to line: $e');
    }
  }

  // Remove stop from line
  Future<bool> removeStopFromLine(String lineId, String stopId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/lines/$lineId/stops/$stopId'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error removing stop from line: $e');
    }
  }

  // Create bus
  Future<Map<String, dynamic>> createBus(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/buses'),
        headers: ApiConfig.headersWithAuth(token),
        body: json.encode(data),
      ).timeout(_timeout);

      if (response.statusCode == 201) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': response.body};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Update bus
  Future<bool> updateBus(String busId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/admin/buses/$busId'),
        headers: ApiConfig.headersWithAuth(token),
        body: json.encode(data),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating bus: $e');
    }
  }

  // Delete bus
  Future<bool> deleteBus(String busId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/buses/$busId'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting bus: $e');
    }
  }

  // Create user
  Future<bool> createUser(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/admin/users'),
        headers: ApiConfig.headersWithAuth(token),
        body: json.encode(data),
      ).timeout(_timeout);

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  // Get all alerts
  Future<Map<String, dynamic>> getAlerts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/admin/alerts'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load alerts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading alerts: $e');
    }
  }

  // Delete alert
  Future<bool> deleteAlert(String alertId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/admin/alerts/$alertId'),
        headers: ApiConfig.headersWithAuth(token),
      ).timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting alert: $e');
    }
  }
}
