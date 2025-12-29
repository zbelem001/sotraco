class MapboxConfig {
  // Clé API Mapbox - À remplacer par ta propre clé
  // Obtiens-en une gratuitement sur https://account.mapbox.com/
  // 50,000 chargements gratuits par mois
  static const String accessToken = 'pk.eyJ1IjoiemlhMTMiLCJhIjoiY21qbjhhN3pyMzJlaDNocXhkb3dwbXVzNiJ9.ROJrdQUfDD-mer7YaDlPKA';
  
  // Style de carte (tu peux personnaliser le tien sur Mapbox Studio)
  static const String styleUrl = 'mapbox://styles/mapbox/streets-v12';
  
  // Coordonnées par défaut (Ouagadougou)
  static const double defaultLatitude = 12.3714;
  static const double defaultLongitude = -1.5197;
  static const double defaultZoom = 13.0;
}
