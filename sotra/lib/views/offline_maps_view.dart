import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class OfflineMapsView extends StatelessWidget {
  const OfflineMapsView({super.key});

  @override
  Widget build(BuildContext context) {
    final zones = [
      {'name': 'Centre-ville', 'size': '12 MB', 'downloaded': true},
      {'name': 'Université', 'size': '8 MB', 'downloaded': true},
      {'name': 'Zone du Bois', 'size': '10 MB', 'downloaded': false},
      {'name': 'Patte d\'Oie', 'size': '15 MB', 'downloaded': false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartes hors-ligne'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.accentColor),
                const SizedBox(width: 12),
                Expanded(
                  child: const Text(
                    'Téléchargez les cartes pour naviguer sans connexion internet',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: zones.length,
              itemBuilder: (context, index) {
                final zone = zones[index];
                final isDownloaded = zone['downloaded'] as bool;
                final zoneName = zone['name'] as String;
                final zoneSize = zone['size'] as String;

                return Card(
                  child: ListTile(
                    leading: Icon(
                      isDownloaded
                          ? Icons.check_circle
                          : Icons.cloud_download,
                      color: isDownloaded
                          ? AppTheme.successColor
                          : AppTheme.accentColor,
                    ),
                    title: Text(zoneName),
                    subtitle: Text(zoneSize),
                    trailing: isDownloaded
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$zoneName supprimée',
                                  ),
                                ),
                              );
                            },
                          )
                        : ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Téléchargement de $zoneName démarré',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Télécharger'),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
