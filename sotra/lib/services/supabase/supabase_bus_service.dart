import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/bus_model.dart';
import '../../config/supabase_config.dart';
import 'package:flutter/material.dart';

class SupabaseBusService {
  final _supabase = Supabase.instance.client;
  
  // Récupérer tous les bus actifs
  Future<List<BusModel>> getActiveBuses() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.busesTable)
          .select()
          .eq('is_active', true)
          .order('bus_number');
      
      return (response as List)
          .map((json) => BusModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des bus actifs: $e');
      return [];
    }
  }
  
  // Récupérer les bus d'une ligne
  Future<List<BusModel>> getBusesByLineId(String lineId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.busesTable)
          .select()
          .eq('line_id', lineId)
          .eq('is_active', true)
          .order('bus_number');
      
      return (response as List)
          .map((json) => BusModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des bus de la ligne $lineId: $e');
      return [];
    }
  }
  
  // Stream temps réel des bus (position mise à jour)
  Stream<List<BusModel>> getBusesStream({String? lineId}) {
    return _supabase
        .from(SupabaseConfig.busesTable)
        .stream(primaryKey: ['bus_id'])
        .map((data) {
          // Filtrer les données
          var filtered = data.where((json) => json['is_active'] == true);
          if (lineId != null) {
            filtered = filtered.where((json) => json['line_id'] == lineId);
          }
          // Trier et convertir
          var list = filtered.toList();
          list.sort((a, b) => (a['bus_number'] as String).compareTo(b['bus_number'] as String));
          return list.map((json) => BusModel.fromJson(json)).toList();
        });
  }
  
  // Mettre à jour la position d'un bus (pour admin/chauffeur)
  Future<bool> updateBusLocation(String busId, double latitude, double longitude) async {
    try {
      await _supabase
          .from(SupabaseConfig.busesTable)
          .update({
            'current_latitude': latitude,
            'current_longitude': longitude,
            'last_updated': DateTime.now().toIso8601String(),
          })
          .eq('bus_id', busId);
      
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour de la position du bus: $e');
      return false;
    }
  }
}
