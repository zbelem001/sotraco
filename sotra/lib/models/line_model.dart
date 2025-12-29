import 'package:flutter/material.dart';

class LineModel {
  final String lineId;
  final String name;
  final Color color;
  final List<String> stopsList; // Liste des IDs d'arrêts
  final double averageSpeed;
  final double baseFare;

  LineModel({
    required this.lineId,
    required this.name,
    required this.color,
    this.stopsList = const [],
    this.averageSpeed = 25.0,
    this.baseFare = 200.0,
  });

  factory LineModel.fromJson(Map<String, dynamic> json) {
    return LineModel(
      lineId: json['line_id'] ?? '',
      name: json['name'] ?? '',
      color: Color(json['color'] ?? 0xFF2196F3),
      stopsList: List<String>.from(json['stops_list'] ?? []),
      averageSpeed: (json['average_speed'] ?? 25.0).toDouble(),
      baseFare: (json['base_fare'] ?? 200.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line_id': lineId,
      'name': name,
      'color': color.value,
      'stops_list': stopsList,
      'average_speed': averageSpeed,
      'base_fare': baseFare,
    };
  }

  List<String> getNextStops(String currentStopId) {
    final currentIndex = stopsList.indexOf(currentStopId);
    
    if (currentIndex == -1 || currentIndex == stopsList.length - 1) {
      return [];
    }
    
    return stopsList.sublist(currentIndex + 1);
  }

  double getFare() => baseFare;

  LineModel copyWith({
    String? lineId,
    String? name,
    Color? color,
    List<String>? stopsList,
    double? averageSpeed,
    double? baseFare,
  }) {
    return LineModel(
      lineId: lineId ?? this.lineId,
      name: name ?? this.name,
      color: color ?? this.color,
      stopsList: stopsList ?? this.stopsList,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      baseFare: baseFare ?? this.baseFare,
    );
  }
}
