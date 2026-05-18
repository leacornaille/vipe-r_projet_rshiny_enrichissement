# Guide d'utilisation — VIPE-R

---

## 1. Présentation générale

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

## 2. Prérequis et format des données

### Format attendu

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

> **Les noms de colonnes doivent être exactement identiques** à ceux indiqués ci-dessus. L'absence de l'une de ces colonnes provoquera une erreur lors du chargement.

---

## 3. Importer ses données

1. Dans la **barre latérale gauche**, repérez le bouton **« Choisissez un fichier csv »**.
2. Cliquez sur ce bouton et sélectionnez votre fichier (`.csv`, `.tsv` ou `.txt`).
3. Sélectionnez ensuite l'**organisme** correspondant à votre expérience dans le menu déroulant :
   - `homo sapiens` → base de données `org.Hs.eg.db`
   - `mus musculus` → base de données `org.Mm.eg.db`
     
     
4. Une fois le fichier chargé, tous les onglets de l'application peuvent être utiliser.

> Le chargement du fichier **ne déclenche pas automatiquement** les analyses d'enrichissement. Vous devrez vous rendre dans l'onglet souhaité et cliquer sur le bouton **« Lancer »**.

---

## 4. Onglet — Visualisation des données DEG

### Accès

Cliquez sur **« Visualisation des données »** dans le menu latéral.

### Volcano plot

Le volcano plot s'affiche automatiquement dès le chargement du fichier. Il représente :

- **Axe X** : Log2 Fold Change (Log2FC)
- **Axe Y** : −log₁₀(p-value ajustée)
- **Points colorés** : gènes significativement différentiellement exprimés selon les seuils définis

Utilisez les **sliders** dans la boîte *Valeur seuil* pour ajuster :

- Le seuil de **Log2FC** (défaut : ±1)
- Le seuil de **p-value ajustée** (défaut : 0.05)

Le bouton **« Réinitialiser »** remet les seuils à leurs valeurs par défaut.

### Sélection interactive de gènes

Le volcano plot est **interactif** : vous pouvez sélectionner des gènes 
directement en dessinant un rectangle sur le graphique (box select) ou en 
cliquant sur des points individuels. Les gènes sélectionnés apparaissent dans 
l'onglet **« Données sélectionnées »** du tableau en bas de page.

### Tableaux disponibles

La boîte *Tableaux* contient trois sous-onglets :

| Onglet                             | Contenu                                                 |
| ---------------------------------- | ------------------------------------------------------- |
| **Données DEG brutes**             | Ensemble du tableau importé                             |
| **Données DEG filtrées (Up/Down)** | Gènes filtrés selon les seuils et le sens de régulation |
| **Données sélectionnées**          | Gènes sélectionnés manuellement sur le volcano plot     |

Pour les données filtrées, utilisez les **cases à cocher** *Up* / *Down* pour 
afficher les gènes sur-exprimés, sous-exprimés, ou les deux.

---

## 5. Onglet — Enrichissement GO term (ORA)

### Accès

Menu latéral → **Enrichissement (GO term)** → **ORA**

### Paramètres à configurer

**1. Données DEG à analyser**  
Choisissez quels gènes envoyer à l'ORA :

- `Sur-exprimés` : uniquement les gènes avec Log2FC > seuil
- `Sous-exprimés` : uniquement les gènes avec Log2FC < −seuil
- `Sur + Sous-exprimés` (défaut) : l'ensemble des DEG significatifs

**2. Ontologie GO**  
Sélectionnez l'une des trois branches :

- `BP` (Biological Process) — recommandé pour une première analyse
- `MF` (Molecular Function)
- `CC` (Cellular Component)

**3. Univers de référence**  

- `Génome de référence` : utilise l'ensemble des gènes annotés de l'organisme. 
Pratique courante, facilite la comparaison entre études
- `Gènes de l'analyse RNA-seq` : restreint l'univers aux gènes effectivement 
détectés dans votre expérience

> Voir le document *Bases théoriques* pour le détail du débat méthodologique. **Quel que soit votre choix, mentionnez-le dans vos méthodes.**

**4. Correction pour tests multiples**  
Méthode par défaut : **Benjamini-Hochberg (FDR)** — adaptée à la plupart des analyses transcriptomiques.

**5. Seuil p-value ORA**  
Valeur par défaut : **0.05**

### Lancer l'analyse

Cliquez sur **« Lancer ORA »**. Un indicateur de chargement s'affiche pendant le calcul.

### Visualisations disponibles

| Type       | Description                                                                              |
| ---------- | ---------------------------------------------------------------------------------------- |
| `dotplot`  | Points représentant le ratio de gènes et la significativité — vue d'ensemble recommandée |
| `barplot`  | Barres ordonnées par count de gènes — lecture rapide du top                              |
| `cnetplot` | Réseau gènes ↔ GO terms — montre les gènes communs entre termes                          |
| `treeplot` | Regroupement hiérarchique des termes enrichis                                            |
| `netplot`  | Réseau d'interactions entre termes                                                       |
| `goplot`   | Vue hiérarchique de l'ontologie GO                                                       |

Ajustez le **nombre de GO terms affichés** (5 à 50) et 
la **palette de couleurs** dans la boîte *Paramètre visuel*.

