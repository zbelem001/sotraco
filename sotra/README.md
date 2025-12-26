# 🚌 Dôrô Wéré - Application de Transport Urbain Intelligent

**"Le chemin clair"** - Votre compagnon numérique pour les déplacements urbains en transports en commun

## 📱 Description

Dôrô Wéré est une application mobile Flutter conçue pour démocratiser l'accès aux transports en commun dans les grandes villes africaines, notamment à Ouagadougou. Elle rend les transports publics compréhensibles, visibles et fiables grâce au numérique et à l'intelligence collective.

## ✨ Fonctionnalités Principales

### 🧭 Navigation & Planification
- **Recherche de trajet** : Planification d'itinéraires avec correspondances
- **Arrêts à proximité** : Détection GPS des arrêts les plus proches
- **Estimation temps/coût** : Calculs précis basés sur l'historique

### 🚍 Suivi en Temps Réel
- **Géolocalisation des bus** : Position des bus via crowdsourcing
- **Temps d'attente estimé** : ETA calculé en temps réel
- **Carte interactive** : Visualisation des lignes, arrêts et bus

### ⚠️ Alertes Communautaires
- Signalements : Bus pleins, pannes, incidents, routes bloquées
- Votes communautaires pour valider les alertes
- Notifications géolocalisées

### 👥 Fonctionnalités Sociales
- **Avatars** : Détection de proximité entre amis
- **Confidentialité** : Contrôle total de la visibilité
- Pas de messagerie (priorité à la simplicité)

### 📍 Mode Hors-ligne
- Téléchargement de cartes par zones
- Navigation sans connexion internet

### ⚙️ Administration
- Gestion des lignes et arrêts
- Tableau de bord statistiques
- Alertes globales aux utilisateurs

## 🎨 Pages de l'Application

1. **Splash** - Écran de lancement
2. **Connexion/Inscription** - Authentification
3. **Carte Principale** - Hub central avec carte interactive
4. **Recherche de Trajet** - Planification d'itinéraires
5. **Résultat Itinéraire** - Détails du trajet calculé
6. **Alertes** - Signalements communautaires
7. **Profil/Paramètres** - Gestion du compte
8. **Favoris/Historique** - Trajets sauvegardés
9. **Amis à Proximité** - Avatars et proximité sociale
10. **Cartes Hors-ligne** - Téléchargements
11. **Administration** - Interface admin

## 🛠️ Technologies Utilisées

- **Framework** : Flutter 3.10+
- **Langage** : Dart
- **State Management** : Provider
- **Navigation** : Named Routes
- **Base de données** : Supabase (PostgreSQL)
- **Cartes** : Flutter Map
- **Localisation** : Geolocator, Geocoding

## 📦 Dépendances Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  go_router: ^14.0.0
  google_maps_flutter: ^2.5.0
  flutter_map: ^6.1.0
  geolocator: ^11.0.0
  geocoding: ^3.0.0
  supabase_flutter: ^2.3.4
  shared_preferences: ^2.2.2
  hive: ^2.2.3
```

## 🚀 Installation et Démarrage

### Prérequis
- Flutter SDK 3.10 ou supérieur
- Dart SDK 3.10 ou supérieur
- Android Studio / VS Code
- Un émulateur ou un appareil physique

### Étapes d'installation

1. **Cloner le projet**
```bash
cd sotra
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Vérifier l'installation**
```bash
flutter doctor
```

4. **Lancer l'application**
```bash
flutter run
```

## 👤 Utilisateur Démo

Pour tester l'application sans inscription :

