import 'user_model.dart';
import 'stop_model.dart';

class BusModel {
  final String busId;
  final String lineId;
  final LocationModel? currentLocation;
  final String direction;
  final double speed;
  final DateTime lastUpdateTime;
  final bool isActive;

  BusModel({
    required this.busId,
    required this.lineId,
    this.currentLocation,
    required this.direction,
    this.speed = 0.0,
    required this.lastUpdateTime,
    this.isActive = true,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      busId: json['bus_id'] ?? '',
      lineId: json['line_id'] ?? '',
      currentLocation: json['current_location'] != null
          ? LocationModel.fromJson(json['current_location'])
          : null,
      direction: json['direction'] ?? '',
      speed: (json['speed'] ?? 0.0).toDouble(),
      lastUpdateTime: json['last_update_time'] != null
          ? DateTime.parse(json['last_update_time'])
          : DateTime.now(),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bus_id': busId,
      'line_id': lineId,
      'current_location': currentLocation?.toJson(),
      'direction': direction,
      'speed': speed,
      'last_update_time': lastUpdateTime.toIso8601String(),
      'is_active': isActive,
    };
  }

  Duration calculateETA(StopModel stop) {
    if (currentLocation == null || !isActive) {
      return Duration.zero;
    }
    
    final distance = currentLocation!.calculateDistance(stop.location);
    final averageSpeed = speed > 0 ? speed : 20.0; // 20 km/h par défaut
    final timeInHours = distance / (averageSpeed * 1000);
    
    return Duration(minutes: (timeInHours * 60).round());
  }

  BusModel copyWith({
    String? busId,
    String? lineId,
    LocationModel? currentLocation,
    String? direction,
    double? speed,
    DateTime? lastUpdateTime,
    bool? isActive,
  }) {
    return BusModel(
      busId: busId ?? this.busId,
      lineId: lineId ?? this.lineId,
      currentLocation: currentLocation ?? this.currentLocation,
      direction: direction ?? this.direction,
      speed: speed ?? this.speed,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      isActive: isActive ?? this.isActive,
    );
  }
}
