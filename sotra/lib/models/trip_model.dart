import 'user_model.dart';
import 'route_model.dart';

class TripModel {
  final String tripId;
  final LocationModel startLocation;
  final LocationModel endLocation;
  final List<RouteModel> routes;
  final Duration estimatedTime;
  final double estimatedCost;

  TripModel({
    required this.tripId,
    required this.startLocation,
    required this.endLocation,
    this.routes = const [],
    required this.estimatedTime,
    required this.estimatedCost,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      tripId: json['trip_id'] ?? '',
      startLocation: LocationModel.fromJson(json['start_location'] ?? {}),
      endLocation: LocationModel.fromJson(json['end_location'] ?? {}),
      routes: (json['routes'] as List<dynamic>?)
              ?.map((route) => RouteModel.fromJson(route))
              .toList() ??
          [],
      estimatedTime: Duration(minutes: json['estimated_time'] ?? 0),
      estimatedCost: (json['estimated_cost'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'start_location': startLocation.toJson(),
      'end_location': endLocation.toJson(),
      'routes': routes.map((route) => route.toJson()).toList(),
      'estimated_time': estimatedTime.inMinutes,
      'estimated_cost': estimatedCost,
    };
  }

  String getSummary() {
    if (routes.isEmpty) {
      return 'Aucun itinéraire disponible';
    }

    final lines = routes.map((r) => r.line?.name ?? 'Inconnu').toSet().toList();
    final transfers = routes.length - 1;
    
    return '${lines.join(' → ')} • ${estimatedTime.inMinutes} min • ${estimatedCost.toStringAsFixed(0)} FCFA${transfers > 0 ? ' • $transfers correspondance${transfers > 1 ? 's' : ''}' : ''}';
  }

  TripModel copyWith({
    String? tripId,
    LocationModel? startLocation,
    LocationModel? endLocation,
    List<RouteModel>? routes,
    Duration? estimatedTime,
    double? estimatedCost,
  }) {
    return TripModel(
      tripId: tripId ?? this.tripId,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      routes: routes ?? this.routes,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      estimatedCost: estimatedCost ?? this.estimatedCost,
    );
  }
}
