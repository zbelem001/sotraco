import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/stop_model.dart';
import '../../models/user_model.dart';
import '../../config/supabase_config.dart';
import 'package:flutter/material.dart';

class SupabaseStopService {
  final _supabase = Supabase.instance.client;
  
  // Récupérer tous les arrêts
  Future<List<StopModel>> getAllStops() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.stopsTable)
          .select()
          .order('stop_name');
      
      return (response as List)
          .map((json) => StopModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des arrêts: $e');
      return [];
    }
  }
  
  // Récupérer les arrêts d'une ligne
  Future<List<StopModel>> getStopsByLineId(String lineId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.stopsTable)
          .select()
          .contains('line_ids', [lineId])
          .order('stop_name');
      
      return (response as List)
          .map((json) => StopModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des arrêts de la ligne $lineId: $e');
      return [];
    }
  }
  
  // Rechercher des arrêts proches d'une position (utilise PostGIS)
  Future<List<StopModel>> getNearbyStops(LocationModel userLocation, {double radiusKm = 1.0}) async {
    try {
      // Utilise la fonction PostGIS ST_DWithin pour recherche géospatiale
      final response = await _supabase
          .rpc('get_nearby_stops', params: {
            'lat': userLocation.latitude,
            'lng': userLocation.longitude,
            'radius_km': radiusKm,
          });
      
      return (response as List)
          .map((json) => StopModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la recherche d\'arrêts proches: $e');
      return [];
    }
  }
  
  // Rechercher des arrêts par nom
  Future<List<StopModel>> searchStops(String query) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.stopsTable)
          .select()
          .ilike('stop_name', '%$query%')
          .order('stop_name');
      
      return (response as List)
          .map((json) => StopModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la recherche d\'arrêts: $e');
      return [];
    }
  }
  
  // Stream temps réel des arrêts
  Stream<List<StopModel>> getStopsStream() {
    return _supabase
        .from(SupabaseConfig.stopsTable)
        .stream(primaryKey: ['stop_id'])
        .order('stop_name')
        .map((data) => data.map((json) => StopModel.fromJson(json)).toList());
  }
}
