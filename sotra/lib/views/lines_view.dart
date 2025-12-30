import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../data/mock_data.dart';
import '../models/line_model.dart';

class LinesView extends StatefulWidget {
  const LinesView({super.key});

  @override
  State<LinesView> createState() => _LinesViewState();
}

class _LinesViewState extends State<LinesView> {
  final _mockData = MockData();
  final _searchController = TextEditingController();
  List<LineModel> _filteredLines = [];

  // Palette de couleurs SOTRACO
  static const Color sotracoPrimary = Color(0xFF2E7D32);
  static const Color sotracoDark = Color(0xFF1B5E20);
  static const Color sotracoLight = Color(0xFF43A047);

  @override
  void initState() {
    super.initState();
    _filteredLines = _mockData.lines;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterLines(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLines = _mockData.lines;
      } else {
        _filteredLines = _mockData.lines
            .where((line) =>
                line.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _getLineStartStop(LineModel line) {
    if (line.stopsList.isEmpty) return 'Aucun arrêt';
    final stopId = line.stopsList.first;
    final stop = _mockData.stops.firstWhere(
      (s) => s.stopId == stopId,
      orElse: () => _mockData.stops.first,
    );
    return stop.name;
  }

  String _getLineEndStop(LineModel line) {
    if (line.stopsList.isEmpty) return 'Aucun arrêt';
    final stopId = line.stopsList.last;
    final stop = _mockData.stops.firstWhere(
      (s) => s.stopId == stopId,
      orElse: () => _mockData.stops.first,
    );
    return stop.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: sotracoPrimary,
        title: const Text(
          'Lignes de transport',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // En-tête avec gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [sotracoPrimary, sotracoPrimary.withOpacity(0.8)],
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      // Barre de recherche
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterLines,
                          style: const TextStyle(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Rechercher une ligne...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Text(
                                '🔍',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Text(
                                        '✕',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterLines('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Compteur de résultats
                      Row(
                        children: [
                          Text(
                            '${_filteredLines.length} ligne${_filteredLines.length > 1 ? 's' : ''} disponible${_filteredLines.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Liste des lignes
          Expanded(
            child: _filteredLines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '🔍',
                            style: TextStyle(fontSize: 48),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Aucune ligne trouvée',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Essayez une autre recherche',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _filteredLines.length,
                    itemBuilder: (context, index) {
                      final line = _filteredLines[index];
                      return _buildLineCard(line);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineCard(LineModel line) {
    final startStop = _getLineStartStop(line);
    final endStop = _getLineEndStop(line);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/map',
              arguments: {'selectedLine': line},
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    // Badge de ligne
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            line.color,
                            line.color.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: line.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        line.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Prix
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sotracoLight.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sotracoLight.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '${line.baseFare.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: sotracoDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Informations du trajet
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      // Départ
                      _buildStopRow(
                        label: 'DÉPART',
                        stopName: startStop,
                        color: line.color,
                        isStart: true,
                      ),
                      // Ligne de connexion
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 32,
                              margin: const EdgeInsets.only(left: 11),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    line.color,
                                    line.color.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${line.stopsList.length} arrêts',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Arrivée
                      _buildStopRow(
                        label: 'ARRIVÉE',
                        stopName: endStop,
                        color: line.color,
                        isStart: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Bouton d'action
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [sotracoPrimary, sotracoLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Voir sur la carte',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStopRow({
    required String label,
    required String stopName,
    required Color color,
    required bool isStart,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Point
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Informations
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[500],
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stopName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}