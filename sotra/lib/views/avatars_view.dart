import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../data/mock_data.dart';

class AvatarsView extends StatelessWidget {
  const AvatarsView({super.key});

  @override
  Widget build(BuildContext context) {
    final mockData = MockData();
    final friends = mockData.demoFriends;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amis à proximité'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Statistiques
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(Icons.people, '${friends.length}', 'Amis'),
                _buildStat(Icons.near_me, '2', 'À proximité'),
                _buildStat(Icons.directions_bus, '1', 'Dans un bus'),
              ],
            ),
          ),
          // Liste des amis
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                final isNearby = index < 2;
                
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isNearby
                          ? AppTheme.successColor
                          : AppTheme.textSecondaryColor,
                      child: Text(
                        friend.name[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(friend.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isNearby ? Icons.near_me : Icons.location_off,
                              size: 14,
                              color: isNearby
                                  ? AppTheme.successColor
                                  : AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isNearby
                                  ? 'À 500m de vous'
                                  : 'Localisation désactivée',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        if (index == 0)
                          const Row(
                            children: [
                              Icon(Icons.directions_bus, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Dans la Ligne 1',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.message_outlined),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Messagerie à venir'),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add),
        label: const Text('Ajouter un ami'),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
