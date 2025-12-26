import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoris & Historique')),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppTheme.primaryColor,
              tabs: [
                Tab(text: 'Favoris', icon: Icon(Icons.star)),
                Tab(text: 'Historique', icon: Icon(Icons.history)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFavorites(),
                  _buildHistory(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavorites() {
    final favorites = [
      {'from': 'Place des Nations Unies', 'to': 'Université Ouaga 1'},
      {'from': 'Gare Routière', 'to': 'Marché Central'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final fav = favorites[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.star, color: AppTheme.secondaryColor),
            title: Text(fav['from']!),
            subtitle: Text('→ ${fav['to']}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistory() {
    final history = [
      {
        'from': 'Zone du Bois',
        'to': 'Patte d\'Oie',
        'date': 'Aujourd\'hui 14:30'
      },
      {
        'from': 'Marché Central',
        'to': 'Université',
        'date': 'Hier 09:15'
      },
      {
        'from': 'Gare Routière',
        'to': 'Gounghin',
        'date': 'Il y a 2 jours'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.history, color: AppTheme.accentColor),
            title: Text(item['from']!),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('→ ${item['to']}'),
                Text(
                  item['date']!,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }
}
