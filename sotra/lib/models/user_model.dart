class UserModel {
  final String userId;
  final String name;
  final String phoneNumber;
  final String? avatarId;
  final LocationModel? location;
  final bool isLocationEnabled;
  final double reliabilityScore;
  final List<String> friendsList;

  UserModel({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    this.avatarId,
    this.location,
    this.isLocationEnabled = false,
    this.reliabilityScore = 0.0,
    this.friendsList = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      avatarId: json['avatar_id'],
      location: json['location'] != null
          ? LocationModel.fromJson(json['location'])
          : null,
      isLocationEnabled: json['is_location_enabled'] ?? false,
      reliabilityScore: (json['reliability_score'] ?? 0.0).toDouble(),
      friendsList: List<String>.from(json['friends_list'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'avatar_id': avatarId,
      'location': location?.toJson(),
      'is_location_enabled': isLocationEnabled,
      'reliability_score': reliabilityScore,
      'friends_list': friendsList,
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? phoneNumber,
    String? avatarId,
    LocationModel? location,
    bool? isLocationEnabled,
    double? reliabilityScore,
    List<String>? friendsList,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarId: avatarId ?? this.avatarId,
      location: location ?? this.location,
      isLocationEnabled: isLocationEnabled ?? this.isLocationEnabled,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      friendsList: friendsList ?? this.friendsList,
    );
  }
}

class LocationModel {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  double calculateDistance(LocationModel other) {
    // Formule de Haversine simplifiée
    const double earthRadius = 6371000; // en mètres
    double dLat = _toRadians(other.latitude - latitude);
    double dLon = _toRadians(other.longitude - longitude);
    
    double a = (dLat / 2).abs() * (dLat / 2).abs() +
        latitude.abs() * other.latitude.abs() *
        (dLon / 2).abs() * (dLon / 2).abs();
    double c = 2 * (a < 0 ? -1 : 1) * (a.abs() > 1 ? 1 : a.abs());
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * 3.141592653589793 / 180;
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
