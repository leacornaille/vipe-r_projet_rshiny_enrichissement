# Lancer le conteneur Docker en arrière-plan
docker run -d -p 3838:3838 vipe-r

# Attendre que le conteneur soit prêt
Start-Sleep -Seconds 3

# Ouvrir le navigateur par défaut
Start-Process "http://localhost:3838"