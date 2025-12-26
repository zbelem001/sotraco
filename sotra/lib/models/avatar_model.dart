import 'user_model.dart';

enum VisibilityStatus {
  visible,
  friendsOnly,
  invisible,
}

class AvatarModel {
  final String avatarId;
  final String userId;
  final LocationModel? position;
  final VisibilityStatus visibilityStatus;
  final String? currentBusId;
  final String? currentStopId;

  AvatarModel({
    required this.avatarId,
    required this.userId,
    this.position,
    this.visibilityStatus = VisibilityStatus.friendsOnly,
    this.currentBusId,
    this.currentStopId,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) {
    return AvatarModel(
      avatarId: json['avatar_id'] ?? '',
      userId: json['user_id'] ?? '',
      position: json['position'] != null
          ? LocationModel.fromJson(json['position'])
          : null,
      visibilityStatus:
          VisibilityStatus.values[json['visibility_status'] ?? 1],
      currentBusId: json['current_bus_id'],
      currentStopId: json['current_stop_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_id': avatarId,
      'user_id': userId,
      'position': position?.toJson(),
      'visibility_status': visibilityStatus.index,
      'current_bus_id': currentBusId,
      'current_stop_id': currentStopId,
    };
  }

  bool isVisibleTo(String requestingUserId, List<String> friendsList) {
    switch (visibilityStatus) {
      case VisibilityStatus.visible:
        return true;
      case VisibilityStatus.friendsOnly:
        return friendsList.contains(requestingUserId) ||
            userId == requestingUserId;
      case VisibilityStatus.invisible:
        return userId == requestingUserId;
    }
  }

  AvatarModel copyWith({
    String? avatarId,
    String? userId,
    LocationModel? position,
    VisibilityStatus? visibilityStatus,
    String? currentBusId,
    String? currentStopId,
  }) {
    return AvatarModel(
      avatarId: avatarId ?? this.avatarId,
      userId: userId ?? this.userId,
      position: position ?? this.position,
      visibilityStatus: visibilityStatus ?? this.visibilityStatus,
      currentBusId: currentBusId ?? this.currentBusId,
      currentStopId: currentStopId ?? this.currentStopId,
    );
  }
}
