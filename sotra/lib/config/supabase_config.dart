class SupabaseConfig {
  // Configuration Supabase
  // Trouvez ces valeurs dans : Settings > API de votre projet Supabase
  
  // URL du projet (Project URL)
  static const String supabaseUrl = 'https://aviancbdngiqgzehhtgt.supabase.co';
  
  // Clé publique anonyme (anon/public key)
  static const String supabaseAnonKey = 'sb_publishable_lAOAUMooUr_iil3serJxzg_zhsmhsIq';
  
  // Noms des tables (assurez-vous qu'elles existent dans votre BD)
  static const String linesTable = 'lines';
  static const String stopsTable = 'stops';
  static const String busesTable = 'buses';
  static const String alertsTable = 'alerts';
  static const String usersTable = 'users';
  static const String favoritesTable = 'favorites';
}
