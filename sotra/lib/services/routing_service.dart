import '../models/user_model.dart';
import '../models/trip_model.dart';
import '../models/route_model.dart';
import '../models/stop_model.dart';
import '../data/mock_data.dart';

class RoutingService {
  final MockData _mockData = MockData();

  Future<TripModel?> calculateTrip(
    LocationModel start,
    LocationModel end,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    // Trouver les arrêts les plus proches du départ et de l'arrivée
    final allStops = _mockData.stops;
    final startStop = _findNearestStop(start, allStops);
    final endStop = _findNearestStop(end, allStops);

    if (startStop == null || endStop == null) {
      return null;
    }

    // Trouver une ligne en commun ou avec correspondance
    final routes = _findBestRoutes(startStop, endStop);

    if (routes.isEmpty) {
      return null;
    }

    // Calculer le temps et le coût total
    Duration totalTime = Duration.zero;
    double totalCost = 0.0;

    for (var route in routes) {
      totalTime += route.calculateDuration();
      totalCost += route.calculateCost();
    }

    return TripModel(
      tripId: 'trip_${DateTime.now().millisecondsSinceEpoch}',
      startLocation: start,
      endLocation: end,
      routes: routes,
      estimatedTime: totalTime,
      estimatedCost: totalCost,
    );
  }

  StopModel? _findNearestStop(
    LocationModel location,
    List<StopModel> stops,
  ) {
    if (stops.isEmpty) return null;

    StopModel? nearest;
    double minDistance = double.infinity;

    for (var stop in stops) {
      final distance = location.calculateDistance(stop.location);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = stop;
      }
    }

    return nearest;
  }

  List<RouteModel> _findBestRoutes(
    StopModel startStop,
    StopModel endStop,
  ) {
    final lines = _mockData.lines;
    final routes = <RouteModel>[];

    // Chercher une ligne directe
    for (var line in lines) {
      final startStopId = startStop.stopId;
      final endStopId = endStop.stopId;
      
      if (line.stopsList.contains(startStopId) &&
          line.stopsList.contains(endStopId)) {
        final startIndex = line.stopsList.indexOf(startStopId);
        final endIndex = line.stopsList.indexOf(endStopId);

        if (endIndex > startIndex) {
          // Convertir les IDs en StopModel
          final stopIds = line.stopsList.sublist(startIndex, endIndex + 1);
          final stops = stopIds.map((id) {
            return _mockData.stops.firstWhere(
              (s) => s.stopId == id,
              orElse: () => _mockData.stops.first,
            );
          }).toList();
          
          routes.add(RouteModel(
            routeId: 'route_${DateTime.now().millisecondsSinceEpoch}',
            line: line,
            stopsSequence: stops,
            walkingDistance: 100.0,
          ));
          break;
        }
      }
    }

    // Si pas de ligne directe, proposer une correspondance (simplifié)
    if (routes.isEmpty && lines.length > 1) {
      final firstLine = lines[0];
      final secondLine = lines[1];

      // Convertir les IDs en StopModel pour la première ligne
      final firstLineStopIds = firstLine.stopsList.take(3).toList();
      final firstLineStops = firstLineStopIds.map((id) {
        return _mockData.stops.firstWhere(
          (s) => s.stopId == id,
          orElse: () => _mockData.stops.first,
        );
      }).toList();

      // Convertir les IDs en StopModel pour la deuxième ligne
      final secondLineStopIds = secondLine.stopsList.take(2).toList();
      final secondLineStops = secondLineStopIds.map((id) {
        return _mockData.stops.firstWhere(
          (s) => s.stopId == id,
          orElse: () => _mockData.stops.first,
        );
      }).toList();

      routes.add(RouteModel(
        routeId: 'route_1',
        line: firstLine,
        stopsSequence: firstLineStops,
        walkingDistance: 150.0,
      ));

      routes.add(RouteModel(
        routeId: 'route_2',
        line: secondLine,
        stopsSequence: secondLineStops,
        walkingDistance: 100.0,
      ));
    }

    return routes;
  }

  Future<List<StopModel>> getNearbyStops(
    LocationModel location,
    double radiusInMeters,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return StopModel.getNearbyStops(
      location,
      _mockData.stops,
      radiusInMeters,
    );
  }
}
