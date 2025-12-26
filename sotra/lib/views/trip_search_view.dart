import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/routing_service.dart';
import '../services/geolocation_service.dart';
import '../models/user_model.dart';

class TripSearchView extends StatefulWidget {
  const TripSearchView({super.key});

  @override
  State<TripSearchView> createState() => _TripSearchViewState();
}

class _TripSearchViewState extends State<TripSearchView> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _routingService = RoutingService();
  final _geoService = GeolocationService();
  
  bool _isSearching = false;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  Future<void> _searchTrip() async {
    if (_startController.text.isEmpty || _endController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isSearching = true);

    // Utiliser la position actuelle ou des coordonnées fictives
    final start = await _geoService.getCurrentLocation() ??
        _geoService.currentLocation!;
    
    // Position fictive pour la destination (légèrement différente)
    final end = start.copyWith(
      latitude: start.latitude + 0.01,
      longitude: start.longitude + 0.01,
    );

    final trip = await _routingService.calculateTrip(start, end);

    setState(() {
      _isSearching = false;
    });

    if (trip != null && mounted) {
      Navigator.pushNamed(context, '/trip-result', arguments: trip);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher un trajet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Point de départ
            TextField(
              controller: _startController,
              decoration: const InputDecoration(
                labelText: 'Point de départ',
                hintText: 'Entrez une adresse ou un arrêt',
                prefixIcon: Icon(Icons.my_location, color: AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 16),
            // Bouton inverser
            Center(
              child: IconButton(
                icon: const Icon(Icons.swap_vert),
                onPressed: () {
                  final temp = _startController.text;
                  _startController.text = _endController.text;
                  _endController.text = temp;
                },
              ),
            ),
            const SizedBox(height: 16),
            // Point d'arrivée
            TextField(
              controller: _endController,
              decoration: const InputDecoration(
                labelText: 'Point d\'arrivée',
                hintText: 'Entrez une adresse ou un arrêt',
                prefixIcon: Icon(Icons.place, color: AppTheme.errorColor),
              ),
            ),
            const SizedBox(height: 24),
            // Bouton rechercher
            ElevatedButton.icon(
              onPressed: _isSearching ? null : _searchTrip,
              icon: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(_isSearching ? 'Recherche...' : 'Calculer l\'itinéraire'),
            ),
            const SizedBox(height: 24),
            // Suggestions rapides
            const Text(
              'Suggestions populaires',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickSuggestion('Place des Nations Unies', 'Université Ouaga 1'),
            _buildQuickSuggestion('Gare Routière', 'Marché Central'),
            _buildQuickSuggestion('Zone du Bois', 'Patte d\'Oie'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestion(String start, String end) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.directions, color: AppTheme.accentColor),
        title: Text(start),
        subtitle: Text('→ $end'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _startController.text = start;
          _endController.text = end;
        },
      ),
    );
  }
}
