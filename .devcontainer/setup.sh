#!/bin/bash
set -ex

WORKSPACE="/workspaces/tp-cd-github-flow"

echo "==> Installation des dépendances npm..."
npm ci

echo "==> Création de la base de données SQLite et initialisation des données de démonstration..."
DATABASE_URL="./dev.db" npx ts-node db/seed.ts

echo "==> Démarrage des registres locaux (Verdaccio + registry:2)..."
docker compose -f "$WORKSPACE/docker-compose.yml" up -d --build

echo "==> Connexion du DevContainer au réseau Docker cd-network..."
docker network connect tp-cd-github-flow_cd-network "$(hostname)" 2>/dev/null || true

echo "==> Démarrage des relais socat (localhost → registres Docker)..."
pkill -f "socat TCP-LISTEN:4873" 2>/dev/null || true
pkill -f "socat TCP-LISTEN:5000" 2>/dev/null || true
nohup socat TCP-LISTEN:4873,fork,reuseaddr TCP:verdaccio:4873 > /dev/null 2>&1 &
nohup socat TCP-LISTEN:5000,fork,reuseaddr TCP:registry:5000 > /dev/null 2>&1 &

echo "==> Attente du démarrage de Verdaccio..."
until curl -sf http://localhost:4873/-/ping > /dev/null 2>&1; do
  echo "   ... Verdaccio pas encore prêt, attente 2s..."
  sleep 2
done

echo "==> Attente du démarrage du registry Docker..."
until curl -sf http://localhost:5000/v2/ > /dev/null 2>&1; do
  echo "   ... registry:2 pas encore prêt, attente 2s..."
  sleep 2
done

echo "==> Installation de act (exécution locale des GitHub Actions)..."
# 1. On télécharge le script d'installation officiel
curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh -o install_act.sh

# 2. On l'exécute explicitement en forçant le dossier système de destination
sudo bash install_act.sh -b /usr/local/bin/

# 3. On nettoie le script temporaire
rm install_act.sh

# 4. On s'assure que le binaire est exécutable par tout le monde
sudo chmod +x /usr/local/bin/act

echo "==> Pré-téléchargement de l'image Docker pour act..."
docker pull catthehacker/ubuntu:act-24.04

echo "==> Installation de Trivy (scan de sécurité)..."
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin

echo ""
echo "✅ Environnement prêt !"
echo "   - Application : npm run start:dev  →  http://localhost:3000"
echo "   - Swagger      : http://localhost:3000/api"
echo "   - Tests        : npm test"
echo "   - CI locale    : act"
echo "   - Verdaccio    : http://localhost:4873"
echo "   - Registry     : http://localhost:5000/v2/"
