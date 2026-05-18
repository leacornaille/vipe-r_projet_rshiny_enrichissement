# Analyses d'enrichissement fonctionnel

## 1.  L'enrichissement fonctionnel

Une analyse RNA-seq typique produit des centaines à des milliers de gènes 
différentiellement exprimés (DEG). Interpréter cette liste gène par gène est 
fastidieux et ne permet pas d'identifier les **processus biologiques** 
sous-jacents à la condition étudiée.

L'**enrichissement fonctionnel** répond à la question :

> *Parmi mes gènes d'intérêt, certaines fonctions biologiques ou voies métaboliques sont-elles représentées de manière significativement plus importante que ce que l'on attendrait par hasard ?*

Ces méthodes permettent :

- d'**identifier les mécanismes biologiques** impliqués dans une réponse cellulaire
- de **comparer des conditions** expérimentales à un niveau fonctionnel
- de **contextualiser** les résultats dans la littérature existante

---

## 2. Les bases de données

### 2.1 La Gene Ontology (GO)

### Structure

La Gene Ontology est un vocabulaire contrôlé et hiérarchique qui décrit les 
fonctions des gènes selon trois branches indépendantes :

| Branche            | Abréviation | Description                                                                      |
| ------------------ | ----------- | -------------------------------------------------------------------------------- |
| Biological Process | **BP**      | Processus biologiques auxquels le gène contribue (ex. *apoptosis*, *cell cycle*) |
| Molecular Function | **MF**      | Activité moléculaire du produit génique (ex. *kinase activity*, *DNA binding*)   |
| Cellular Component | **CC**      | Localisation subcellulaire (ex. *nucleus*, *mitochondrion*)                      |

Chaque branche forme un **graphe acyclique dirigé (DAG)** : un terme plus spécifique 
hérite des annotations de ses termes parents. Ainsi, un gène annoté
*"regulation of apoptotic process"* est aussi implicitement annoté *"apoptotic process"* et *"biological_process"*.

### Recommandations d'utilisation dans VIPE-R

- **BP** est la branche la plus couramment analysée — elle relie directement les
gènes à des phénomènes cellulaires interprétables.
- **MF** est utile pour comprendre les activités enzymatiques ou de liaison affectées.
- **CC** aide à identifier des réorganisations de compartiments cellulaires.

---

### 2.2 Les bases de données Pathway

### KEGG (Kyoto Encyclopedia of Genes and Genomes)

KEGG recense des **voies métaboliques et de signalisation** sous forme de 
graphes biologiques. Chaque voie KEGG est une carte visuelle reliant enzymes, 
métabolites et réactions. Les voies KEGG couvrent le métabolisme, la 
transduction du signal, le cycle cellulaire, les maladies, etc.

**Avantages** : couverture étendue, très bien référencée dans la littérature, 
disponible pour de nombreux organismes.  
**Limites** : mise à jour manuelle, certaines voies sont génériques et peu spécifiques.

### Reactome

Reactome est une base de données **open source** focalisée sur les réactions 
biochimiques et les voies biologiques humaines (avec inférence pour d'autres 
organismes). Les voies Reactome sont organisées hiérarchiquement, des grands 
processus jusqu'aux réactions élémentaires.

**Avantages** : très granulaire, curation experte, idéal pour *Homo sapiens*.  
**Limites** : moins exhaustif que KEGG pour les organismes non-humains.

---

## 3. ORA — Over-Representation Analysis

### Principe

L'ORA est la méthode d'enrichissement la plus ancienne et la plus répandue. 
Elle teste si un terme fonctionnel (GO term ou pathway) contient 
**plus de gènes d'intérêt que prévu par hasard** dans une liste de DEG.

### Entrée

L'ORA nécessite deux listes :

1. **Liste de gènes d'intérêt** : les DEG sélectionnés après application 
des seuils (Log2FC, p-value ajustée)
2. **Univers de référence** : l'ensemble des gènes pouvant potentiellement 
être différentiellement exprimés

### Test statistique

L'ORA repose sur le **test exact de Fisher** (ou le test hypergéométrique, 
mathématiquement équivalent). Pour chaque terme fonctionnel, on construit une 
table de contingence 2×2 :

|             | Dans le terme | Hors du terme |
| ----------- |:-------------:|:-------------:|
| **DEG**     | k             | n − k         |
| **Non-DEG** | K − k         | N − n − K + k |

Avec :

- **N** = taille de l'univers total
- **n** = nombre de DEG
- **K** = nombre de gènes annotés dans le terme
- **k** = nombre de DEG annotés dans le terme (= overlap)

La p-value est calculée selon la loi hypergéométrique :

$$P(X \geq k) = \sum_{i=k}^{\min(n,K)} \frac{\binom{K}{i}\binom{N-K}{n-i}}{\binom{N}{n}}$$

