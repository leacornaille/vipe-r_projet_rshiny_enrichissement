# Guide d'interprétation des figures — VIPE-R

---

## 1. Volcano Plot

### Description

Le volcano plot est la figure principale de l'analyse DEG. Il donne une vue 
d'ensemble immédiate des gènes analysés.

![](/home/cornalea/snap/marktext/9/.config/marktext/images/2026-05-05-23-14-15-image.png)

### Lecture axe par axe

**Axe X — Log2 Fold Change (Log2FC)**  

- Représente la magnitude du changement d'expression entre deux conditions
- Log2FC = 1 signifie une expression **doublée** (2¹ = 2×)
- Log2FC = −1 signifie une expression **divisée par 2** (2⁻¹ = 0.5×)
- Les valeurs entre −1 et +1 correspondent à des changements faibles (< 2 fois)

**Axe Y — −log₁₀(p-value ajustée)**  

- Plus le point est haut, plus la différence est statistiquement significative
- −log₁₀(0.05) ≈ 1.3 → seuil de significativité à 5 %
- −log₁₀(0.001) = 3 → haute confiance statistique

### Zones d'interprétation

| Zone          | Couleur       | Signification                                             |
| ------------- | ------------- | --------------------------------------------------------- |
| Droite, haute | Rouge / chaud | Gènes **sur-exprimés** et significatifs → candidats Up    |
| Gauche, haute | Bleu / froid  | Gènes **sous-exprimés** et significatifs → candidats Down |
| Centre bas    | Gris          | Gènes non-significatifs ou faiblement régulés             |

### Questions à se poser

- Le nombre de gènes Up et Down est-il équilibré ? Un déséquilibre peut 
signaler une réponse biologique directionnelle.
- Y a-t-il des outliers extrêmes (très haut ou très à droite/gauche) ? 
Ces gènes méritent une attention particulière.
- La forme générale est-elle "en V symétrique" (réponse diffuse) ou asymétrique 
(activation/répression ciblée) ?

---

## 2. Figures ORA — Dotplot

### Description

Le dotplot est la **visualisation recommandée en première intention** pour l'ORA. 
Chaque point représente un terme GO ou un pathway enrichi. 

<img title="" src="file:///home/cornalea/snap/marktext/9/.config/marktext/images/2026-05-05-23-18-10-image.png" alt="" width="608">

| Visuel              | Signification                                                       |
| ------------------- | ------------------------------------------------------------------- |
| **GeneRatio**       | Fraction des DEG annotés dans ce terme = k/n                        |
| **Taille du point** | Nombre absolu de DEG dans le terme (Count)                          |
| **Couleur**         | Valeur de p.adjust — du plus au moins significatif selon la palette |

### Points d'attention

- Un terme avec un **grand GeneRatio mais peu de gènes** (Count faible) peut 
être un terme très spécifique avec peu de membres — à vérifier.
- Un terme avec un **GeneRatio faible mais Count élevé** correspond à un 
large terme dont seulement une faible fraction est dans votre liste — terme peu 
spécifique, attention à la sur-interprétation.
- Les termes en **haut de la liste** sont classés par GeneRatio ou Count — 
vérifier le critère de tri affiché.

---

## 3. Figures ORA — Barplot

### Description

Le barplot représente les termes enrichis sous forme de barres horizontales, 
classées par Count ou par GeneRatio.

<img src="file:///home/cornalea/snap/marktext/9/.config/marktext/images/2026-05-05-23-20-06-image.png" title="" alt="" width="603">

### Lecture

- **Longueur de la barre** : Count (nombre de DEG dans le terme) — plus la 
barre est longue, plus de gènes de votre liste appartiennent à ce terme
- **Couleur** : p.adjust 

### Avantage / Inconvénient

Très lisible, idéal pour identifier rapidement le 
**top des termes les plus peuplés**.  
Ne montre pas le ratio (un terme peut avoir 50 gènes mais appartenir à un terme 
qui en contient 5000 → faible enrichissement relatif).  

---

## 4. Figures ORA — Cnetplot

### Description

Le cnetplot est un **réseau bipartite** reliant les gènes (DEG) aux termes 
GO/pathways dans lesquels ils sont annotés. C'est la figure la plus informative 
pour comprendre quels gènes "portent" l'enrichissement.

<img src="file:///home/cornalea/snap/marktext/9/.config/marktext/images/2026-05-05-23-22-20-image.png" title="" alt="" width="583">

- **Grands nœuds colorés** : termes GO ou pathways

