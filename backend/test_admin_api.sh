#!/bin/bash

# Script de test de l'API Admin - Dôrô Wéré
# Ce script teste tous les endpoints admin

BASE_URL="http://localhost:3000/api"
PHONE="+22670000000"
PASSWORD="admin123"

echo "🧪 Tests de l'API Admin - Dôrô Wéré"
echo "======================================"
echo ""

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour tester un endpoint
test_endpoint() {
    local method=$1
    local endpoint=$2
    local description=$3
    local data=$4
    local auth_required=$5

    echo -n "Testing ${description}... "
    
    if [ "$auth_required" = "true" ]; then
        if [ -z "$TOKEN" ]; then
            echo -e "${RED}SKIP${NC} (No token)"
            return
        fi
        
        if [ -n "$data" ]; then
            response=$(curl -s -w "\n%{http_code}" -X $method "${BASE_URL}${endpoint}" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $TOKEN" \
                -d "$data")
        else
            response=$(curl -s -w "\n%{http_code}" -X $method "${BASE_URL}${endpoint}" \
                -H "Authorization: Bearer $TOKEN")
        fi
    else
        if [ -n "$data" ]; then
            response=$(curl -s -w "\n%{http_code}" -X $method "${BASE_URL}${endpoint}" \
                -H "Content-Type: application/json" \
                -d "$data")
        else
            response=$(curl -s -w "\n%{http_code}" -X $method "${BASE_URL}${endpoint}")
        fi
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo -e "${GREEN}✓ OK${NC} (${http_code})"
        echo "   Response: ${body:0:100}"
    elif [ "$http_code" = "404" ]; then
        echo -e "${YELLOW}⚠ NOT FOUND${NC} (${http_code})"
    elif [ "$http_code" = "401" ] || [ "$http_code" = "403" ]; then
        echo -e "${RED}✗ UNAUTHORIZED${NC} (${http_code})"
    else
        echo -e "${RED}✗ FAILED${NC} (${http_code})"
        echo "   Response: ${body:0:100}"
    fi
    echo ""
}

# 1. Test de connexion au serveur
echo "1️⃣  Vérification du serveur..."
if curl -s "${BASE_URL}/../" > /dev/null; then
    echo -e "${GREEN}✓ Serveur en ligne${NC}"
else
    echo -e "${RED}✗ Serveur hors ligne${NC}"
    echo "Démarrez le serveur avec: cd backend && npm start"
    exit 1
fi
echo ""

# 2. Connexion admin
echo "2️⃣  Connexion en tant qu'admin..."
login_response=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"phone_number\":\"${PHONE}\",\"password\":\"${PASSWORD}\"}")

http_code=$(echo "$login_response" | tail -n1)
body=$(echo "$login_response" | sed '$d')

if [ "$http_code" = "200" ]; then
    TOKEN=$(echo "$body" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
    USER_ID=$(echo "$body" | grep -o '"user_id":"[^"]*' | cut -d'"' -f4)
    
    if [ -n "$TOKEN" ]; then
        echo -e "${GREEN}✓ Connexion réussie${NC}"
        echo "   Token: ${TOKEN:0:20}..."
        echo "   User ID: ${USER_ID}"
    else
        echo -e "${RED}✗ Token non reçu${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Connexion échouée (${http_code})${NC}"
    echo "   Response: ${body}"
    echo ""
    echo "Vérifiez que:"
    echo "  1. La migration a été exécutée (backend/migrations/add_admin_role.sql)"
    echo "  2. Le compte admin existe avec le bon mot de passe"
    exit 1
fi
echo ""

# 3. Test des endpoints admin
echo "3️⃣  Test des endpoints d'administration..."
echo ""

test_endpoint "GET" "/admin/stats" "Statistiques admin" "" "true"

test_endpoint "GET" "/admin/users" "Liste des utilisateurs" "" "true"

test_endpoint "GET" "/admin/users?page=1&limit=10" "Liste des utilisateurs (paginée)" "" "true"

test_endpoint "GET" "/admin/alerts" "Liste des alertes" "" "true"

test_endpoint "GET" "/admin/alerts?status=active" "Alertes actives" "" "true"

# 4. Test des endpoints publics (pour comparaison)
echo ""
echo "4️⃣  Test des endpoints publics (sans auth)..."
echo ""

test_endpoint "GET" "/lines" "Liste des lignes" "" "false"

test_endpoint "GET" "/stops" "Liste des arrêts" "" "false"

test_endpoint "GET" "/buses" "Liste des bus" "" "false"

# 5. Test d'accès non autorisé
echo ""
echo "5️⃣  Test de sécurité (accès sans token)..."
echo ""

echo -n "Testing Accès stats sans token... "
response=$(curl -s -w "\n%{http_code}" -X GET "${BASE_URL}/admin/stats")
http_code=$(echo "$response" | tail -n1)

if [ "$http_code" = "401" ] || [ "$http_code" = "403" ]; then
    echo -e "${GREEN}✓ Accès refusé correctement${NC} (${http_code})"
else
    echo -e "${RED}✗ Problème de sécurité${NC} (${http_code})"
    echo "   Un utilisateur non authentifié peut accéder aux stats admin !"
fi
echo ""

# 6. Résumé
echo ""
echo "======================================"
echo "✅ Tests terminés"
echo ""
echo "Pour plus de détails:"
echo "  - Consultez GUIDE_ADMIN.md"
echo "  - Documentation backend: backend/README.md"
echo "  - Intégration Flutter: GUIDE_BACKEND_FLUTTER.md"
echo ""
echo "Compte admin par défaut:"
echo "  Téléphone: ${PHONE}"
echo "  Mot de passe: ${PASSWORD}"
echo "  ⚠️  Changez ce mot de passe en production !"
echo ""