### Métriques de sortie

| Métrique      | Signification                                 |
| ------------- | --------------------------------------------- |
| **p-value**   | Probabilité d'observer cet overlap par hasard |
| **p.adjust**  | p-value corrigée pour les tests multiples     |
| **GeneRatio** | k/n — fraction des DEG dans le terme          |
| **BgRatio**   | K/N — fraction de l'univers dans le terme     |
| **Count**     | Nombre de DEG dans le terme (= k)             |

### Limites de l'ORA

- **Sensibilité au seuil** : les résultats dépendent fortement des seuils de 
Log2FC et p-value choisis
- **Biais vers les grands termes** : les termes avec beaucoup de gènes annotés 
ont mécaniquement plus de chances d'être enrichis
- **Indépendance supposée** : le test hypergéométrique suppose que les gènes 
sont tirés indépendamment, ce qui n'est pas biologiquement réaliste

---

## 4. GSEA — Gene Set Enrichment Analysis

### Principe

Introduite par Subramanian et al. (2005), la GSEA dépasse les limitations de 
l'ORA en travaillant sur **la totalité des gènes mesurés**, sans seuil de 
significativité. Elle teste si les membres d'un ensemble fonctionnel (gene set) 
tendent à se retrouver en **tête ou en queue** d'une liste de gènes classée 
par un score continu.

### Entrée

La GSEA nécessite :

1. **Une liste classée de tous les gènes mesurés** : classés par Log2FC (du plus 
sur-exprimé au plus sous-exprimé) ou par un score de pertinence 
(ex. −log₁₀(padj) × signe(log2FC))
2. **Des gene sets** : ensembles de gènes correspondant à des termes GO ou des pathways

### Algorithme

**Étape 1 — Calcul du score d'enrichissement (ES)**  
La GSEA "marche" le long de la liste classée de haut en bas. À chaque gène :

