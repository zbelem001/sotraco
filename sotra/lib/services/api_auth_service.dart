import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiAuthService {
  // Inscription
  static Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authRegister}'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'password': password,
          'name': displayName,
        }),
      ).timeout(ApiConfig.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Sauvegarder le token et les données utilisateur
        if (data['token'] != null) {
          await _saveToken(data['token']);
          if (data['user'] != null) {
            await _saveUserData(data['user']);
          }
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Erreur d\'inscription'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  // Connexion
  static Future<Map<String, dynamic>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authLogin}'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      ).timeout(ApiConfig.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Sauvegarder le token et les données utilisateur
        if (data['token'] != null) {
          await _saveToken(data['token']);
          if (data['user'] != null) {
            await _saveUserData(data['user']);
          }
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Erreur de connexion'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  // Connexion démo
  static Future<Map<String, dynamic>> demoLogin() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authDemo}'),
        headers: ApiConfig.headers,
      ).timeout(ApiConfig.connectTimeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Sauvegarder le token
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Erreur de connexion démo'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  // Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // Sauvegarder le token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Sauvegarder les données utilisateur
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  // Récupérer le token sauvegardé
  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
