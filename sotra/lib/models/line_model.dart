import 'package:flutter/material.dart';
import 'stop_model.dart';

class LineModel {
  final String lineId;
  final String name;
  final Color color;
  final List<StopModel> stopsList;
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
      stopsList: (json['stops_list'] as List<dynamic>?)
              ?.map((stop) => StopModel.fromJson(stop))
              .toList() ??
          [],
      averageSpeed: (json['average_speed'] ?? 25.0).toDouble(),
      baseFare: (json['base_fare'] ?? 200.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line_id': lineId,
      'name': name,
      'color': color.value,
      'stops_list': stopsList.map((stop) => stop.toJson()).toList(),
      'average_speed': averageSpeed,
      'base_fare': baseFare,
    };
  }

  List<StopModel> getNextStops(StopModel currentStop) {
    final currentIndex = stopsList.indexWhere(
      (stop) => stop.stopId == currentStop.stopId,
    );
    
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
    List<StopModel>? stopsList,
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
