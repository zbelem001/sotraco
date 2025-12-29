#!/bin/bash

# Script de démarrage du backend Dôrô Wéré

echo "🚀 Démarrage du serveur backend Dôrô Wéré..."
echo ""

# Vérifier que Node.js est installé
if ! command -v node &> /dev/null; then
    echo "❌ Node.js n'est pas installé."
    echo "   Installez Node.js depuis https://nodejs.org/"
    exit 1
fi

# Vérifier que npm est installé
if ! command -v npm &> /dev/null; then
    echo "❌ npm n'est pas installé."
    exit 1
fi

# Vérifier que le fichier .env existe
if [ ! -f .env ]; then
    echo "❌ Le fichier .env n'existe pas."
    echo "   Copiez .env.example vers .env et configurez-le :"
    echo "   cp .env.example .env"
    exit 1
fi

# Vérifier que les dépendances sont installées
if [ ! -d node_modules ]; then
    echo "📦 Installation des dépendances..."
    npm install
fi

echo ""
echo "✅ Tout est prêt !"
echo ""
echo "📡 Le serveur va démarrer sur http://localhost:3000"
echo ""
echo "Endpoints disponibles :"
echo "  - POST /api/auth/register      # Inscription"
echo "  - POST /api/auth/login         # Connexion"
echo "  - GET  /api/lines              # Liste des lignes"
echo "  - GET  /api/stops              # Liste des arrêts"
echo "  - GET  /api/buses              # Liste des bus"
echo "  - GET  /api/admin/stats        # Stats admin (authentification requise)"
echo ""
echo "Pour arrêter le serveur : Ctrl+C"
echo ""
echo "─────────────────────────────────────────────────────────"
echo ""

# Démarrer le serveur
npm start
