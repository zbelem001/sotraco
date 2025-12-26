import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/line_model.dart';
import '../models/stop_model.dart';
import '../models/bus_model.dart';

class MockData {
  // Arrêts fictifs à Ouagadougou
  List<StopModel> get stops => [
        StopModel(
          stopId: 'stop_001',
          name: 'Place des Nations Unies',
          location: LocationModel(
            latitude: 12.3714,
            longitude: -1.5197,
            timestamp: DateTime.now(),
          ),
          linesServing: ['line_001', 'line_002', 'line_003'],
        ),
        StopModel(
          stopId: 'stop_002',
          name: 'Avenue Kwame Nkrumah',
          location: LocationModel(
            latitude: 12.3654,
            longitude: -1.5327,
            timestamp: DateTime.now(),
          ),
          linesServing: ['line_001', 'line_002'],
        ),
        StopModel(
          stopId: 'stop_003',
          name: 'Marché Central',
          location: LocationModel(
            latitude: 12.3684,
            longitude: -1.5274,
            timestamp: DateTime.now(),
          ),
          linesServing: ['line_001', 'line_003'],
        ),
        StopModel(
          stopId: 'stop_004',
          name: 'Université Ouaga 1',
          location: LocationModel(
            latitude: 12.3584,
            longitude: -1.5117,
            timestamp: DateTime.now(),
          ),
          linesServing: ['line_002', 'line_003'],
        ),
        StopModel(
          stopId: 'stop_005',
          name: 'Gare Routière',
          location: LocationModel(
            latitude: 12.3754,
            longitude: -1.5097,
            timestamp: DateTime.now(),
          ),
          linesServing: ['line_001'],
        ),
        StopModel(
          stopId: 'stop_006',
          name: 'Zone du Bois',
          location: LocationModel(
            latitude: 12.3434,
            longitude: -1.5287,
            timestamp: DateTime.now(),
          ),
          linesServing: ['line_002', 'line_003'],
        ),
        StopModel(
          stopId: 'stop_007',
          name: 'Quartier Gounghin',
          location: LocationModel(
            latitude: 12.3824,
            longitude: -1.5147,
            timestamp: DateTime.now(),
          ),
          linesServing: ['line_001', 'line_002'],
        ),
        StopModel(
          stopId: 'stop_008',
          name: 'Patte d\'Oie',
          location: LocationModel(
            latitude: 12.3894,
            longitude: -1.5387,
            timestamp: DateTime.now(),
          ),
          linesServing: ['line_003'],
        ),
      ];

  // Lignes fictives
  List<LineModel> get lines => [
        LineModel(
          lineId: 'line_001',
          name: 'Ligne 1 - Centre-Nord',
          color: Colors.blue,
          stopsList: [
            stops[0], // Place des Nations Unies
            stops[1], // Avenue Kwame Nkrumah
            stops[2], // Marché Central
            stops[4], // Gare Routière
            stops[6], // Quartier Gounghin
          ],
          averageSpeed: 25.0,
          baseFare: 200.0,
        ),
        LineModel(
          lineId: 'line_002',
          name: 'Ligne 2 - Est-Ouest',
          color: Colors.green,
          stopsList: [
            stops[1], // Avenue Kwame Nkrumah
            stops[3], // Université Ouaga 1
            stops[5], // Zone du Bois
            stops[6], // Quartier Gounghin
          ],
          averageSpeed: 22.0,
          baseFare: 200.0,
        ),
        LineModel(
          lineId: 'line_003',
          name: 'Ligne 3 - Circulaire',
          color: Colors.orange,
          stopsList: [
            stops[0], // Place des Nations Unies
            stops[2], // Marché Central
            stops[3], // Université Ouaga 1
            stops[5], // Zone du Bois
            stops[7], // Patte d'Oie
          ],
          averageSpeed: 20.0,
          baseFare: 250.0,
        ),
      ];

  // Bus fictifs
  List<BusModel> get buses => [
        BusModel(
          busId: 'bus_001',
          lineId: 'line_001',
          currentLocation: LocationModel(
            latitude: 12.3714,
            longitude: -1.5197,
            timestamp: DateTime.now(),
          ),
          direction: 'Nord',
          speed: 25.0,
          lastUpdateTime: DateTime.now(),
          isActive: true,
        ),
        BusModel(
          busId: 'bus_002',
          lineId: 'line_001',
          currentLocation: LocationModel(
            latitude: 12.3824,
            longitude: -1.5147,
            timestamp: DateTime.now(),
          ),
          direction: 'Centre',
          speed: 20.0,
          lastUpdateTime: DateTime.now(),
          isActive: true,
        ),
        BusModel(
          busId: 'bus_003',
          lineId: 'line_002',
          currentLocation: LocationModel(
            latitude: 12.3584,
            longitude: -1.5117,
            timestamp: DateTime.now(),
          ),
          direction: 'Ouest',
          speed: 22.0,
          lastUpdateTime: DateTime.now(),
          isActive: true,
        ),
        BusModel(
          busId: 'bus_004',
          lineId: 'line_003',
          currentLocation: LocationModel(
            latitude: 12.3684,
            longitude: -1.5274,
            timestamp: DateTime.now(),
          ),
          direction: 'Circulaire',
          speed: 18.0,
          lastUpdateTime: DateTime.now(),
          isActive: true,
        ),
      ];

  // Amis fictifs pour l'utilisateur démo
  List<UserModel> get demoFriends => [
        UserModel(
          userId: 'friend_001',
          name: 'Fatou Sankara',
          phoneNumber: '+22670987654',
          location: LocationModel(
            latitude: 12.3754,
            longitude: -1.5097,
            timestamp: DateTime.now(),
          ),
          isLocationEnabled: true,
          reliabilityScore: 4.2,
        ),
        UserModel(
          userId: 'friend_002',
          name: 'Ibrahim Konaté',
          phoneNumber: '+22671234567',
          location: LocationModel(
            latitude: 12.3654,
            longitude: -1.5327,
            timestamp: DateTime.now(),
          ),
          isLocationEnabled: true,
          reliabilityScore: 4.8,
        ),
        UserModel(
          userId: 'friend_003',
          name: 'Aminata Ouédraogo',
          phoneNumber: '+22672345678',
          location: LocationModel(
            latitude: 12.3684,
            longitude: -1.5274,
            timestamp: DateTime.now(),
          ),
          isLocationEnabled: true,
          reliabilityScore: 4.0,
        ),
      ];
}