---

## 6. Onglet — Enrichissement GO term (GSEA)

### Accès

Menu latéral → **Enrichissement (GO term)** → **GSEA**

### Paramètres spécifiques à la GSEA

**Critère de classement**  
La GSEA requiert une liste de gènes **classée** par un score continu :

- `log2FC` (recommandé) : les gènes sont classés du plus sur-exprimé au plus sous-exprimé
- `padj` : classement par significativité statistique

> Le choix du critère de classement influence fortement les résultats. `log2FC` est le standard dans la majorité des publications.

Les autres paramètres (ontologie, univers, correction, seuil) sont identiques à ceux de l'ORA GO term.

### Lancer l'analyse

Cliquez sur **« Run »**.

### Visualisations disponibles

| Type        | Description                                                                      |
| ----------- | -------------------------------------------------------------------------------- |
| `gseaplot`  | Courbe d'enrichissement classique — indispensable pour interpréter un terme GSEA |
| `dotplot`   | Vue comparative des NES et significativité                                       |
| `emapplot`  | Carte d'enrichissement — réseau de similarité entre termes                       |
| `ridgeplot` | Distribution des scores par terme — visualise la direction d'enrichissement      |

---

## 7. Onglet — Enrichissement Pathway (ORA)

### Accès

Menu latéral → **Enrichissement (Pathway)** → **ORA**

### Spécificités

**Base de données Pathway**  

- `KEGG` : voies KEGG — annotations métaboliques et de signalisation bien établies
- `Reactome` : voies Reactome — annotations plus détaillées, notamment pour 
les processus cellulaires humains

Le reste du workflow est identique à l'ORA GO term (sélection des gènes, 
univers, correction, seuil, visualisations).

### Visualisations disponibles

| Type       | Description                           |
| ---------- | ------------------------------------- |
| `Dotplot`  | Vue d'ensemble des pathways enrichis  |
| `Barplot`  | Classement par nombre de gènes        |
| `Cnetplot` | Réseau gènes ↔ pathways               |
| `Emaplot`  | Carte d'enrichissement par similarité |
| `pathview` | Carte du réseau métabolique choisi    |  

---

## 8. Onglets — Enrichissement Pathway (GSEA)

### Accès

Menu latéral → **Enrichissement (Pathway)** → **GSEA**

### Spécificités

**Base de données Pathway**  

- `KEGG` : voies KEGG — annotations métaboliques et de signalisation bien établies
- `Reactome` : voies Reactome — annotations plus détaillées, notamment pour 
les processus cellulaires humains

Le reste du workflow est identique à la GSEA Go term (tri de la liste de gène 
par Padjust ou Log2FC, permutations, correction, seuil, visualisations).

### Visualisations disponibles

| Type       | Description                                         |
| ---------- | --------------------------------------------------- |
| `gseaplot` | Courbe d'enrichissement de la voie sélectionnée     |
| `Dotplot`  | Vue d'ensemble des pathways enrichis                |
| `Barplot`  | Classement par nombre de gènes                      |
| `Cnetplot` | Réseau gènes ↔ pathways                             |
| `Emaplot`  | Carte d'enrichissement par similarité               |
| `pathview` | Carte du réseau métabolique choisi                  |
---

## 9. Paramètres communs et bonnes pratiques

### Choix de l'univers

Le choix de l'univers de référence est l'un des paramètres les plus impactants 
en ORA, et il n'existe pas de consensus absolu. Le **génome complet** est plus 
répandu dans la littérature et facilite la comparaison entre études. Les 
**gènes détectés** sont statistiquement plus rigoureux pour du RNA-seq, car 
un gène non exprimé ne pouvait pas être différentiellement exprimé. La bonne 
pratique est avant tout de **justifier son choix et de le mentionner dans les méthodes**. 
En cas de doute, lancez l'analyse avec les deux options et comparez : des résultats 
très divergents signalent une instabilité à investiguer.

### Correction pour tests multiples

| Méthode        | Usage recommandé                                                     |
| -------------- | -------------------------------------------------------------------- |
| **BH (FDR)**   | Standard — bon équilibre sensibilité/spécificité                     |
| **Bonferroni** | Très conservateur — évite les faux positifs au prix de faux négatifs |
| **Holm**       | Alternative conservatrice moins stricte que Bonferroni               |
| **BY**         | Conserve le FDR même avec des tests corrélés                         |
| **Aucune**     | À éviter en pratique — uniquement pour exploration                   |

### Nombre de termes affichés

Choisissez à l'aide du slider le nombre de termes à afficher sur les graphes

---

## 10. Télécharger les résultats

| Élément                     | Comment télécharger                                                                 |
| --------------------------- | ----------------------------------------------------------------------------------- |
| Volcano plot                | Bouton de téléchargement dans la boîte *Volcano plot*                               |
| Table DEG filtrée           | Bouton **« Télécharger »** sous le tableau filtré                                   |
| Table gènes sélectionnés    | Bouton **« Télécharger »** sous le tableau de sélection                             |
| Graphiques d'enrichissement | Clic droit sur le graphique → *Enregistrer l'image* (ou bouton dédié si disponible) |
