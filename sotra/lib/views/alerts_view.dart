import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/alert_service.dart';
import '../models/alert_model.dart';

class AlertsView extends StatefulWidget {
  const AlertsView({super.key});

  @override
  State<AlertsView> createState() => _AlertsViewState();
}

class _AlertsViewState extends State<AlertsView> {
  final _alertService = AlertService();

  @override
  void initState() {
    super.initState();
    _alertService.loadMockAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _alertService.alerts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes communautaires'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: alerts.isEmpty
          ? const Center(
              child: Text('Aucune alerte active'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _buildAlertCard(alert);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAlertDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Signaler'),
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getAlertIcon(alert.type),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.getTypeLabel(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTimestamp(alert.timestamp),
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildVoteButtons(alert),
              ],
            ),
            const SizedBox(height: 8),
            Text(alert.description),
            if (alert.lineId != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Ligne: ${alert.lineId}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _getAlertIcon(AlertType type) {
    IconData icon;
    Color color;

    switch (type) {
      case AlertType.busFull:
        icon = Icons.people;
        color = AppTheme.warningColor;
        break;
      case AlertType.breakdown:
        icon = Icons.build;
        color = AppTheme.errorColor;
        break;
      case AlertType.accident:
        icon = Icons.warning;
        color = AppTheme.errorColor;
        break;
      case AlertType.stopMoved:
        icon = Icons.not_listed_location;
        color = AppTheme.accentColor;
        break;
      case AlertType.roadBlocked:
        icon = Icons.block;
        color = AppTheme.errorColor;
        break;
      default:
        icon = Icons.info;
        color = AppTheme.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildVoteButtons(AlertModel alert) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.thumb_up_outlined, size: 20),
          onPressed: () => _alertService.voteAlert(alert.alertId, true),
        ),
        Text('${alert.votes}'),
        IconButton(
          icon: const Icon(Icons.thumb_down_outlined, size: 20),
          onPressed: () => _alertService.voteAlert(alert.alertId, false),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }

  void _showCreateAlertDialog() {
    final types = AlertType.values;
    AlertType? selectedType;
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Créer une alerte'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<AlertType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type d\'alerte',
                  ),
                  items: types.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedType = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Décrivez la situation...',
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                // Créer l'alerte (simplifié)
                if (selectedType != null && descController.text.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alerte créée avec succès'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(AlertType type) {
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
}
