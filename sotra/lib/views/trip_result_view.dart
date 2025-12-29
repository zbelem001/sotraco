import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../models/trip_model.dart';
import '../models/route_model.dart';

class TripResultView extends StatelessWidget {
  const TripResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)!.settings.arguments as TripModel?;

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Itinéraire')),
        body: const Center(child: Text('Aucun itinéraire disponible')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre itinéraire'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ajouté aux favoris')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Résumé du trajet
            Card(
              color: AppTheme.primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          Icons.access_time,
                          '${trip.estimatedTime.inMinutes} min',
                          'Durée',
                        ),
                        _buildSummaryItem(
                          Icons.payments,
                          '${trip.estimatedCost.toStringAsFixed(0)} FCFA',
                          'Coût',
                        ),
                        _buildSummaryItem(
                          Icons.transfer_within_a_station,
                          '${trip.routes.length - 1}',
                          'Correspondances',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Détails des routes
            const Text(
              'Itinéraire détaillé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...trip.routes.asMap().entries.map((entry) {
              final index = entry.key;
              final route = entry.value;
              return Column(
                children: [
                  _buildRouteCard(route, index + 1),
                  if (index < trip.routes.length - 1)
                    _buildTransferIndicator(),
                ],
              );
            }),
            const SizedBox(height: 24),
            // Bouton démarrer
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/map');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigation démarrée'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              icon: const Icon(Icons.navigation),
              label: const Text('Démarrer la navigation'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(RouteModel route, int stepNumber) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: route.line?.color ?? AppTheme.primaryColor,
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.line?.name ?? 'Marche à pied',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${route.stopsSequence.length} arrêts • ${route.calculateDuration().inMinutes} min',
                        style: const TextStyle(
                          color: AppTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${route.calculateCost().toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            if (route.stopsSequence.isNotEmpty) ...[
              const Divider(height: 24),
              ...route.stopsSequence.map((stop) => Padding(
                    padding: const EdgeInsets.only(left: 48, bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8),
                        const SizedBox(width: 12),
                        Text(stop.name),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransferIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 32),
          Container(
            width: 2,
            height: 30,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 12),
          const Text(
            'Correspondance',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
