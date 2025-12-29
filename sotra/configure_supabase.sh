#!/bin/bash

# Script de configuration Supabase pour Dôrô Wéré

echo "========================================="
echo "🗄️  Configuration Supabase - Dôrô Wéré"
echo "========================================="
echo ""
echo "Pour connecter l'app à votre base de données Supabase :"
echo ""
echo "📋 ÉTAPES :"
echo ""
echo "1. Allez dans votre projet Supabase"
echo "2. Cliquez sur ⚙️  Settings > API"
echo "3. Copiez :"
echo "   - Project URL"
echo "   - anon public key"
echo ""
echo "========================================="
echo ""

read -p "Entrez votre Project URL (https://xxxxx.supabase.co) : " url
read -p "Entrez votre anon public key (eyJhbGciOiJIUz...) : " key

if [[ $url == https://*.supabase.co ]] && [[ $key == eyJ* ]]; then
    echo ""
    echo "✅ Informations valides !"
    echo ""
    
    # Configurer dans supabase_config.dart
    sed -i "s|YOUR_SUPABASE_URL_HERE|$url|g" lib/config/supabase_config.dart
    sed -i "s|YOUR_SUPABASE_ANON_KEY_HERE|$key|g" lib/config/supabase_config.dart
    
    echo "✅ Configuration terminée dans :"
    echo "   - lib/config/supabase_config.dart"
    echo ""
    echo "🚀 Maintenant lancez l'application :"
    echo "   flutter run"
    echo ""
else
    echo ""
    echo "❌ Erreur : Vérifiez vos informations"
    echo "   - URL doit être : https://xxxxx.supabase.co"
    echo "   - Key doit commencer par : eyJ"
    echo ""
    echo "Réessayez en lançant : ./configure_supabase.sh"
    exit 1
fi
