import 'package:geocoding/geocoding.dart';
import '../models/user_model.dart';

class GeocodingService {
  // Rechercher une adresse et retourner les suggestions
  Future<List<Location>> searchLocation(String query) async {
    try {
      if (query.isEmpty) return [];
      
      // Rechercher des lieux correspondant à la requête
      // Note: geocoding package utilise des lieux réels, mais pour la démo
      // on peut aussi ajouter des lieux fictifs d'Ouagadougou
      final locations = await locationFromAddress(query);
      return locations;
    } catch (e) {
      // Si la recherche échoue, retourner des lieux fictifs pour Ouagadougou
      return _getMockLocations(query);
    }
  }

  // Obtenir l'adresse à partir des coordonnées
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}'
            .replaceAll(', ,', ',')
            .trim();
      }
      return 'Adresse inconnue';
    } catch (e) {
      return 'Adresse inconnue';
    }
  }

  // Convertir Location en LocationModel
  LocationModel locationToModel(Location location) {
    return LocationModel(
      latitude: location.latitude,
      longitude: location.longitude,
      timestamp: DateTime.now(),
    );
  }

  // Lieux fictifs pour Ouagadougou (en cas d'échec de l'API)
  List<Location> _getMockLocations(String query) {
    final mockPlaces = {
      'place des nations': Location(
        latitude: 12.3686,
        longitude: -1.5275,
        timestamp: DateTime.now(),
      ),
      'rond point': Location(
        latitude: 12.3686,
        longitude: -1.5275,
        timestamp: DateTime.now(),
      ),
      'centre': Location(
        latitude: 12.3714,
        longitude: -1.5197,
        timestamp: DateTime.now(),
      ),
      'gare': Location(
        latitude: 12.3650,
        longitude: -1.5280,
        timestamp: DateTime.now(),
      ),
      'marché': Location(
        latitude: 12.3700,
        longitude: -1.5200,
        timestamp: DateTime.now(),
      ),
      'université': Location(
        latitude: 12.4000,
        longitude: -1.4800,
        timestamp: DateTime.now(),
      ),
      'aéroport': Location(
        latitude: 12.3532,
        longitude: -1.5124,
        timestamp: DateTime.now(),
      ),
      'ouaga 2000': Location(
        latitude: 12.3300,
        longitude: -1.4900,
        timestamp: DateTime.now(),
      ),
      'somgandé': Location(
        latitude: 12.4100,
        longitude: -1.5000,
        timestamp: DateTime.now(),
      ),
      'gounghin': Location(
        latitude: 12.3800,
        longitude: -1.5100,
        timestamp: DateTime.now(),
      ),
    };

    final queryLower = query.toLowerCase();
    final results = <Location>[];

    mockPlaces.forEach((name, location) {
      if (name.contains(queryLower) || queryLower.contains(name)) {
        results.add(location);
      }
    });

    // Si aucun résultat, retourner le centre d'Ouagadougou
    if (results.isEmpty) {
      results.add(Location(
        latitude: 12.3714,
        longitude: -1.5197,
        timestamp: DateTime.now(),
      ));
    }

    return results;
  }
}
