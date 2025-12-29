import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/line_model.dart';
import '../config/api_config.dart';

class ApiLineService {
  final String token;

  ApiLineService({required this.token});

  Map<String, String> get _headers => ApiConfig.headersWithAuth(token);

  // Récupérer toutes les lignes
  Future<List<LineModel>> getAllLines() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lines}'),
        headers: _headers,
      ).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final linesJson = data['lines'] as List;
        
        return linesJson.map((json) => LineModel(
          lineId: (json['line_id'] ?? '').toString(),
          name: json['line_name'] ?? json['name'] ?? '',
          color: _parseColor(json['color']),
          stopsList: [],
          averageSpeed: 25.0,
          baseFare: 200.0,
        )).toList();
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur getAllLines: $e');
      return [];
    }
  }

  // Récupérer une ligne par ID
  Future<LineModel?> getLineById(String lineId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lineById(lineId)}'),
        headers: _headers,
      ).timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['line'];
        
        return LineModel(
          lineId: (data['line_id'] ?? '').toString(),
          name: data['line_name'] ?? data['name'] ?? '',
          color: _parseColor(data['color']),
          stopsList: [],
          averageSpeed: 25.0,
          baseFare: 200.0,
        );
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur getLineById: $e');
      return null;
    }
  }

  // Créer une ligne (admin)
  Future<Map<String, dynamic>> createLine(Map<String, dynamic> lineData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lines}'),
        headers: _headers,
        body: jsonEncode(lineData),
      ).timeout(ApiConfig.connectTimeout);

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201,
        'data': data,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Color _parseColor(dynamic colorValue) {
    if (colorValue == null) return const Color(0xFF2196F3);
    
    try {
      if (colorValue is String) {
        String hex = colorValue.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      }
      return const Color(0xFF2196F3);
    } catch (e) {
      return const Color(0xFF2196F3);
    }
  }
}
