import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_admin_service.dart';
import '../utils/app_theme.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ApiAdminService _adminService;
  String? _token;
  
  Map<String, dynamic>? _stats;
  List<dynamic> _users = [];
  List<dynamic> _alerts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    
    if (_token == null) {
      setState(() {
        _error = 'Non authentifié';
        _isLoading = false;
      });
      return;
    }

    _adminService = ApiAdminService(token: _token!);
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await _adminService.getStats();
      final users = await _adminService.getUsers();
      final alerts = await _adminService.getAlerts();

      setState(() {
        _stats = stats;
        _users = users['users'] ?? [];
        _alerts = alerts['alerts'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isLoading = false;
      });
      
      if (e.toString().contains('401') || e.toString().contains('403')) {
        _showAccessDeniedDialog();
      }
    }
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accès refusé'),
        content: const Text('Vous n\'avez pas les droits administrateur nécessaires pour accéder à cette page.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Tableau de bord'),
            Tab(icon: Icon(Icons.people), text: 'Utilisateurs'),
            Tab(icon: Icon(Icons.warning), text: 'Alertes'),
            Tab(icon: Icon(Icons.directions_bus), text: 'Transport'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDashboard(),
                    _buildUsersTab(),
                    _buildAlertsTab(),
                    _buildTransportTab(),
                  ],
                ),
    );
  }

  Widget _buildDashboard() {
    if (_stats == null) {
      return const Center(child: Text('Pas de données'));
    }

    final stats = _stats!['stats'] ?? {};

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statistiques principales
          Card(
            color: AppTheme.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Vue d\'ensemble',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2,
                    children: [
                      _buildStatCard('Utilisateurs', stats['total_users']?.toString() ?? '0', Icons.people),
                      _buildStatCard('Chauffeurs', stats['total_drivers']?.toString() ?? '0', Icons.person),
                      _buildStatCard('Lignes', stats['total_lines']?.toString() ?? '0', Icons.route),
                      _buildStatCard('Arrêts', stats['total_stops']?.toString() ?? '0', Icons.location_on),
                      _buildStatCard('Bus', stats['total_buses']?.toString() ?? '0', Icons.directions_bus),
                      _buildStatCard('Bus actifs', stats['active_buses']?.toString() ?? '0', Icons.check_circle),
                      _buildStatCard('Alertes actives', stats['active_alerts']?.toString() ?? '0', Icons.warning),
                      _buildStatCard('Trajets', stats['total_trips']?.toString() ?? '0', Icons.map),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Activité récente
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Activité récente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...(_stats!['recentActivity'] as List? ?? []).map((activity) {
                    return ListTile(
                      leading: Icon(_getActivityIcon(activity['type'])),
                      title: Text(_getActivityTitle(activity['type'])),
                      subtitle: Text(_formatDate(activity['created_at'])),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  user['display_name']?[0]?.toUpperCase() ?? 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user['display_name'] ?? 'Anonyme'),
              subtitle: Text('${user['phone_number']} • ${user['role']}'),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Modifier'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Supprimer'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditUserDialog(user);
                  } else if (value == 'delete') {
                    _deleteUser(user['user_id']);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlertsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          final isActive = DateTime.parse(alert['expires_at']).isAfter(DateTime.now());
          
          return Card(
            child: ListTile(
              leading: Icon(
                _getAlertIcon(alert['alert_type']),
                color: isActive ? Colors.orange : Colors.grey,
              ),
              title: Text(alert['description'] ?? 'Alerte'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: ${alert['alert_type']}'),
                  Text('Par: ${alert['reporter_name'] ?? 'Anonyme'}'),
                  Text('Confirmations: ${alert['confirms']} • Refus: ${alert['denies']}'),
                  Text(isActive ? 'Active' : 'Expirée', 
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteAlert(alert['alert_id']),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransportTab() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppTheme.primaryColor,
            tabs: [
              Tab(text: 'Lignes'),
              Tab(text: 'Arrêts'),
              Tab(text: 'Bus'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildLinesManagement(),
                _buildStopsManagement(),
                _buildBusesManagement(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinesManagement() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.route, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Gestion des lignes'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateLineDialog,
            icon: const Icon(Icons.add),
            label: const Text('Créer une ligne'),
          ),
        ],
      ),
    );
  }

  Widget _buildStopsManagement() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_on, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Gestion des arrêts'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateStopDialog,
            icon: const Icon(Icons.add),
            label: const Text('Créer un arrêt'),
          ),
        ],
      ),
    );
  }

  Widget _buildBusesManagement() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_bus, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Gestion des bus'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showCreateBusDialog,
            icon: const Icon(Icons.add),
            label: const Text('Créer un bus'),
          ),
        ],
      ),
    );
  }

  // Dialog pour modifier un utilisateur
  void _showEditUserDialog(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['display_name']);
    String selectedRole = user['role'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(labelText: 'Rôle'),
              items: const [
                DropdownMenuItem(value: 'user', child: Text('Utilisateur')),
                DropdownMenuItem(value: 'driver', child: Text('Chauffeur')),
                DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
              ],
              onChanged: (value) {
                selectedRole = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _adminService.updateUser(
                user['user_id'],
                {
                  'display_name': nameController.text,
                  'role': selectedRole,
                },
              );
              
              Navigator.pop(context);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Utilisateur modifié')),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Erreur lors de la modification')),
                );
              }
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }

  void _showCreateLineDialog() {
    final numberController = TextEditingController();
    final nameController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une ligne'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Numéro'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: startController,
                decoration: const InputDecoration(labelText: 'Point de départ'),
              ),
              TextField(
                controller: endController,
                decoration: const InputDecoration(labelText: 'Point d\'arrivée'),
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
            onPressed: () async {
              final result = await _adminService.createLine({
                'line_number': numberController.text,
                'line_name': nameController.text,
                'start_point': startController.text,
                'end_point': endController.text,
                'color': '#FF6B35',
              });
              
              Navigator.pop(context);
              
              if (result['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ligne créée')),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: ${result['error']}')),
                );
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showCreateStopDialog() {
    final nameController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un arrêt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: latController,
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lngController,
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await _adminService.createStop({
                'stop_name': nameController.text,
                'latitude': double.parse(latController.text),
                'longitude': double.parse(lngController.text),
              });
              
              Navigator.pop(context);
              
              if (result['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Arrêt créé')),
                );
                _loadData();
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showCreateBusDialog() {
    final numberController = TextEditingController();
    final capacityController = TextEditingController(text: '45');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un bus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Numéro de bus'),
            ),
            TextField(
              controller: capacityController,
              decoration: const InputDecoration(labelText: 'Capacité'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Pour créer un bus, il faut une ligne_id
              // Pour simplifier, on montre juste le message
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sélectionnez d\'abord une ligne')),
              );
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _adminService.deleteUser(userId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur supprimé')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression')),
        );
      }
    }
  }

  Future<void> _deleteAlert(String alertId) async {
    final success = await _adminService.deleteAlert(alertId);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alerte supprimée')),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'user':
        return Icons.person_add;
      case 'alert':
        return Icons.warning;
      case 'trip':
        return Icons.map;
      default:
        return Icons.circle;
    }
  }

  String _getActivityTitle(String type) {
    switch (type) {
      case 'user':
        return 'Nouvel utilisateur';
      case 'alert':
        return 'Nouvelle alerte';
      case 'trip':
        return 'Nouveau trajet';
      default:
        return 'Activité';
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'bus_full':
        return Icons.people;
      case 'breakdown':
        return Icons.build;
      case 'accident':
        return Icons.car_crash;
      case 'stop_moved':
        return Icons.location_off;
      case 'road_blocked':
        return Icons.block;
      default:
        return Icons.warning;
    }
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return 'Il y a ${diff.inDays} jour${diff.inDays > 1 ? 's' : ''}';
    } else if (diff.inHours > 0) {
      return 'Il y a ${diff.inHours} heure${diff.inHours > 1 ? 's' : ''}';
    } else if (diff.inMinutes > 0) {
      return 'Il y a ${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }
}
