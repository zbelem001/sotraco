#!/bin/bash

# Script de configuration Mapbox pour Dôrô Wéré
# Ce script vous aide à configurer votre token Mapbox GRATUIT

echo "========================================="
echo "🗺️  Configuration Mapbox - Dôrô Wéré"
echo "========================================="
echo ""
echo "Pour afficher la carte, vous devez obtenir un token Mapbox GRATUIT."
echo ""
echo "📋 ÉTAPES :"
echo ""
echo "1. Allez sur : https://account.mapbox.com/auth/signup/"
echo "2. Créez un compte gratuit (email + mot de passe)"
echo "3. Confirmez votre email"
echo "4. Connectez-vous et copiez votre 'Default public token'"
echo "   ⚠️  Le token commence par 'pk.' (PAS 'sk.')"
echo ""
echo "🎁 AVANTAGES :"
echo "   ✅ 50,000 chargements de carte par mois GRATUITS"
echo "   ✅ API de géocodage et routing incluses"
echo "   ✅ Cartes hors-ligne"
echo "   ✅ Styles personnalisés"
echo ""
echo "========================================="
echo ""
read -p "Entrez votre token Mapbox (pk.xxxxx) : " token

if [[ $token == pk.* ]]; then
    echo ""
    echo "✅ Token valide détecté !"
    echo ""
    
    # Configurer dans strings.xml
    sed -i "s/YOUR_MAPBOX_ACCESS_TOKEN_HERE/$token/g" android/app/src/main/res/values/strings.xml
    
    # Configurer dans mapbox_config.dart
    sed -i "s/YOUR_MAPBOX_ACCESS_TOKEN_HERE/$token/g" lib/config/mapbox_config.dart
    
    echo "✅ Token configuré dans :"
    echo "   - android/app/src/main/res/values/strings.xml"
    echo "   - lib/config/mapbox_config.dart"
    echo ""
    echo "🚀 Maintenant lancez l'application :"
    echo "   flutter run"
    echo ""
else
    echo ""
    echo "❌ Erreur : Le token doit commencer par 'pk.'"
    echo "   Exemple : pk.eyJ1IjoibXl1c2VybmFtZSIsImEiOiJjbHh..."
    echo ""
    echo "Réessayez en lançant : ./configure_mapbox.sh"
    exit 1
fi