- **Petits nœuds** : gènes individuels (DEG)

- **Arêtes** : indiquent qu'un gène est annoté dans un terme

- **Gènes connectés à plusieurs termes** : gènes "hubs" — fortement 
impliqués dans plusieurs processus

### Questions à se poser

- Certains gènes sont-ils au centre du réseau, connectés à de nombreux termes ? 
Ce sont des **gènes clés biologiques** méritant une investigation prioritaire.
- Des clusters de termes partagent-ils les mêmes gènes ? Cela indique une 
**redondance** ou des processus biologiquement liés.
- Les termes sont-ils isolés ou interconnectés ? Un réseau fortement connecté 
suggère une **réponse biologique coordonnée**.

---

## 5. Figures ORA — Treeplot

### Description

Le treeplot regroupe les termes enrichis selon leur **similarité sémantique** 
dans la hiérarchie GO, sous forme d'arbre ou de dendrogramme. Il permet de 
réduire la redondance visuelle.

<img src="file:///home/cornalea/snap/marktext/9/.config/marktext/images/2026-05-05-23-23-48-image.png" title="" alt="" width="614">

### Lecture

- Les termes regroupés dans la même branche partagent une même fonction
- Les **clusters** sont souvent étiquetés par le terme ancêtre commun le plus 
représentatif
- La hauteur de la branche peut refléter la distance sémantique entre termes

### Quand l'utiliser ?

- Quand le dotplot ou barplot montre **beaucoup de termes redondants** 
(ex. 15 variations autour de "immune response")
- Pour une figure synthétique dans une publication

---

## 6. Figures ORA — Emapplot (Netplot)

### Description

L'emapplot (Enrichment MAP plot) est un réseau de **termes GO uniquement**, où 
les liens représentent leur similarité (gènes partagés). Contrairement au 
cnetplot, les gènes individuels ne sont pas affichés.

![](/home/cornalea/snap/marktext/9/.config/marktext/images/2026-05-05-23-25-28-image.png)

### Lecture

- **Nœuds** : termes GO/pathways enrichis
- **Taille des nœuds** : nombre de gènes (Count ou GeneRatio)
- **Couleur des nœuds** : p.adjust
- **Épaisseur/existence des arêtes** : proportion de gènes partagés entre deux 
termes (similarité de Jaccard)

### Interprétation

- Des **clusters** de termes très interconnectés indiquent un processus 
biologique dominant.
- Des **nœuds isolés** représentent des fonctions enrichies 
indépendantes des autres. 

---

## 7. Figures ORA — Goplot

### Description

Le goplot est propre à l'analyse GO. Il affiche les termes enrichis dans 
leur **contexte hiérarchique** au sein du DAG GO, en indiquant leur significativité.

![](/home/cornalea/snap/marktext/9/.config/marktext/images/2026-05-05-23-26-25-image.png)

### Lecture

- Les termes parents (généraux) sont en haut, les termes fils (spécifiques) en bas
- La couleur ou la taille des nœuds encode la significativité ou le GeneRatio
- Le sens des flèches suit la relation "is_a" de l'ontologie

### Utilité

Ce graphique est particulièrement utile pour vérifier si l'enrichissement 
est **spécifique** (concentré sur des termes feuilles précis) ou **général** 
(porté par des termes parents larges).

---

## 8. Figures GSEA — GSEA Plot (Enrichissement)

### Description

C'est la **figure canonique de la GSEA**, indispensable pour valider et 
interpréter un terme enrichi. Elle se décompose en trois panneaux superposés.

![](/home/cornalea/snap/marktext/9/.config/marktext/images/2026-05-05-23-27-33-image.png)

### Lecture

**Panneau 1 - Running Enrichment Score**

- La courbe monte quand un gène du gene set est rencontré dans la liste classée
- La courbe descend légèrement à chaque gène hors du gene set
- Le **pic maximal** = Enrichment Score (ES)
- Si le pic est **à gauche** → les gènes du set sont concentrés parmi les gènes 
**sur-exprimés** (NES > 0)
- Si le pic est **à droite** → concentrés parmi les **sous-exprimés** (NES < 0)

**Panneau 2 - Barcode plot**

