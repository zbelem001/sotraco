import 'user_model.dart';

enum AlertType {
  busFull,
  breakdown,
  accident,
  stopMoved,
  roadBlocked,
  other,
}

class AlertModel {
  final String alertId;
  final AlertType type;
  final String description;
  final LocationModel location;
  final String? lineId;
  final String createdBy;
  final DateTime timestamp;
  final Duration validityDuration;
  final int votes;

  AlertModel({
    required this.alertId,
    required this.type,
    required this.description,
    required this.location,
    this.lineId,
    required this.createdBy,
    required this.timestamp,
    this.validityDuration = const Duration(hours: 2),
    this.votes = 0,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      alertId: json['alert_id'] ?? '',
      type: AlertType.values[json['type'] ?? 0],
      description: json['description'] ?? '',
      location: LocationModel.fromJson(json['location'] ?? {}),
      lineId: json['line_id'],
      createdBy: json['created_by'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      validityDuration: Duration(minutes: json['validity_duration'] ?? 120),
      votes: json['votes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alert_id': alertId,
      'type': type.index,
      'description': description,
      'location': location.toJson(),
      'line_id': lineId,
      'created_by': createdBy,
      'timestamp': timestamp.toIso8601String(),
      'validity_duration': validityDuration.inMinutes,
      'votes': votes,
    };
  }

  bool isValid() {
    final expirationTime = timestamp.add(validityDuration);
    return DateTime.now().isBefore(expirationTime);
  }

  String getTypeLabel() {
    switch (type) {
      case AlertType.busFull:
        return 'Bus plein';
      case AlertType.breakdown:
        return 'Panne';
      case AlertType.accident:
        return 'Incident';
      case AlertType.stopMoved:
        return 'Arrêt déplacé';
      case AlertType.roadBlocked:
        return 'Route bloquée';
      case AlertType.other:
        return 'Autre';
    }
  }

  AlertModel copyWith({
    String? alertId,
    AlertType? type,
    String? description,
    LocationModel? location,
    String? lineId,
    String? createdBy,
    DateTime? timestamp,
    Duration? validityDuration,
    int? votes,
  }) {
    return AlertModel(
      alertId: alertId ?? this.alertId,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      lineId: lineId ?? this.lineId,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
      validityDuration: validityDuration ?? this.validityDuration,
      votes: votes ?? this.votes,
    );
  }
}
