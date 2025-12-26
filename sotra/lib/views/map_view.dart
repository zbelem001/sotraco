import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../data/mock_data.dart';
import '../models/line_model.dart';
import '../services/routing_service.dart';
import '../services/geolocation_service.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final _mockData = MockData();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _routingService = RoutingService();
  final _geoService = GeolocationService();
  
  LineModel? _selectedLine;
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
        const SnackBar(content: Text('Veuillez remplir le départ et l\'arrivée')),
      );
      return;
    }

    setState(() => _isSearching = true);

    final start = await _geoService.getCurrentLocation() ??
        _geoService.currentLocation!;
    
    final end = start.copyWith(
      latitude: start.latitude + 0.01,
      longitude: start.longitude + 0.01,
    );

    final trip = await _routingService.calculateTrip(start, end);

    setState(() => _isSearching = false);

    if (trip != null && mounted) {
      Navigator.pushNamed(context, '/trip-result', arguments: trip);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          // Barre de recherche intégrée
          _buildSearchBar(),
          // Carte
          Expanded(
            child: Stack(
              children: [
                // Carte simulée
                _buildMapPlaceholder(),
                // Panneau de filtrage
                if (_selectedLine != null) _buildLineFilterPanel(),
                // Boutons d'action flottants (sans recherche)
                _buildFloatingActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Champ départ
              Expanded(
                child: TextField(
                  controller: _startController,
                  decoration: InputDecoration(
                    hintText: 'Départ',
                    prefixIcon: const Icon(
                      Icons.my_location,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bouton inverser
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.swap_vert, size: 20),
                  onPressed: () {
                    final temp = _startController.text;
                    _startController.text = _endController.text;
                    _endController.text = temp;
                  },
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Champ arrivée
              Expanded(
                child: TextField(
                  controller: _endController,
                  decoration: InputDecoration(
                    hintText: 'Arrivée',
                    prefixIcon: const Icon(
                      Icons.place,
                      color: AppTheme.errorColor,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bouton itinéraire
              ElevatedButton.icon(
                onPressed: _isSearching ? null : _searchTrip,
                icon: _isSearching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.directions, size: 20),
                label: const Text('Itinéraire'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Stack(
        children: [
          // Fond de carte
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Carte Interactive',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lignes: ${_mockData.lines.length} • Arrêts: ${_mockData.stops.length}',
                  style: const TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
          ),
          // Lignes colorées sur la carte
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.route, size: 20, color: AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        'Lignes de transport',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Cartes des lignes
                ..._mockData.lines.map((line) => _buildLineCard(line)),
                const SizedBox(height: 8),
                // Bus en temps réel
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus, 
                        color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_mockData.buses.where((b) => b.isActive).length} bus actifs',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineCard(LineModel line) {
    final isSelected = _selectedLine?.lineId == line.lineId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? line.color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLine = isSelected ? null : line;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Indicateur coloré de ligne
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: line.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Informations de ligne
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${line.stopsList.length} arrêts • ${line.baseFare.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Icône de sélection
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? line.color : Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineFilterPanel() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: _selectedLine!.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedLine!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${_selectedLine!.stopsList.length} arrêts',
                    style: const TextStyle(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _selectedLine = null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton alertes
          FloatingActionButton(
            heroTag: 'alert',
            onPressed: () => Navigator.pushNamed(context, '/alerts'),
            backgroundColor: AppTheme.warningColor,
            child: const Icon(Icons.warning),
          ),
          const SizedBox(height: 12),
          // Bouton centrer position
          FloatingActionButton(
            heroTag: 'location',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Localisation centrée')),
              );
            },
            backgroundColor: AppTheme.accentColor,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Amadou Traoré',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '+226 70 12 34 56',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Carte'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Rechercher un trajet'),
            onTap: () {
              Navigator.pop(context);
  Navigator.pop(context);
              Navigator.pushNamed(context, '/alerts');
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Favoris'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Amis à proximité'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/avatars');
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: const Text('Cartes hors-ligne'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/offline-maps');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Administration'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
