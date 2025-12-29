# Guide Administration - Dôrô Wéré

## 📋 Vue d'ensemble

Le système d'administration de Dôrô Wéré permet aux administrateurs de gérer l'ensemble de l'application : utilisateurs, lignes, arrêts, bus et alertes.

## 🔐 Accès Administrateur

### Compte Admin par défaut

Lors de l'exécution de la migration, un compte administrateur est créé :

```
Téléphone: +22670000000
Mot de passe: admin123
```

**⚠️ IMPORTANT**: Changez ce mot de passe après la première connexion !

### Vérification des droits

Le système vérifie automatiquement que l'utilisateur a le rôle `admin` avant de permettre l'accès aux endpoints admin.

## 🚀 Mise en place

### 1. Exécuter la migration

```bash
cd backend
psql -h dpg-cu2ni23qf0us73d8p41g-a.oregon-postgres.render.com \
     -p 5432 \
     -U doro_were_user \
     -d doro_were \
     -f migrations/add_admin_role.sql
```

Ou en local :

```bash
psql -h 127.0.0.1 -p 5432 -U postgres -d sotraco -f migrations/add_admin_role.sql
```

### 2. Démarrer le serveur backend

```bash
cd backend
npm install
npm start
```

Le serveur démarre sur `http://localhost:3000`.

### 3. Tester l'accès admin

```bash
# Se connecter avec le compte admin
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+22670000000",
    "password": "admin123"
  }'

# Récupérer le token dans la réponse
# Ensuite tester un endpoint admin
curl -X GET http://localhost:3000/api/admin/stats \
  -H "Authorization: Bearer VOTRE_TOKEN"
```

## 📱 Interface Admin Flutter

### Accès depuis l'application

L'interface admin est accessible via le menu latéral (drawer) uniquement pour les utilisateurs avec le rôle `admin`.

### Fonctionnalités disponibles

#### 1. Tableau de bord

- **Statistiques globales** :
  - Nombre total d'utilisateurs
  - Nombre de chauffeurs
  - Nombre d'administrateurs
  - Nombre de lignes
  - Nombre d'arrêts
  - Nombre de bus (total et actifs)
  - Nombre d'alertes (total et actives)
  - Nombre de trajets

- **Activité récente** : Les 10 dernières actions sur la plateforme

#### 2. Gestion des utilisateurs

- **Liste des utilisateurs** avec filtres :
  - Par rôle (user, driver, admin)
  - Par recherche (nom ou téléphone)

- **Actions** :
  - Modifier un utilisateur (nom, rôle)
  - Supprimer un utilisateur
  - Voir les statistiques (nombre de trajets, alertes créées)

#### 3. Gestion des alertes

- **Liste des alertes** avec filtres :
  - Par type (bus_full, breakdown, accident, etc.)
  - Par statut (active, expirée, toutes)

- **Informations affichées** :
  - Type d'alerte
  - Description
  - Créateur
  - Nombre de confirmations et refus
  - Statut (active/expirée)

- **Actions** :
  - Supprimer une alerte

#### 4. Gestion du transport

##### Lignes
- Créer une nouvelle ligne
- Modifier une ligne existante
- Supprimer une ligne
- Associer/Dissocier des arrêts

##### Arrêts
- Créer un nouvel arrêt
- Modifier un arrêt existant
- Supprimer un arrêt

##### Bus
- Créer un nouveau bus
- Modifier un bus existant
- Supprimer un bus
- Activer/Désactiver un bus

## 🔧 API Admin

### Authentification

Tous les endpoints admin nécessitent :
1. Un token JWT valide (header `Authorization: Bearer TOKEN`)
2. Le rôle `admin` dans la base de données

### Endpoints disponibles

#### Statistiques
```
GET /api/admin/stats
```

#### Utilisateurs
```
GET    /api/admin/users                    # Liste avec pagination
PUT    /api/admin/users/:userId            # Modifier
DELETE /api/admin/users/:userId            # Supprimer
```

#### Lignes
```
POST   /api/admin/lines                    # Créer
PUT    /api/admin/lines/:lineId            # Modifier
DELETE /api/admin/lines/:lineId            # Supprimer

POST   /api/admin/lines/:lineId/stops/:stopId    # Associer arrêt
DELETE /api/admin/lines/:lineId/stops/:stopId    # Dissocier arrêt
```

