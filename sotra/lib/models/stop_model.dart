import 'user_model.dart';

class StopModel {
  final String stopId;
  final String name;
  final LocationModel location;
  final List<String> linesServing;

  StopModel({
    required this.stopId,
    required this.name,
    required this.location,
    this.linesServing = const [],
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      stopId: json['stop_id'] ?? '',
      name: json['name'] ?? '',
      location: LocationModel.fromJson(json['location'] ?? {}),
      linesServing: List<String>.from(json['lines_serving'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stop_id': stopId,
      'name': name,
      'location': location.toJson(),
      'lines_serving': linesServing,
    };
  }

  static List<StopModel> getNearbyStops(
    LocationModel userLocation,
    List<StopModel> allStops,
    double radius,
  ) {
    return allStops.where((stop) {
      final distance = userLocation.calculateDistance(stop.location);
      return distance <= radius;
    }).toList()
      ..sort((a, b) {
        final distanceA = userLocation.calculateDistance(a.location);
        final distanceB = userLocation.calculateDistance(b.location);
        return distanceA.compareTo(distanceB);
      });
  }

  StopModel copyWith({
    String? stopId,
    String? name,
    LocationModel? location,
    List<String>? linesServing,
  }) {
    return StopModel(
      stopId: stopId ?? this.stopId,
      name: name ?? this.name,
      location: location ?? this.location,
      linesServing: linesServing ?? this.linesServing,
    );
  }
}
