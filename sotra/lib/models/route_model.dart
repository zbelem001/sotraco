import 'line_model.dart';
import 'stop_model.dart';

class RouteModel {
  final String routeId;
  final LineModel? line;
  final List<StopModel> stopsSequence;
  final double walkingDistance;

  RouteModel({
    required this.routeId,
    this.line,
    this.stopsSequence = const [],
    this.walkingDistance = 0.0,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      routeId: json['route_id'] ?? '',
      line: json['line'] != null ? LineModel.fromJson(json['line']) : null,
      stopsSequence: (json['stops_sequence'] as List<dynamic>?)
              ?.map((stop) => StopModel.fromJson(stop))
              .toList() ??
          [],
      walkingDistance: (json['walking_distance'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'line': line?.toJson(),
      'stops_sequence': stopsSequence.map((stop) => stop.toJson()).toList(),
      'walking_distance': walkingDistance,
    };
  }

  Duration calculateDuration() {
    if (line == null || stopsSequence.length < 2) {
      return Duration.zero;
    }

    double totalDistance = 0;
    for (int i = 0; i < stopsSequence.length - 1; i++) {
      totalDistance += stopsSequence[i]
          .location
          .calculateDistance(stopsSequence[i + 1].location);
    }

    // Ajouter le temps de marche
    final walkingTime = walkingDistance / 1.4; // 1.4 m/s vitesse de marche
    final busTime = (totalDistance / 1000) / line!.averageSpeed * 3600;

    return Duration(seconds: (walkingTime + busTime).round());
  }

  double calculateCost() {
    return line?.baseFare ?? 0.0;
  }

  RouteModel copyWith({
    String? routeId,
    LineModel? line,
    List<StopModel>? stopsSequence,
    double? walkingDistance,
  }) {
    return RouteModel(
      routeId: routeId ?? this.routeId,
      line: line ?? this.line,
      stopsSequence: stopsSequence ?? this.stopsSequence,
      walkingDistance: walkingDistance ?? this.walkingDistance,
    );
  }
}