#### Arrêts
```
POST   /api/admin/stops                    # Créer
PUT    /api/admin/stops/:stopId            # Modifier
DELETE /api/admin/stops/:stopId            # Supprimer
```

#### Bus
```
POST   /api/admin/buses                    # Créer
PUT    /api/admin/buses/:busId             # Modifier
DELETE /api/admin/buses/:busId             # Supprimer
```

#### Alertes
```
GET    /api/admin/alerts                   # Liste avec filtres
DELETE /api/admin/alerts/:alertId          # Supprimer
```

## 👥 Gestion des rôles

### Rôles disponibles

1. **user** (utilisateur standard)
   - Consulter les lignes, arrêts, bus
   - Créer des alertes
   - Sauvegarder des trajets
   - Voir sa position et celle des amis

2. **driver** (chauffeur)
   - Toutes les permissions de `user`
   - Mettre à jour la position du bus
   - Voir les informations de sa ligne

3. **admin** (administrateur)
   - Accès complet à toutes les fonctionnalités
   - Gestion des utilisateurs
   - Gestion du contenu (lignes, arrêts, bus)
   - Modération des alertes
   - Accès aux statistiques

### Promouvoir un utilisateur en admin

Via SQL :
```sql
UPDATE dorowere.users 
SET role = 'admin' 
WHERE phone_number = '+22512345678';
```

Ou via l'interface admin (depuis un compte admin existant).

## 🔒 Sécurité

### Middleware d'authentification

Le middleware `authenticateToken` vérifie :
- Présence du token JWT
- Validité du token
- Extraction de l'ID utilisateur

### Middleware d'autorisation

Le middleware `requireAdmin` vérifie :
- Que l'utilisateur existe dans la DB
- Que son rôle est `admin`

### Bonnes pratiques

1. **Ne jamais commit le fichier .env**
2. **Changer le JWT_SECRET** en production
3. **Utiliser HTTPS** en production
4. **Changer le mot de passe admin** par défaut
5. **Limiter le nombre d'admins** aux personnes de confiance
6. **Logger les actions admin** pour audit

## 🐛 Dépannage

### Erreur 401 Unauthorized

**Problème** : Token manquant ou invalide

**Solution** :
```bash
# Vérifier que le token est présent dans le header
Authorization: Bearer votre_token_ici
```

### Erreur 403 Forbidden

**Problème** : L'utilisateur n'a pas le rôle admin

**Solution** :
```sql
-- Vérifier le rôle de l'utilisateur
SELECT user_id, display_name, phone_number, role 
FROM dorowere.users 
WHERE user_id = 'UUID_ICI';

-- Si nécessaire, promouvoir en admin
UPDATE dorowere.users 
SET role = 'admin' 
WHERE user_id = 'UUID_ICI';
```

### Migration échoue

**Problème** : La colonne `role` existe déjà

**Solution** :
```sql
-- Vérifier si la colonne existe
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'dorowere' 
  AND table_name = 'users' 
  AND column_name = 'role';

-- Si elle n'existe pas, créer manuellement
ALTER TABLE dorowere.users 
ADD COLUMN role VARCHAR(20) DEFAULT 'user';
```

### Interface admin vide

**Problème** : Erreur CORS ou backend non démarré

**Solution** :
```bash
# Vérifier que le backend tourne
curl http://localhost:3000/

# Vérifier les logs du serveur
cd backend
npm start

# Vérifier la configuration CORS dans server.js
```

## 📊 Monitoring

### Logs importants

Le serveur log automatiquement :
- Toutes les requêtes admin (avec user_id)
- Les erreurs serveur
- Les tentatives d'accès non autorisées

### Requêtes utiles

```sql
-- Dernières connexions admin
SELECT user_id, display_name, last_seen 
FROM dorowere.users 
WHERE role = 'admin' 
ORDER BY last_seen DESC;

-- Actions récentes
SELECT 'user' as type, created_at FROM dorowere.users
UNION ALL
SELECT 'alert', created_at FROM dorowere.alerts
UNION ALL
SELECT 'trip', created_at FROM dorowere.trips
ORDER BY created_at DESC
LIMIT 20;

-- Statistiques d'utilisation
SELECT 
    DATE(created_at) as date,
    COUNT(*) as total_alerts
FROM dorowere.alerts
WHERE created_at > CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

## 📞 Support

Pour toute question ou problème avec le système d'administration, contactez l'équipe de développement.
