import '../models/alert_model.dart';
import '../models/user_model.dart';

class AlertService {
  final List<AlertModel> _alerts = [];

  List<AlertModel> get alerts => _alerts.where((a) => a.isValid()).toList();

  Future<void> createAlert(
    AlertType type,
    String description,
    LocationModel location,
    String userId, {
    String? lineId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final alert = AlertModel(
      alertId: 'alert_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      description: description,
      location: location,
      lineId: lineId,
      createdBy: userId,
      timestamp: DateTime.now(),
    );

    _alerts.add(alert);
  }

  Future<void> voteAlert(String alertId, bool upvote) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _alerts.indexWhere((a) => a.alertId == alertId);
    if (index != -1) {
      final alert = _alerts[index];
      _alerts[index] = alert.copyWith(
        votes: upvote ? alert.votes + 1 : alert.votes - 1,
      );
    }
  }

  Future<List<AlertModel>> getAlertsNearLocation(
    LocationModel location,
    double radiusInMeters,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return alerts.where((alert) {
      final distance = location.calculateDistance(alert.location);
      return distance <= radiusInMeters;
    }).toList();
  }

  Future<List<AlertModel>> getAlertsByLine(String lineId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return alerts.where((alert) => alert.lineId == lineId).toList();
  }

  Future<void> deleteAlert(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _alerts.removeWhere((a) => a.alertId == alertId);
  }

  void loadMockAlerts() {
    _alerts.addAll([
      AlertModel(
        alertId: 'alert_001',
        type: AlertType.busFull,
        description: 'Bus bondé, attente recommandée',
        location: LocationModel(
          latitude: 12.3714,
          longitude: -1.5197,
          timestamp: DateTime.now(),
        ),
        lineId: 'line_001',
        createdBy: 'user_001',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        votes: 5,
      ),
      AlertModel(
        alertId: 'alert_002',
        type: AlertType.breakdown,
        description: 'Panne mécanique, bus en attente de dépannage',
        location: LocationModel(
          latitude: 12.3654,
          longitude: -1.5327,
          timestamp: DateTime.now(),
        ),
        lineId: 'line_002',
        createdBy: 'user_002',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        votes: 12,
      ),
    ]);
  }
}
