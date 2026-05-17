# VIPE-R  
VIPE-R est une interface Shiny conçue pour accompagner l'analyse de données 
transcriptomiques issues d'expériences RNA-seq. À partir d'un tableau de gènes 
différentiellement exprimés (DEG), l'application permet de :

- **Visualiser** les DEG sous forme de volcano plot interactif
- **Filtrer** les gènes selon des seuils de Log2FC et de p-value ajustée
- **Réaliser des analyses d'enrichissement fonctionnel** via deux méthodes 
complémentaires : ORA et GSEA
- **Explorer** les termes GO (Gene Ontology) et les voies métaboliques 
(KEGG, Reactome)
- **Exporter** les graphiques et tableaux pour intégration dans des rapports ou 
publications

L'application supporte deux organismes : *Homo sapiens*, *Mus musculus*.  
---
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
---
## Utilisation
### 1. Format des données
Le fichier d'entrée doit être un tableau tabulé (`.csv`, `.tsv` ou `.txt`) avec 
**obligatoirement** les colonnes suivantes :

| Colonne    | Description                    | Exemple        |
| ---------- | ------------------------------ | -------------- |
| `GeneName` | Nom du gène (symbole HGNC/MGI) | `TP53`, `Actb` |
| `ID`       | Identifiant Entrez ou Ensembl  | `7157`         |
| `baseMean` | Expression moyenne normalisée  | `245.3`        |
| `log2FC`   | Log2 du fold-change            | `2.45`         |
| `pval`     | p-value brute                  | `0.003`        |
| `padj`     | p-value corrigée (ex. BH/FDR)  | `0.041`        |

> **Les noms de colonnes doivent être exactement identiques** à ceux indiqués 
ci-dessus. L'absence de l'une de ces colonnes provoquera une erreur lors du 
chargement.

### 2. Importer ses données

1. Dans la **barre latérale gauche**, repérez le bouton **« Choisissez un fichier csv »**.
2. Cliquez sur ce bouton et sélectionnez votre fichier (`.csv`, `.tsv` ou `.txt`).
3. Sélectionnez ensuite l'**organisme** correspondant à votre expérience dans le 
menu déroulant :
   - `homo sapiens` → base de données `org.Hs.eg.db`
   - `mus musculus` → base de données `org.Mm.eg.db`
4. Une fois le fichier chargé, tous les onglets de l'application peuvent être 
utilisé.

> Le chargement du fichier **ne déclenche pas automatiquement** les analyses d'enrichissement. Vous devrez vous rendre dans l'onglet souhaité et cliquer sur le bouton **« Lancer »**.
## Citations