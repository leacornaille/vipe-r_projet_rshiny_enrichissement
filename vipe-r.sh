#!/bin/bash

# Lancer le conteneur Docker en arrière plan
docker run -d -p 3838:3838 vipe-r

# Attendre que le conteneur soit prêt
sleep 3

# Ouvrir le navigateur par défaut
xdg-open http://localhost:3838  # Linux
# open http://localhost:3838   # macOS (à décommenter si nécessaire)