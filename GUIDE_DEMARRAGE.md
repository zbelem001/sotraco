# 🚀 Guide de Démarrage Rapide - Dôrô Wéré

## ✅ Installation Complète

Toutes les fonctionnalités ont été implémentées ! Voici comment démarrer :

### 1️⃣ Lancer l'application

```bash
cd sotra
flutter run
```

### 2️⃣ Naviguer dans l'application

**Utilisateur démo déjà configuré :**
- **Téléphone** : `+22670123456` ou `70123456`
- **Mot de passe** : n'importe lequel
- **OU** : Cliquez simplement sur "Mode Démo"

### 3️⃣ Explorer les 11 pages

Toutes les pages sont accessibles via :
- Le **menu drawer** (☰) depuis la carte principale
- Les **boutons flottants** en bas à droite de la carte
- La **navigation naturelle** entre les écrans

## 📱 Pages Disponibles

| Page | Description | Accès |
|------|-------------|-------|
| 🎨 Splash | Écran de démarrage animé | Auto au lancement |
| 🔐 Connexion | Authentification | Auto après splash |
| ✍️ Inscription | Créer un compte | Depuis la connexion |
| 🗺️ Carte | Hub central avec lignes et bus | Page principale |
| 🔍 Recherche | Planifier un trajet | Bouton orange (carte) |
| 📋 Itinéraire | Détails du trajet | Après recherche |
| ⚠️ Alertes | Signalements communautaires | Bouton jaune (carte) |
| 👤 Profil | Paramètres utilisateur | Menu drawer |
| ⭐ Favoris | Trajets sauvegardés | Menu drawer |
| 👥 Amis | Proximité sociale | Menu drawer |
| 📥 Hors-ligne | Cartes téléchargées | Menu drawer |
| ⚙️ Admin | Interface administrateur | Menu drawer (admin) |

## 🎯 Fonctionnalités Testables

### ✅ Authentification
- Mode démo instantané
- Connexion avec utilisateur fictif
- Inscription de nouveaux utilisateurs

### ✅ Navigation
- 11 pages entièrement fonctionnelles
- Navigation fluide entre les écrans
- Retour arrière fonctionnel

### ✅ Données Fictives
- **3 lignes de bus** (bleu, vert, orange)
- **8 arrêts** à Ouagadougou
- **4 bus actifs** en circulation
- **3 amis** pour l'utilisateur démo
- **2 alertes** communautaires actives

### ✅ Interface Utilisateur
- Thème cohérent (vert/orange/bleu)
- Animations fluides
- Design responsive
- Icons Material Design

## 🗄️ Base de Données Supabase

Le script SQL complet est prêt dans : `supabase_schema.sql`

### Configuration Supabase (Optionnel - pour production)

1. Créer un compte sur https://supabase.com
2. Créer un nouveau projet
3. Ouvrir l'éditeur SQL
4. Copier-coller le contenu de `supabase_schema.sql`
5. Exécuter le script

**Tables créées :**
- 14 tables principales
- Indexes optimisés
- Row Level Security (RLS) activé
- Triggers automatiques
- Vues utiles

## 🎨 Personnalisation

### Changer les couleurs

Modifier `lib/utils/app_theme.dart` :

```dart
static const Color primaryColor = Color(0xFF2E7D32); // Vert
static const Color secondaryColor = Color(0xFFFF6F00); // Orange
static const Color accentColor = Color(0xFF0288D1); // Bleu
```

### Ajouter des lignes/arrêts

Modifier `lib/data/mock_data.dart` :

```dart
List<LineModel> get lines => [
  // Ajouter vos lignes ici
];

List<StopModel> get stops => [
  // Ajouter vos arrêts ici
];
```

## 🔧 Architecture

```
Modèles (Models) → Services (Business Logic) → Vues (UI)
     ↓                    ↓                        ↓
  8 classes          4 services              11 pages
```

### Modèles Disponibles
- `UserModel` - Utilisateurs
- `BusModel` - Bus en circulation
- `LineModel` - Lignes de transport
- `StopModel` - Arrêts
- `TripModel` - Trajets planifiés
- `RouteModel` - Segments de trajets
- `AlertModel` - Alertes communautaires
- `AvatarModel` - Avatars sociaux

### Services Disponibles
- `AuthService` - Authentification
- `GeolocationService` - GPS et localisation
- `RoutingService` - Calcul d'itinéraires
- `AlertService` - Gestion des alertes

## 🧪 Tests

L'application est prête pour les tests avec :
- Utilisateur démo complet
- Données fictives réalistes
- Toutes les pages navigables
- Aucune erreur de compilation

### Tester rapidement

```bash
# Lancer sur un émulateur Android
flutter run -d android

# Lancer sur un appareil iOS
flutter run -d ios

# Lancer sur le web
flutter run -d chrome

# Mode debug avec hot reload
flutter run --debug
```

## 📝 Prochaines Étapes (Optionnel)

1. **Intégrer Supabase** - Connecter la vraie base de données
2. **Ajouter Google Maps** - Remplacer la carte simulée
3. **Push Notifications** - Alertes en temps réel
4. **Tests unitaires** - Ajouter des tests automatisés
5. **CI/CD** - Déploiement automatique

## ⚠️ Notes Importantes

- ✅ Toutes les pages sont fonctionnelles
- ✅ La navigation fonctionne parfaitement
- ✅ Les données de test sont déjà chargées
- ⚠️ La carte est une simulation (pas de vraie map)
- ⚠️ La localisation GPS est simulée
- ⚠️ Supabase n'est pas encore connecté (données locales)

## 🎉 Félicitations !

Votre application **Dôrô Wéré** est prête à être testée !

Lancez simplement `flutter run` et explorez les 11 pages avec l'utilisateur démo **Amadou Traoré**.

---

**Besoin d'aide ?** Consultez le README.md principal pour plus de détails.
