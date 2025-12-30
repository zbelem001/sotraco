import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../utils/app_theme.dart';
import '../data/mock_data.dart';
import '../models/line_model.dart';
import '../models/user_model.dart';
import '../services/geolocation_service.dart';
import '../services/api_auth_service.dart';
import '../config/mapbox_config.dart';
import '../providers/user_provider.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final _mockData = MockData();
  final _destinationController = TextEditingController();
  final _geoService = GeolocationService();
  
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _stopAnnotationManager;
  PointAnnotationManager? _busAnnotationManager;
  PointAnnotationManager? _userAnnotationManager;
  PolylineAnnotationManager? _routeAnnotationManager;
  
  LineModel? _selectedLine;
  bool _isSearching = false;
  LocationModel? _userLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    // Charger la ligne sélectionnée si passée en argument
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['selectedLine'] != null) {
        setState(() {
          _selectedLine = args['selectedLine'] as LineModel;
        });
        _updateMapAnnotations();
      }
    });
  }

  Future<void> _initializeLocation() async {
    await _geoService.initialize();
    await _updateUserLocation();
  }

  Future<void> _updateUserLocation() async {
    setState(() => _isLoadingLocation = true);
    
    final location = await _geoService.getCurrentLocation();
    
    setState(() {
      _userLocation = location;
      _isLoadingLocation = false;
    });

    if (location != null && mounted) {
      // Centrer la carte sur la position de l'utilisateur
      _mapboxMap?.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(location.longitude, location.latitude),
          ),
          zoom: 15.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
      
      // Mettre à jour le marqueur utilisateur
      _updateUserMarker();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Localisation activée'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    
    // Créer les gestionnaires d'annotations
    _stopAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    _busAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    _userAnnotationManager = await mapboxMap.annotations.createPointAnnotationManager();
    _routeAnnotationManager = await mapboxMap.annotations.createPolylineAnnotationManager();
    
    // Ajouter les marqueurs initiaux
    _updateMapAnnotations();
  }

  Future<void> _updateMapAnnotations() async {
    if (_stopAnnotationManager == null) return;
    
    // Nettoyer les annotations existantes
    await _stopAnnotationManager?.deleteAll();
    await _busAnnotationManager?.deleteAll();
    await _routeAnnotationManager?.deleteAll();
    
    // Obtenir les arrêts à afficher
    final stopsToShow = _selectedLine != null
        ? _mockData.stops
            .where((stop) => _selectedLine!.stopsList.contains(stop.stopId))
            .toList()
        : _mockData.stops;
    
    // Ajouter les marqueurs d'arrêts
    for (final stop in stopsToShow) {
      final isOnSelectedLine = _selectedLine != null &&
          _selectedLine!.stopsList.contains(stop.stopId);
      
      await _stopAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              stop.location.longitude,
              stop.location.latitude,
            ),
          ),
          iconSize: 0.8,
          iconColor: isOnSelectedLine
              ? _selectedLine!.color.toARGB32()
              : AppTheme.primaryColor.toARGB32(),
          textField: stop.name,
          textSize: 10.0,
          textOffset: [0.0, 1.5],
          textColor: Colors.black.toARGB32(),
          textHaloColor: Colors.white.toARGB32(),
          textHaloWidth: 2.0,
        ),
      );
    }
    
    // Ajouter les marqueurs de bus
    final busesToShow = _mockData.buses
        .where((bus) =>
            bus.isActive &&
            (_selectedLine == null || bus.lineId == _selectedLine!.lineId))
        .toList();
    
    for (final bus in busesToShow) {
      if (bus.currentLocation != null) {
        await _busAnnotationManager?.create(
          PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(
                bus.currentLocation!.longitude,
                bus.currentLocation!.latitude,
              ),
            ),
            iconSize: 1.0,
            iconColor: Colors.orange.toARGB32(),
          ),
        );
      }
    }
    
    // Dessiner les lignes de transport
    if (_selectedLine != null) {
      final lineStops = stopsToShow;
      if (lineStops.length >= 2) {
        final coordinates = lineStops.map((stop) {
          return Position(
            stop.location.longitude,
            stop.location.latitude,
          );
        }).toList();
        
        await _routeAnnotationManager?.create(
          PolylineAnnotationOptions(
            geometry: LineString(coordinates: coordinates),
            lineColor: _selectedLine!.color.toARGB32(),
            lineWidth: 4.0,
          ),
        );
      }
    }
    
    _updateUserMarker();
  }

  Future<void> _updateUserMarker() async {
    if (_userAnnotationManager == null || _userLocation == null) return;
    
    await _userAnnotationManager?.deleteAll();
    await _userAnnotationManager?.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            _userLocation!.longitude,
            _userLocation!.latitude,
          ),
        ),
        iconSize: 1.2,
        iconColor: AppTheme.accentColor.toARGB32(),
      ),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _searchLine() async {
    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir une destination')),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Chercher les arrêts qui correspondent à la destination
      final destination = _destinationController.text.toLowerCase();
      final matchingStops = _mockData.stops.where((stop) =>
        stop.name.toLowerCase().contains(destination)
      ).toList();

      if (matchingStops.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun arrêt trouvé pour cette destination')),
          );
        }
        setState(() => _isSearching = false);
        return;
      }

      // Récupérer toutes les lignes qui passent par ces arrêts
      final lineIds = <String>{};
      for (final stop in matchingStops) {
        lineIds.addAll(stop.linesServing);
      }

      final matchingLines = _mockData.lines.where((line) =>
        lineIds.contains(line.lineId)
      ).toList();

      setState(() => _isSearching = false);

      if (matchingLines.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucune ligne trouvée pour cette destination')),
          );
        }
      } else if (matchingLines.length == 1) {
        // Une seule ligne trouvée, l'afficher directement
        setState(() {
          _selectedLine = matchingLines.first;
        });
        _updateMapAnnotations();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ligne ${matchingLines.first.name} affichée')),
          );
        }
      } else {
        // Plusieurs lignes trouvées, afficher une boîte de dialogue pour choisir
        if (mounted) {
          _showLineSelectionDialog(matchingLines);
        }
      }
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  void _showLineSelectionDialog(List<LineModel> lines) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une ligne'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final line = lines[index];
                return ListTile(
                  leading: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: line.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(line.name),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedLine = line;
                    });
                    _updateMapAnnotations();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ligne ${line.name} affichée')),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
          ],
        );
      },
    );
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Champ destination
          Expanded(
            child: TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'Destination (ex: Université, Marché Central)',
                prefixIcon: const Icon(
                  Icons.place,
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
          // Bouton rechercher ligne
          ElevatedButton.icon(
            onPressed: _isSearching ? null : _searchLine,
            icon: _isSearching
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.search, size: 20),
            label: const Text('Ligne'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return MapWidget(
      key: const ValueKey('mapWidget'),
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            MapboxConfig.defaultLongitude,
            MapboxConfig.defaultLatitude,
          ),
        ),
        zoom: MapboxConfig.defaultZoom,
      ),
      styleUri: MapboxConfig.styleUrl,
      textureView: true,
      onMapCreated: _onMapCreated,
      onTapListener: (coordinate) {
        // Gérer les clics sur la carte si nécessaire
      },
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
              color: Colors.black.withValues(alpha: 0.1),
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
          // Bouton rechercher lignes (nouveau)
          FloatingActionButton(
            heroTag: 'lines',
            onPressed: () {
              Navigator.pushNamed(context, '/lines');
            },
            backgroundColor: AppTheme.primaryColor,
            child: const Icon(Icons.route),
          ),
          const SizedBox(height: 12),
          // Bouton alertes
          FloatingActionButton(
            heroTag: 'alert',
            onPressed: () => Navigator.pushNamed(context, '/alerts'),
            backgroundColor: AppTheme.warningColor,
            child: const Icon(Icons.warning),
          ),
          const SizedBox(height: 12),
          // Bouton activer localisation
          FloatingActionButton(
            heroTag: 'location',
            onPressed: _isLoadingLocation ? null : _updateUserLocation,
            backgroundColor: AppTheme.accentColor,
            child: _isLoadingLocation
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
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
                      child: Center(
                        child: Text(
                          userProvider.isLoggedIn 
                              ? userProvider.userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userProvider.isLoggedIn 
                          ? userProvider.userName
                          : 'Utilisateur',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userProvider.isLoggedIn 
                          ? userProvider.userPhone
                          : '',
                      style: const TextStyle(
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
            leading: const Icon(Icons.route),
            title: const Text('Lignes de transport'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/lines');
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Alertes'),
            onTap: () {
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
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              if (!userProvider.isAdmin) return const SizedBox.shrink();
              return ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Administration'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/admin');
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            onTap: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              await userProvider.logout();
              await ApiAuthService.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
        );
      },
    );
  }
}
