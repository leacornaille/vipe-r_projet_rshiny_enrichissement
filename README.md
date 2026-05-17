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

**Note :**L'application supporte deux organismes : *Homo sapiens*, *Mus musculus*. 

---  

## Installation  
Dans un premier temps, il faut télécharger le répertoire github. Par défaut, 
le répertoire va être copié dans le répertoire courant.
```bash
git clone https://github.com/leacornaille/vipe-r_projet_rshiny_enrichissement.git
cd vipe-r_projet_rshiny_enrichissement
```
### Locale   
Il est possible de lancer l'application en local depuis R et les 
packages manquant s'installeront si nécessaires. Vérifiez que le répertoire
de travail R est bien la racine du projet.
```R
shiny::runApp('./shiny_AEF')
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
4. Une fois le fichier chargé, allez dans l'onglet visualisation pour filtrer les données via la pvalue et le log2FC
5. Les analyses d'enrichissement peuvent être lancées

> Le chargement du fichier **ne déclenche pas automatiquement** les analyses d'enrichissement. Vous devrez vous rendre dans l'onglet souhaité et cliquer sur le bouton **« Lancer »**.

## Citations  
### Paquets CRAN

**shiny**  
Chang, W., Cheng, J., Allaire, J. J., Sievert, C., Schloerke, B., Xie, Y., ... & Dipert, A. (2023). shiny: Web Application Framework for R [R package version 1.7.4]. https://CRAN.R-project.org/package=shiny

**shinydashboard**  
Chang, W., & Cheng, J. (2023). shinydashboard: Interactive Dashboards for R [R package version 0.7.2]. https://CRAN.R-project.org/package=shinydashboard

**shinyBS**  
Brown, E. (2023). shinyBS: Twitter Bootstrap Components for Shiny [R package version 0.61.0]. https://CRAN.R-project.org/package=shinyBS

**shinyWidgets**  
Perrier, V. (2023). shinyWidgets: Custom Inputs Widgets for Shiny [R package version 0.7.6]. https://CRAN.R-project.org/package=shinyWidgets

**shinydashboardPlus**  
Granjon, D. (2023). shinydashboardPlus: Extensions for 'shinydashboard' [R package version 2.0.0]. https://CRAN.R-project.org/package=shinydashboardPlus

**fresh**  
Granjon, D. (2023). fresh: Make It Easy to Create 'shiny' UIs [R package version 0.5.2]. https://CRAN.R-project.org/package=fresh

**plotly**  
Sievert, C., Parmer, C., Hocking, T., Chamberlain, S., Ram, K., Corvellec, M., & Despouy, P. (2023). plotly: Interactive Graphs for R [R package version 4.10.1]. https://CRAN.R-project.org/package=plotly

**DT**  
Xie, Y. (2023). DT: A Wrapper of the JavaScript Library 'DataTables' [R package version 0.26]. https://CRAN.R-project.org/package=DT

**waiter**  
Coene, J. (2023). waiter: Loading Screens for 'shiny' Applications [R package version 0.2.3]. https://CRAN.R-project.org/package=waiter

**data.table**  
Dowle, M., & Srinivasan, A. (2023). data.table: Extension of data.frame [R package version 1.14.8]. https://CRAN.R-project.org/package=data.table

**BiocManager**  
Morgan, M. (2023). BiocManager: Access the Bioconductor Project Package Repository [R package version 1.30.20]. https://CRAN.R-project.org/package=BiocManager

**shinycssloaders**  
Olshanskiy, A. (2023). shinycssloaders: Add Loading Animations to 'shiny' Outputs [R package version 1.0.0]. https://CRAN.R-project.org/package=shinycssloaders

**shinyjqui**  
Tiateng, Y. (2023). shinyjqui: jQuery UI Interactions for Shiny [R package version 0.4.1]. https://CRAN.R-project.org/package=shinyjqui

**markdown**  
Allaire, J. J., R Core Team, Xie, Y., McPherson, J., Srinivasan, A., Sievert, C., ... & Yutani, H. (2023). markdown: Render Markdown with the C 'cmark' Library [R package version 1.11]. https://CRAN.R-project.org/package=markdown

**ggbeeswarm**  
Clarke, E. (2023). ggbeeswarm: Bee Swarm Plot, an Alternative to Stripchart [R package version 0.7.1]. https://CRAN.R-project.org/package=ggbeeswarm

**ggplot2**  
Wickham, H., Chang, W., Henry, L., Pedersen, T. L., Takahashi, K., Wilke, C., ... & Dunnington, D. (2023). ggplot2: Create Elegant Data Visualisations Using the Grammar of Graphics [R package version 3.4.2]. https://CRAN.R-project.org/package=ggplot2

**dplyr**  
Wickham, H., François, R., Henry, L., Müller, K., & Vaughan, D. (2023). dplyr: A Fast, Consistent Tool for Working with Data Frame Like Objects [R package version 1.1.2]. https://CRAN.R-project.org/package=dplyr

**stringr**  
Wickham, H. (2023). stringr: Simple, Consistent Wrappers for Common String Operations [R package version 1.5.0]. https://CRAN.R-project.org/package=stringr

**ggrepel**  
Slowikowski, K. (2023). ggrepel: Repulsive Text Labelling for 'ggplot2' [R package version 0.9.3]. https://CRAN.R-project.org/package=ggrepel

**ggtext**  
Wilke, C. (2023). ggtext: Improved Text Rendering Support for 'ggplot2' [R package version 0.1.2]. https://CRAN.R-project.org/package=ggtext

**ggraph**  
Pedersen, T. L. (2023). ggraph: An Implementation of Graph Grammar [R package version 2.1.0]. https://CRAN.R-project.org/package=ggraph

**igraph**  
Csardi, G., & Nepusz, T. (2023). igraph: Network Analysis and Visualization [R package version 1.4.3]. https://CRAN.R-project.org/package=igraph

**ggarchery**  
Bovee, E. B. (2023). ggarchery: Extensions to 'ggplot2' for Visualizing Archery Scores [R package version 0.1.0]. https://CRAN.R-project.org/package=ggarchery

**shinybusy**  
Chang, W. (2023). shinybusy: Show Busy Indicators for Shiny Applications [R package version 0.2.1]. https://CRAN.R-project.org/package=shinybusy

### Paquets Bioconductor

**clusterProfiler**  
Yu, G. (2023). clusterProfiler: Universal Enrichment Set Analysis for Functional Annotations and Visualization [R package version 4.8.0]. https://bioconductor.org/packages/clusterProfiler/

**GO.db**  
Bioconductor Package Maintainer. (2023). GO.db: A Set of Annotation Maps for the Gene Ontology [R package version 3.18.0]. https://bioconductor.org/packages/GO.db/

**org.Mm.eg.db**  
Bioconductor Package Maintainer. (2023). org.Mm.eg.db: Genome wide annotation for Mouse [R package version 3.18.0]. https://bioconductor.org/packages/org.Mm.eg.db/

**DOSE**  
Yu, G. (2023). DOSE: Disease Ontology Semantic and Enrichment analysis [R package version 3.26.0]. https://bioconductor.org/packages/DOSE/

**pathview**  
Luo, W. (2023). pathview: a tool set for pathway-based data integration and visualization [R package version 1.40.0]. https://bioconductor.org/packages/pathview/

**enrichplot**  
Yu, G. (2023). enrichplot: Visualization of Functional Enrichment Result [R package version 1.20.0]. https://bioconductor.org/packages/enrichplot/

**org.Hs.eg.db**  
Bioconductor Package Maintainer. (2023). org.Hs.eg.db: Genome wide annotation for Human [R package version 3.18.0]. https://bioconductor.org/packages/org.Hs.eg.db/

**ReactomePA**  
Yu, G. (2023). ReactomePA: Reactome Pathway Analysis [R package version 1.44.0]. https://bioconductor.org/packages/ReactomePA/

**reactome.db**  
Bioconductor Package Maintainer. (2023). reactome.db: A curated database of reactions and pathways [R package version 1.86.0]. https://bioconductor.org/packages/reactome.db/


