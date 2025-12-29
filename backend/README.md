# Dôrô Wéré - Backend API

API REST pour l'application de transport urbain intelligent.

## 🚀 Installation

```bash
# Installer les dépendances
cd backend
npm install

# Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos paramètres PostgreSQL

# Démarrer le serveur
npm start

# Mode développement (avec auto-reload)
npm run dev
```

## 📦 Prérequis

- Node.js 16+ 
- PostgreSQL 12+ avec la base `sotraco` et le schéma `dorowere`
- Base de données créée avec `postgresql_local_schema_no_postgis.sql`

## 🔧 Configuration

Fichier `.env` :

```env
# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sotraco
DB_USER=dorowere_app
DB_PASSWORD=dev_password_change_in_production
DB_SCHEMA=dorowere

# Serveur
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=dorowere_dev_secret_key_2025
JWT_EXPIRES_IN=7d

# CORS
CORS_ORIGINS=http://localhost:*,http://127.0.0.1:*
```

## 📡 API Endpoints

### 🔐 Authentification

#### POST `/api/auth/register`
Inscription d'un nouvel utilisateur

**Body:**
```json
{
  "name": "Amadou Traoré",
  "phone_number": "+22670123456",
  "password": "monmotdepasse"
}
```

**Response:** 
```json
{
  "message": "Inscription réussie",
  "token": "eyJhbGciOiJIUzI1...",
  "user": {
    "userId": "uuid",
    "name": "Amadou Traoré",
    "phoneNumber": "+22670123456",
    "reliabilityScore": 5.0
  }
}
```

#### POST `/api/auth/login`
Connexion utilisateur

**Body:**
```json
{
  "phone_number": "+22670123456",
  "password": "demo123"
}
```

#### POST `/api/auth/demo`
Mode démo (utilisateur test)

**Response:** Renvoie un token pour l'utilisateur démo

---

### 🚌 Lignes de bus

#### GET `/api/lines`
Liste toutes les lignes

**Query params:**
- `active_only=true` : uniquement les lignes actives

#### GET `/api/lines/:id`
Détails d'une ligne avec ses arrêts

---

### 🚏 Arrêts

#### GET `/api/stops`
Liste tous les arrêts

#### GET `/api/stops/nearby?lat=12.3714&lng=-1.5197&radius=1.0`
Arrêts à proximité (rayon en km)

#### GET `/api/stops/:id`
Détails d'un arrêt avec les lignes qui y passent

---

### 🚍 Bus

#### GET `/api/buses`
Liste des bus actifs avec leur position

**Query params:**
- `line_id=uuid` : filtrer par ligne

#### GET `/api/buses/nearby?lat=12.3714&lng=-1.5197&radius=5.0`
Bus à proximité

#### GET `/api/buses/:id`
Détails d'un bus avec sa position actuelle

---

### ⚠️ Alertes

#### GET `/api/alerts`
Alertes actives

**Query params:**
- `line_id=uuid` : filtrer par ligne

#### GET `/api/alerts/nearby?lat=12.3714&lng=-1.5197&radius=5.0`
Alertes à proximité

#### POST `/api/alerts` 🔒
Créer une alerte (authentification requise)

**Headers:**
```
Authorization: Bearer <token>
```

**Body:**
```json
{
  "type": "bus_full",
  "description": "Bus complètement rempli",
  "latitude": 12.3714,
  "longitude": -1.5197,
  "line_id": "uuid",
  "validity_duration": 60
}
```

**Types valides:** `bus_full`, `breakdown`, `accident`, `stop_moved`, `road_blocked`, `other`

#### POST `/api/alerts/:id/vote` 🔒
Voter sur une alerte

**Body:**
```json
{
  "vote_type": "up"
}
```

---

### 👤 Utilisateurs

#### GET `/api/users/me` 🔒
Profil de l'utilisateur connecté

#### PUT `/api/users/me` 🔒
Mettre à jour le profil

**Body:**
```json
{
  "name": "Nouveau nom",
  "is_location_enabled": true,
  "avatar_id": "avatar_123"
}
```

#### POST `/api/users/me/location` 🔒
Enregistrer la localisation

**Body:**
```json
{
  "latitude": 12.3714,
  "longitude": -1.5197,
  "accuracy": 10.5
}
```

#### GET `/api/users/me/trips` 🔒
Récupérer les trajets sauvegardés

**Query params:**
- `favorites_only=true` : uniquement les favoris

#### POST `/api/users/me/trips` 🔒
Sauvegarder un trajet

**Body:**
```json
{
  "start_latitude": 12.3714,
  "start_longitude": -1.5197,
  "end_latitude": 12.335,
  "end_longitude": -1.485,
  "estimated_time": 25,
  "estimated_cost": 200,
  "is_favorite": false
}
```

---

## 🔐 Authentification

Les endpoints marqués 🔒 nécessitent un token JWT dans le header :

```
Authorization: Bearer <votre_token>
```

Le token est obtenu lors de la connexion ou l'inscription.

## 🧪 Tester l'API

```bash
# Health check
curl http://localhost:3000/health

# Mode démo
curl -X POST http://localhost:3000/api/auth/demo

# Lister les lignes
curl http://localhost:3000/api/lines

# Arrêts à proximité
curl "http://localhost:3000/api/stops/nearby?lat=12.3714&lng=-1.5197&radius=2"
```

## 📁 Structure

```
backend/
├── config/
│   └── database.js      # Configuration PostgreSQL
├── middleware/
│   └── auth.js          # Middleware d'authentification
├── routes/
│   ├── auth.js          # Routes authentification
│   ├── lines.js         # Routes lignes de bus
│   ├── stops.js         # Routes arrêts
│   ├── buses.js         # Routes bus
│   ├── alerts.js        # Routes alertes
│   └── users.js         # Routes utilisateurs
├── .env                 # Variables d'environnement
├── server.js            # Point d'entrée
└── package.json         # Dépendances
```

## 🔒 Sécurité

- ✅ Helmet pour les headers de sécurité
- ✅ Rate limiting (100 req/15min)
- ✅ CORS configuré
- ✅ JWT pour l'authentification
- ✅ Bcrypt pour le hachage des mots de passe
- ✅ Validation des données d'entrée

## 📊 Base de données

Le backend se connecte à PostgreSQL avec le schéma `dorowere`. 

Assurez-vous d'avoir exécuté `postgresql_local_schema_no_postgis.sql` avant de démarrer le serveur.

## 🐛 Debugging

Logs détaillés en mode développement :
```bash
NODE_ENV=development npm run dev
```

Les requêtes SQL sont loggées avec leur durée d'exécution.