- Si le gène appartient au gene set → le score monte (d'une valeur proportionnelle à son rang)
- Si le gène n'appartient pas au gene set → le score descend légèrement

L'**ES (Enrichment Score)** est la déviation maximale par rapport à zéro 
observée pendant cette marche.

**Étape 2 — Normalisation (NES)**  
L'ES est normalisé par la taille du gene set pour obtenir le **NES (Normalized Enrichment Score)**, 
qui permet la comparaison entre termes de tailles différentes.

$$NES = \frac{ES_{observé}}{ES_{moyen \ des \ permutations}}$$

**Étape 3 — Calcul de la p-value par permutation**  
La significativité est estimée empiriquement : la liste de gènes est **permutée aléatoirement** 
(1 000 à 10 000 fois), et l'ES est recalculé à chaque permutation. La p-value correspond à la 
fraction de permutations donnant un ES ≥ ES observé.

### Interprétation du NES

| Valeur NES                    | Interprétation                                                       |
| ----------------------------- | -------------------------------------------------------------------- |
| NES > 0 (et p.adjust < seuil) | Le gene set est enrichi en **tête** de liste → activé/sur-exprimé    |
| NES < 0 (et p.adjust < seuil) | Le gene set est enrichi en **queue** de liste → réprimé/sous-exprimé |
| NES ≈ 0                       | Aucun enrichissement directionnel                                    |

### Avantages par rapport à l'ORA

- **Aucun seuil arbitraire** : tous les gènes contribuent, les gènes modérément 
régulés sont pris en compte
- **Détection de signaux subtils** : un terme avec de nombreux gènes faiblement 
mais cohéremment régulés sera détecté
- **Sens de la régulation** : le NES indique si le terme est activé ou réprimé
- **Moins sensible à la taille des gene sets**

### Limites de la GSEA

- **Plus lente** à calculer (permutations)
- **Sensible au critère de classement** : le choix entre Log2FC, padj ou un 
score composite influence les résultats
- **Interprétation plus complexe** : la courbe d'enrichissement et les core 
genes nécessitent une lecture attentive

---

## 5. ORA vs GSEA — Comparaison et choix

| Critère                                  | ORA                              | GSEA                   |
| ---------------------------------------- | -------------------------------- | ---------------------- |
| Entrée                                   | Liste de DEG                     | Liste complète classée |
| Seuil requis                             | Oui (Log2FC, padj)               | Non                    |
| Utilise la magnitude                     | Non                              | Oui                    |
| Sens de régulation                       | Non (sauf si séparation Up/Down) | Oui (via NES)          |
| Vitesse                                  | Rapide                           | Plus lente             |
| Gènes non-significatifs                  | Ignorés                          | Pris en compte         |
| Sensibilité aux gènes faiblement régulés | Faible                           | Élevée                 |
| Facilité d'interprétation                | Simple                           | Modérée                |

### Quand utiliser l'ORA ?

- Grand nombre de DEG bien définis (> 200 gènes)
- Analyse rapide et directe
- Comparaison binaire claire (traité vs contrôle)
- Première exploration des données

### Quand utiliser la GSEA ?

- Le nombre de DEG est faible ou les seuils sont difficiles à définir
- Capture des régulations subtiles et cohérentes
- Pour connaître la direction de régulation des voies
- Analyse plus puissante et moins dépendante des seuils

---

## 6. Correction pour tests multiples

Lorsque l'on teste simultanément des centaines ou milliers de termes GO, le 
risque de faux positifs (erreurs de type I) augmente. Si le seuil de 
significativité est α = 0.05, on s'attend à 5 % de termes faussement significatifs par hasard.

### Méthodes disponibles dans VIPE-R

**Benjamini-Hochberg (BH / FDR)** *(recommandé)*  
Contrôle le **False Discovery Rate** (FDR) — la proportion attendue de faux 
positifs parmi les résultats significatifs. Offre le meilleur équilibre sensibilité/spécificité.

$$p_{adj}^{(i)} = \frac{p_{(i)} \times m}{i}$$

Où m est le nombre total de tests et i le rang de la p-value.

**Bonferroni**  
Contrôle le **Family-Wise Error Rate** (FWER) — la probabilité de commettre 
*au moins* un faux positif. Très conservateur : `p_adj = p × m`. À réserver aux 
contextes où tout faux positif est inacceptable.

**Holm**  
Version séquentielle de Bonferroni, légèrement moins conservative tout en contrôlant le FWER.

**Benjamini-Yekutieli (BY)**  
Extension du BH valable même lorsque les tests ne sont pas indépendants (ce qui
est souvent le cas avec des gènes corrélés). Plus conservateur que BH.

### Seuil de significativité recommandé

Le seuil standard est **p.adjust < 0.05**. Dans certains contextes exploratoires,
un seuil de 0.10 peut être toléré, à condition de le mentionner explicitement.

---

## 7. Univers de référence

L'**univers** (ou background) est l'ensemble de tous les gènes qui *auraient pu*
être différentiellement exprimés dans votre expérience. Ce choix affecte directement 
le calcul du test hypergéométrique et fait l'objet d'un **débat méthodologique actif** 
dans la communauté bioinformatique — il n'existe pas de consensus absolu.

### Génome de référence complet

Utilise l'ensemble des gènes annotés de l'organisme (ex. ~20 000 pour *H. sapiens*), 
qu'ils soient détectés ou non dans votre expérience.

**Arguments pour** : pratique courante dans la littérature, facilite la 
reproductibilité et la comparaison entre études, comportement par défaut de nombreux outils.  
**Arguments contre** : biologiquement discutable — un gène non exprimé dans 
votre tissu *ne pouvait pas* être détecté comme différentiellement exprimé. 
L'inclure dans l'univers gonfle artificiellement le dénominateur N, ce qui peut 
produire des p-values artificiellement basses et biaise les résultats selon le 
profil d'expression du tissu étudié.

### Gènes détectés dans l'analyse RNA-seq

Restreint l'univers aux gènes effectivement exprimés (avec un count > seuil) 
dans votre expérience.

**Arguments pour** : statistiquement plus rigoureux pour du RNA-seq — la 
question posée devient *"parmi les gènes qui pouvaient être DE dans ce tissu, mes DEG sont-ils enrichis ?"*. 
Recommandé par plusieurs méthodologistes (Wijesooriya et al., 2022 ; Timmons et al., 2015) et mentionné 
comme option valide par les auteurs de clusterProfiler.  
**Arguments contre** : moins standard dans la littérature publiée, résultats moins 
directement comparables entre expériences sur des tissus différents.

---

## Références

- Ashburner et al. (2000). *Gene ontology: tool for the unification of biology*. Nature Genetics.
- Subramanian et al. (2005). *Gene set enrichment analysis: A knowledge-based approach for interpreting genome-wide expression profiles*. PNAS.
- Yu G. et al. (2012). *clusterProfiler: an R Package for Comparing Biological Themes Among Gene Clusters*. OMICS.
- Kanehisa & Goto (2000). *KEGG: Kyoto Encyclopedia of Genes and Genomes*. Nucleic Acids Research.
- Fabregat et al. (2018). *The Reactome Pathway Knowledgebase*. Nucleic Acids Research.
- Benjamini & Hochberg (1995). *Controlling the False Discovery Rate: A Practical and Powerful Approach to Multiple Testing*. Journal of the Royal Statistical Society.
- Wijesooriya et al. (2022). *Urgent need for consistent standards in functional enrichment analysis*. PLOS Computational Biology.
- Timmons et al. (2015). *Multiple sources of bias confound functional enrichment analysis of global -omics data*. Genome Biology.
