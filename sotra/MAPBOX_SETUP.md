# 🗺️ Configuration Mapbox pour Dôrô Wéré

## 📋 Étapes pour obtenir votre clé API Mapbox (GRATUIT)

### 1. Créer un compte Mapbox
1. Allez sur **https://account.mapbox.com/auth/signup/**
2. Créez un compte gratuit avec votre email
3. Confirmez votre email

### 2. Obtenir votre Access Token
1. Connectez-vous à **https://account.mapbox.com/**
2. Allez dans la section **"Access tokens"**
3. Copiez votre **"Default public token"** (commence par `pk.`)
   - ⚠️ Utilisez le token public (pk.), PAS le secret (sk.)

### 3. Configurer dans l'application

#### Option A : Dans le code source
Ouvrez le fichier `lib/config/mapbox_config.dart` et remplacez :
```dart
static const String accessToken = 'YOUR_MAPBOX_ACCESS_TOKEN_HERE';
```
par :
```dart
static const String accessToken = 'pk.votre_token_ici';
```

#### Option B : Via le fichier .mapbox_token (recommandé)
Créez un fichier `.mapbox_token` à la racine du projet avec votre token :
```
pk.votre_token_ici
```

### 4. Vérifier que tout fonctionne
```bash
flutter run
```

## 🎁 Limites gratuites Mapbox

- ✅ **50 000 chargements de carte/mois GRATUITS**
- ✅ API de géocodage et routing incluses
- ✅ Cartes hors-ligne
- ✅ Styles personnalisés
- ✅ Animations fluides

💡 **C'est amplement suffisant pour le développement et les petites applications !**

## 🎨 Styles de carte disponibles

Dans `mapbox_config.dart`, vous pouvez changer le style :

```dart
// Streets (par défaut)
static const String styleUrl = 'mapbox://styles/mapbox/streets-v12';

// Outdoors (pour les transports)
static const String styleUrl = 'mapbox://styles/mapbox/outdoors-v12';

// Light
static const String styleUrl = 'mapbox://styles/mapbox/light-v11';

// Dark
static const String styleUrl = 'mapbox://styles/mapbox/dark-v11';

// Satellite
static const String styleUrl = 'mapbox://styles/mapbox/satellite-streets-v12';
```

## 🛠️ Configuration Android (DÉJÀ FAIT ✅)

Les permissions suivantes ont été ajoutées dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

## 📱 Fonctionnalités Mapbox intégrées

✅ **Carte interactive** avec zoom/pan/rotation
✅ **Marqueurs pour arrêts** avec noms
✅ **Marqueurs pour bus** en temps réel
✅ **Traçage des itinéraires** (lignes)
✅ **Position de l'utilisateur** avec marqueur bleu
✅ **Animations fluides** lors des déplacements
✅ **Style Streets de Mapbox** (personnalisable)

## 🚀 Prochaines améliorations possibles

- Animation du mouvement des bus en temps réel
- API Mapbox Geocoding pour recherche d'adresses réelles
- API Mapbox Directions pour calcul d'itinéraires
- Téléchargement de cartes hors-ligne
- Couche trafic en temps réel
- Styles personnalisés dans Mapbox Studio

## ❓ Problèmes courants

### La carte ne s'affiche pas
- Vérifiez que vous avez bien remplacé `YOUR_MAPBOX_ACCESS_TOKEN_HERE`
- Vérifiez que vous utilisez un token public (pk.)
- Vérifiez votre connexion Internet

### Erreur de permissions
- Relancez l'app après avoir modifié AndroidManifest.xml
- Sur Android, acceptez les permissions de localisation

## 📚 Documentation Mapbox

- **Compte Mapbox** : https://account.mapbox.com/
- **Documentation** : https://docs.mapbox.com/flutter/
- **Pricing** : https://www.mapbox.com/pricing
- **Styles** : https://www.mapbox.com/maps
