import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/line_model.dart';
import '../../config/supabase_config.dart';
import 'package:flutter/material.dart';

class SupabaseLineService {
  final _supabase = Supabase.instance.client;
  
  // Récupérer toutes les lignes
  Future<List<LineModel>> getAllLines() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.linesTable)
          .select()
          .order('line_number');
      
      return (response as List)
          .map((json) => LineModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des lignes: $e');
      return [];
    }
  }
  
  // Récupérer une ligne par ID
  Future<LineModel?> getLineById(String lineId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.linesTable)
          .select()
          .eq('line_id', lineId)
          .single();
      
      return LineModel.fromJson(response);
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la ligne $lineId: $e');
      return null;
    }
  }
  
  // Rechercher des lignes par nom ou numéro
  Future<List<LineModel>> searchLines(String query) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.linesTable)
          .select()
          .or('line_name.ilike.%$query%,line_number.ilike.%$query%')
          .order('line_number');
      
      return (response as List)
          .map((json) => LineModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la recherche de lignes: $e');
      return [];
    }
  }
  
  // Stream temps réel des lignes (pour les mises à jour)
  Stream<List<LineModel>> getLinesStream() {
    return _supabase
        .from(SupabaseConfig.linesTable)
        .stream(primaryKey: ['line_id'])
        .order('line_number')
        .map((data) => data.map((json) => LineModel.fromJson(json)).toList());
  }
}
