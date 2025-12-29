import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/alert_model.dart';
import '../../config/supabase_config.dart';
import 'package:flutter/material.dart';

class SupabaseAlertService {
  final _supabase = Supabase.instance.client;
  
  // Récupérer toutes les alertes actives
  Future<List<AlertModel>> getActiveAlerts() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.alertsTable)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => AlertModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des alertes: $e');
      return [];
    }
  }
  
  // Récupérer les alertes d'une ligne
  Future<List<AlertModel>> getAlertsByLineId(String lineId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.alertsTable)
          .select()
          .eq('line_id', lineId)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => AlertModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des alertes de la ligne: $e');
      return [];
    }
  }
  
  // Créer une nouvelle alerte
  Future<bool> createAlert(AlertModel alert) async {
    try {
      await _supabase
          .from(SupabaseConfig.alertsTable)
          .insert(alert.toJson());
      
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la création de l\'alerte: $e');
      return false;
    }
  }
  
  // Stream temps réel des alertes
  Stream<List<AlertModel>> getAlertsStream({String? lineId}) {
    return _supabase
        .from(SupabaseConfig.alertsTable)
        .stream(primaryKey: ['alert_id'])
        .map((data) {
          // Filtrer les données
          var filtered = data.where((json) => json['is_active'] == true);
          if (lineId != null) {
            filtered = filtered.where((json) => json['line_id'] == lineId);
          }
          // Trier et convertir
          var list = filtered.toList();
          list.sort((a, b) => (b['created_at'] as String).compareTo(a['created_at'] as String));
          return list.map((json) => AlertModel.fromJson(json)).toList();
        });
  }
  
  // Marquer une alerte comme résolue
  Future<bool> resolveAlert(String alertId) async {
    try {
      await _supabase
          .from(SupabaseConfig.alertsTable)
          .update({'is_active': false})
          .eq('alert_id', alertId);
      
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la résolution de l\'alerte: $e');
      return false;
    }
  }
}
