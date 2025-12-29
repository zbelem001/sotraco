# Guide de démarrage Backend + Flutter

## 🚀 Démarrage rapide

### 1️⃣ Configurer PostgreSQL

```bash
# Nettoyer l'ancien schéma (si nécessaire)
psql -d sotraco -c "DROP SCHEMA IF EXISTS dorowere CASCADE;"

# Créer le schéma
psql -d sotraco -f postgresql_local_schema_no_postgis.sql
```

### 2️⃣ Démarrer le backend

```bash
cd backend

# Installer les dépendances
npm install

# Démarrer le serveur
npm start
```

Le serveur démarre sur `http://localhost:3000`

### 3️⃣ Tester l'API

```bash
# Health check
curl http://localhost:3000/health

# Mode démo
curl -X POST http://localhost:3000/api/auth/demo

# Lister les lignes
curl http://localhost:3000/api/lines

# Arrêts à proximité de Ouagadougou
curl "http://localhost:3000/api/stops/nearby?lat=12.3714&lng=-1.5197&radius=2"
```

### 4️⃣ Lancer l'app Flutter

```bash
cd sotra

# Exécuter l'app (elle utilisera automatiquement l'API locale)
flutter run
```

## 🔧 Configuration Flutter

L'app est préconfigurée pour utiliser l'API locale sur `http://localhost:3000`

Pour changer l'URL (production), éditez :
- `lib/config/api_config.dart` → `baseUrl`

## 📱 Fonctionnalités connectées

✅ **Authentification**
- Inscription
- Connexion
- Mode démo
- Profil utilisateur

✅ **Lignes de bus**
- Liste toutes les lignes
- Détails d'une ligne avec arrêts

✅ **Arrêts**
- Liste tous les arrêts
- Arrêts à proximité (avec distance)
- Détails d'un arrêt avec lignes

✅ **Bus**
- Bus actifs avec position
- Bus à proximité
- Détails d'un bus

✅ **Alertes**
- Alertes actives
- Alertes à proximité
- Créer une alerte
- Voter sur une alerte

✅ **Utilisateurs**
- Profil avec statistiques
- Mise à jour profil
- Enregistrement localisation
- Trajets sauvegardés

## 🔐 Authentification dans l'app

Les services API utilisent le token JWT automatiquement :

```dart
// Exemple d'utilisation
final authService = ApiAuthService();

// Connexion
final result = await authService.login(
  phoneNumber: '+22670123456',
  password: 'demo123',
);

if (result['success']) {
  // Le token est sauvegardé automatiquement
  final token = authService.token;
  
  // Utiliser les autres services avec le token
  final lineService = ApiLineService(token: token);
  final lines = await lineService.getAllLines();
}
```

## 📊 Structure des services API

```
lib/services/
├── api_auth_service.dart    # Authentification
├── api_line_service.dart    # Lignes de bus
├── api_stop_service.dart    # Arrêts
├── api_bus_service.dart     # Bus
└── api_alert_service.dart   # Alertes
```

## 🐛 Debugging

### Backend
```bash
# Voir les logs SQL détaillés
NODE_ENV=development npm run dev
```

### Flutter
```bash
# Voir les requêtes HTTP
flutter run --verbose
```

## 🔄 Synchronisation

L'app peut fonctionner en mode :
- **En ligne** : utilise l'API PostgreSQL locale
- **Hors ligne** : utilise les données fictives embarquées

## 📝 TODO

- [ ] Implémenter le cache local Flutter
- [ ] Ajouter la synchronisation en temps réel (WebSockets)
- [ ] Gérer les erreurs réseau avec retry
- [ ] Implémenter le refresh token
- [ ] Ajouter les notifications push

## 🎯 Prochaines étapes

1. Tester toutes les fonctionnalités
2. Implémenter le cache local
3. Ajouter les WebSockets pour le tracking temps réel
4. Déployer sur serveur de production