- **Téléphone** : `+22670123456` ou `70123456`
- **Mot de passe** : (n'importe lequel)
- **Ou cliquer sur** : "Mode Démo"

### Informations utilisateur démo
- **Nom** : Amadou Traoré
- **Score de fiabilité** : 4.5/5
- **Amis** : 3 contacts fictifs
- **Localisation** : Activée par défaut

## 🗄️ Base de Données Supabase

Le script SQL complet est disponible dans `../supabase_schema.sql` à la racine du projet parent.

### Tables Principales

1. **users** - Utilisateurs
2. **friends_list** - Relations d'amitié
3. **locations** - Positions GPS
4. **lines** - Lignes de transport
5. **stops** - Arrêts
6. **line_stops** - Association lignes-arrêts
7. **buses** - Bus du réseau
8. **bus_locations** - Positions en temps réel
9. **alerts** - Alertes communautaires
10. **alert_votes** - Votes sur les alertes
11. **avatars** - Avatars des utilisateurs
12. **trips** - Trajets enregistrés
13. **offline_maps** - Cartes téléchargées

### Configuration Supabase

1. Créer un projet sur [supabase.com](https://supabase.com)
2. Exécuter le script `supabase_schema.sql` dans l'éditeur SQL
3. Copier l'URL et l'ANON KEY dans votre configuration

## 📂 Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'app
├── models/                   # Modèles de données
│   ├── user_model.dart
│   ├── bus_model.dart
│   ├── line_model.dart
│   ├── stop_model.dart
│   ├── trip_model.dart
│   ├── route_model.dart
│   ├── alert_model.dart
│   └── avatar_model.dart
├── services/                 # Services métier
│   ├── auth_service.dart
│   ├── geolocation_service.dart
│   ├── routing_service.dart
│   └── alert_service.dart
├── views/                    # Écrans/Pages
│   ├── splash_view.dart
│   ├── login_view.dart
│   ├── register_view.dart
│   ├── map_view.dart
│   ├── trip_search_view.dart
│   ├── trip_result_view.dart
│   ├── alerts_view.dart
│   ├── profile_view.dart
│   ├── favorites_view.dart
│   ├── avatars_view.dart
│   ├── offline_maps_view.dart
│   └── admin_view.dart
├── widgets/                  # Composants réutilisables
├── providers/                # State management
├── utils/                    # Utilitaires
│   └── app_theme.dart
└── data/                     # Données de test
    └── mock_data.dart
```

## 🎨 Charte Graphique

### Couleurs
- **Primaire** : `#2E7D32` (Vert urbain)
- **Secondaire** : `#FF6F00` (Orange transport)
- **Accent** : `#0288D1` (Bleu information)
- **Erreur** : `#D32F2F`
- **Avertissement** : `#F57C00`
- **Succès** : `#388E3C`

### Typographie
- Police principale : Roboto (par défaut Flutter)
- Tailles : 12sp (petit), 14sp (normal), 16sp (titre), 24sp+ (headings)

## 🧪 Données de Test

L'application inclut des données fictives pour tester toutes les fonctionnalités :

- **3 lignes de bus** (Ligne 1, 2, 3)
- **8 arrêts** à Ouagadougou
- **4 bus actifs** en circulation
- **3 amis fictifs** pour l'utilisateur démo
- **2 alertes actives**

## 🔐 Sécurité & Vie Privée

- **Localisation désactivable** à tout moment
- **Données anonymisées** pour la géolocalisation des bus
- **Contrôle de visibilité** des avatars
- **Row Level Security** (RLS) activé sur Supabase
- **Hachage des mots de passe** avec bcrypt

## 📱 Plateformes Supportées

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Linux
- ✅ macOS
- ✅ Windows

## 🐛 Débogage

### Problèmes courants

**Erreur de dépendances**
```bash
flutter clean
flutter pub get
```

**Problème de localisation**
- Vérifier les permissions dans `AndroidManifest.xml` (Android)
- Vérifier `Info.plist` (iOS)

**Carte ne s'affiche pas**
- Vérifier la clé API Google Maps (si utilisée)
- Vérifier la connexion internet

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👨‍💻 Auteur

Développé pour faciliter la mobilité urbaine en Afrique.

## 🙏 Remerciements

- La communauté Flutter
- SOTRACO (inspiration)
- Les utilisateurs de transports publics à Ouagadougou

## 📞 Support

Pour toute question ou problème :
- Ouvrir une issue sur GitHub
- Contacter l'équipe de développement

---

**Version** : 1.0.0  
**Dernière mise à jour** : Décembre 2025

🚌 **Dôrô Wéré** - Parce que chaque trajet compte ! 🚌

