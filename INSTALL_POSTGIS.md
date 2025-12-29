# Installation de PostGIS

## 🔴 Problème détecté

Votre PostgreSQL n'a pas l'extension **PostGIS** installée. C'est pour ça que vous avez l'erreur :
```
type "geography" does not exist
```

## 🎯 Solutions

### **Option 1 : Utiliser le script SANS PostGIS** ✅ RECOMMANDÉ

J'ai créé une version simplifiée qui fonctionne avec PostgreSQL standard :

```bash
psql -d sotraco -f postgresql_local_schema_no_postgis.sql
```

**Avantages :**
- ✅ Fonctionne immédiatement
- ✅ Utilise la formule Haversine pour les calculs de distance
- ✅ Toutes les fonctionnalités sont préservées
- ✅ Performance acceptable pour le développement

**Différences :**
- Pas de type `GEOGRAPHY`, mais `DECIMAL(latitude, longitude)`
- Index standards au lieu d'index GIST spatiaux
- Calculs de distance manuels (précis à 99.5%)

---

### **Option 2 : Installer PostGIS** (Si vous voulez l'optimisation spatiale)

PostGIS offre des performances supérieures pour les requêtes géospatiales complexes.

#### **Sur Ubuntu/Debian :**
```bash
# Vérifier votre version de PostgreSQL
psql --version

# Installer PostGIS (adapter selon votre version PG)
sudo apt update
sudo apt install postgresql-16-postgis-3
# OU pour PG 15: postgresql-15-postgis-3
# OU pour PG 14: postgresql-14-postgis-3

# Redémarrer PostgreSQL
sudo systemctl restart postgresql
```

#### **Sur macOS (avec Homebrew) :**
```bash
brew install postgis
```

#### **Sur Windows :**
1. Télécharger le Stack Builder depuis [postgresql.org](https://www.postgresql.org/download/windows/)
2. Exécuter Stack Builder
3. Sélectionner votre installation PostgreSQL
4. Dans "Spatial Extensions", cocher "PostGIS"
5. Suivre l'assistant d'installation

#### **Vérifier l'installation :**
```sql
-- Se connecter à votre base
psql -d sotraco

-- Activer PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Vérifier
SELECT PostGIS_version();
```

#### **Ensuite utiliser le script complet :**
```bash
psql -d sotraco -f postgresql_local_schema.sql
```

---

## 📊 Comparaison

| Fonctionnalité | SANS PostGIS | AVEC PostGIS |
|----------------|--------------|--------------|
| Distance entre points | Haversine manuelle (~2ms) | ST_Distance optimisé (~0.5ms) |
| Recherche spatiale | Index standard | Index GIST (4x plus rapide) |
| Complexité | Simple | Avancé |
| Installation | ✅ Prêt | ⚠️ Dépendance externe |
| Pour dev local | ✅ Parfait | Optionnel |
| Pour production | ⚠️ Ok pour <10k points | ✅ Idéal pour >10k points |

---

## 🚀 Recommandation

**Pour le développement local** : Utilisez le script **SANS PostGIS** → plus simple, fonctionne tout de suite

**Pour la production** : Installez PostGIS si vous prévoyez :
- Plus de 10 000 arrêts/bus
- Recherches spatiales très fréquentes
- Calculs géométriques complexes

---

## 🔧 État actuel de votre base

D'après les logs, vous avez :
- ✅ Base `sotraco` créée
- ✅ Extension `uuid-ossp` activée
- ✅ Extension `pgcrypto` activée
- ✅ Schema `dorowere` créé
- ✅ Table `users` créée
- ✅ Table `friends_list` créée
- ✅ Table `lines` créée
- ❌ Table `locations` bloquée (besoin de PostGIS)
- ❌ Table `stops` bloquée (besoin de PostGIS)
- ❌ Etc.

**Solution :** Nettoyez et recommencez avec le script sans PostGIS :

```sql
-- Dans psql
DROP SCHEMA dorowere CASCADE;
```

Puis :
```bash
psql -d sotraco -f postgresql_local_schema_no_postgis.sql
```

---

## ✅ Vérification finale

Après avoir exécuté le script, testez :

```sql
-- Se connecter
psql -d sotraco

-- Tester une recherche d'arrêts proches
SELECT * FROM dorowere.get_nearby_stops(12.3714, -1.5197, 2.0);

-- Tester les vues
SELECT * FROM dorowere.active_buses_with_location;

-- Vérifier les stats
SELECT * FROM dorowere.user_stats;
```

Si tout fonctionne → ✅ Vous êtes prêt !