- Chaque barre verticale = un gène du gene set
- Des barres **denses à gauche** = enrichissement en sur-expression
- Des barres **denses à droite** = enrichissement en sous-expression
- La zone entre la liste classée et le pic = **Leading Edge subset** 
(les gènes qui "portent" l'enrichissement)

**Panneau 3 - Classement**

- Représente le score (log2FC ou pval) de chaque gène
- La transition du rouge (positif) vers le bleu (négatif) marque la frontière 
entre Up et Down
- Permet de vérifier que la liste est bien polarisée

### Métriques à lire dans le titre/annotation

| Métrique                 | Description                 | Bon résultat           |
| ------------------------ | --------------------------- | ---------------------- |
| **NES**                  | Normalized Enrichment Score |                        |
| **p-value**              | Significativité empirique   | < 0.05                 |
| **p.adjust (FDR q-val)** | Après correction            | < 0.25 (GSEA standard) |

> En GSEA, le seuil de FDR conventionnellement accepté est **< 0.25** (plus 
permissif qu'en ORA à 0.05), en raison de la plus faible puissance 
statistique avec les permutations.

---

## 9. Figures GSEA — Ridgeplot

### Description

Le ridgeplot (graphique en crêtes) affiche la **distribution des scores de 
classement** (log2FC) pour les gènes de chaque terme enrichi, sous forme de 
courbes de densité superposées.

insérer figure

### Lecture

- Un pic de densité **à droite (log2FC > 0)** → le terme est globalement **activé**
- Un pic à **gauche (log2FC < 0)** → le terme est globalement **réprimé**
- Une distribution **bimodale** → le terme contient des gènes régulés dans les 
deux sens → interprétation complexe

### Utilité

Le ridgeplot permet de comparer en un seul coup d'œil la **direction de 
régulation** de plusieurs termes enrichis simultanément. C'est idéal pour des 
figures de synthèse.

---

## 10. Tableau de résultats — Colonnes clés

Chaque analyse (ORA ou GSEA) produit un tableau de résultats accessible 
dans VIPE-R. Voici comment lire les colonnes essentielles.

### Tableau ORA

| Colonne       | Signification                                   | Comment l'utiliser                     |
| ------------- | ----------------------------------------------- | -------------------------------------- |
| `ID`          | Identifiant du terme (ex. GO:0006915, mmu04979) | Recherche dans AmiGO, QuickGO          |
| `Description` | Nom lisible du terme                            | Lecture directe                        |
| `GeneRatio`   | k/n — fraction des DEG dans le terme            | Plus élevé = plus spécifique           |
| `BgRatio`     | K/N — fraction de l'univers dans le terme       | Indique la taille du terme             |
| `pvalue`      | p-value brute (test hypergéométrique)           | Non corrigée                           |
| `p.adjust`    | p-value corrigée (BH par défaut)                | **Critère principal de sélection**     |
| `qvalue`      | FDR estimé par q-value                          | Critère alternatif                     |
| `geneID`      | Liste des IDs Entrez des DEG dans le terme      | Permet d'identifier les gènes porteurs |
| `Count`       | Nombre de DEG dans le terme                     | Taille absolue de l'overlap            |

### Tableau GSEA

| Colonne              | Signification                          | Comment l'utiliser                        |
| -------------------- | -------------------------------------- | ----------------------------------------- |
| `ID` / `Description` | Identifiant et nom du terme            | —                                         |
| `setSize`            | Taille du gene set (après filtrage)    | Termes < 15 ou > 500 gènes souvent exclus |
| `enrichmentScore`    | ES brut                                | Signe indique la direction                |
| `NES`                | ES normalisé                           | Critère principal de sélection            |
| `pvalue`             | p-value empirique (permutations)       | —                                         |
| `p.adjust`           | p-value corrigée                       | < 0.05 recommandé                         |
| `qvalue`             | FDR (Storey)                           | < 0.25 parfois accepté                    |
| `rank`               | Rang dans la liste où l'ES est maximal | Position du Leading Edge                  |
| `leading_edge`       | Tags/List/Signal du Leading Edge       | Qualité de l'enrichissement               |
| `core_enrichment`    | Gènes du Leading Edge subset           | Gènes biologiquement les plus pertinents  |

---

## 11. Conseil rédaction

### Présentation des résultats

- [ ] Mentionner la méthode (ORA ou GSEA), l'outil (clusterProfiler) et sa 
version, l'organisme et la base d'annotation (GO BP/MF/CC, KEGG, Reactome)
- [ ] Indiquer la méthode de correction et le seuil retenu
- [ ] Préciser l'univers de référence utilisé
- [ ] Indiquer les seuils Log2FC et padj utilisés pour les DEG (pour l'ORA)
- [ ] Indiquer le critère de classement (pour la GSEA)
