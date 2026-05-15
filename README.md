# VIPE-R  
Blabla intro rapide  
## Installation  
Dans un premier temps il faut télécharger le répertoire github. Par défaut, 
le répertoire va être copié dans le répertoire courant.
```bash
git clone https://github.com/leacornaille/vipe-r_projet_rshiny_enrichissement.git
cd vipe-r_projet_rshiny_enrichissement
```
### Locale  
Pour pourvoir utiliser l'application, il est possible de lancer en local
le projet depuis R et les packages manquant s'installeront si nécessaires.
```bash
Rscript --shiny_AEF/server.R
```

### Conteneur  
Il est également possible d'utiliser le Dockerfile disponible pour construire  
une image à même d'exécuter l'application. Pour cela :  
1. Construire l'image (le Dockerfile doit être dans le répertoire courant) : 
```bash
docker build -t vipe-r .
```  
Ce procédé peut être long (10 à 20 minutes).  
2. Lancer l'image Docker *OU* passer à la section Bonus qui vous 
correspond (ci-dessous) :
```bash
docker run -p 3838:3838 vipe-r
```
Après cette étape, l'application tourne sur le port 3838 de votre ordinateur. Il
faut maintenant accéder à ce port.
3. Accéder à l'application :  
Ouvrir l'adresse http://localhost:3838 dans votre navigateur.  
#### Bonus Unix (Linux/MacOS)  
Le script `vipe-r.sh` permet de lancer directement l'application une fois
le conteneur construit. Cela suppose que l'image Docker porte le nom `vipe-r`.  
Sous *MacOS* il faut décommenter la dernière ligne du script et commenter 
l'avant-dernière pour que le navigateur puisse se lancer.
```
./vipe-r.sh
```
#### Bonus Windows  
Le script `vipe-r.sh` permet de lancer directement l'application une fois
le conteneur construit. Cela suppose que l'image Docker porte le nom `vipe-r`.
```powershell
.\vipe-r.ps1
```
## Utilisation  
## Citations