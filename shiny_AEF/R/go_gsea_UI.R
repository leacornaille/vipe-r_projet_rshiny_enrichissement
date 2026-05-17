# Ce module correspond à la partie "Enrichissement (GO terms) - Méthode GSEA" de l'application. 
# Il correspond à la partie UI de ce module, qui permet à l'utilisateur de sélectionner les paramètres de l'analyse, de visualiser les résultats à travers différents types de graphiques, et d'explorer les termes GO spécifiques.

# Fonction ui pour l'onglet GO term de GSEA 
go_gsea_ui <- function(id) {
  # Creation d'un namespace pour le module
  ns <- NS(id)
  
  # Interface utilisateur
  tagList(
    h2("Enrichissement (GO terms)"),
    h3("Méthode GSEA"),
    
    #------------------ Paramètres de la GSEA GO term -------------------
    fluidRow(
      box(
        title = "Paramètres GSEA", 
        solidHeader = TRUE,
        status = "primary",
        width = 12,
        
        fluidRow(
          box(
            title = "Classement des gènes",
            width = 3,
            status = "info",
            helpText("log2FC (recommandé) : classe les gènes par intensité de régulation. padj : classe par significativité statistique."),
            column(
              width = 12,
              radioButtons(
                ns("rank_type_gsea"), 
                "Choisir le critère de classement :",
                choices = c("log2FC" = "log2FC", "padj"  = "padj")),
              selected = "log2FC"
              )
            ),
           
          # paramètres statistiques GSEA 
          box(
            title = "Paramètres statistiques GSEA",
            width = 9,
            status = "primary",
            
            fluidRow(
              column(
                width = 4,
                selectInput(
                  ns("ont"),
                  "Ontologie GO",
                  choices = c(
                    "Biological Process (BP)" = "BP",
                    "Molecular Function (MF)" = "MF",
                    "Cellular Component (CC)" = "CC"
                  ),
                  selected = "BP"
                ),
                bsTooltip(
                  ns(id = "use_permutation_go_gsea"),
                  title = "clusterProfiler déconseille de faire des permutations. Par défaut, il estime les pvalues par convergence.",
                  placement = "right",
                  trigger = "hover"
                ),
                numericInput(
                  ns("nperm_go_gsea"),
                  "Permutations",
                  value = 1000,
                  step = 50.0
                ),
                checkboxInput(
                  ns("use_permutation_go_gsea"),
                  "Faire des permutations",
                  value = FALSE
                ),
              ),
                
              column(
                width = 4,
                selectInput(
                  ns("padjust_method_go_gsea"),
                  "Méthode de correction multiple",
                  choices = c(
                    "Benjamini-Hochberg (FDR)" = "BH",
                    "Bonferroni" = "bonferroni",
                    "Holm" = "holm",
                    "Benjamini-Yekutieli" = "BY",
                    "Aucune" = "none"
                  ),
                  selected = "BH"
                ),
                
                numericInput(
                  ns("padj_thr_gsea"),
                  "Seuil p-value GSEA",
                  value = 1,
                  min = 0,
                  max = 0.1,
                  step = 0.01
                ) 
              ),
              column(
                width = 4,
                h5("Redondance des termes GO"),
                helpText("Les termes GO sont souvent redondants. En cochant cette option, les termes redondants seront éliminés."),
                checkboxInput(
                  ns("simplify_gsea_go"),
                  "Eliminer les termes GO redondants",
                  value = TRUE
                )
              )
            )
          ),
          
          fluidRow(
            column(
              width = 12,
              align = "center",
              actionButton(
                ns("runGSEA"), 
                "Lancer GSEA", 
                icon = icon("play"), 
                class="btn-success")
            )
          )
        )
      )
    ),
    
    #------------------ Plots GSEA GO term -------------------
    fluidRow(
      box(title = "Visualisation GSEA", 
          width = 8, 
          height = 900,
          status = "primary",
          solidHeader = TRUE,
          selectInput(ns("select_graph_gsea_go1"), "Type de graphique :",
                      choices = c("gseaplot", "dotplot", "emapplot", "ridgeplot", "treeplot", "goplot")),
          withSpinner(plotOutput(ns("gsea_go_plot1")), image = "loading.GIF")
      ),
      
      box(
        title = "Paramètres visuels",
        width = 4,
        status = "warning",
        collapsible = TRUE,
        
        textInput(
          ns("plot_title_gsea_go"),
          "Titre du graphique",
          value = "GSEA Enrichissement GO"
        ),
        
        sliderInput(
          ns("n_cat_gsea"),
          "Nombre de GO terms affichés",
          min = 5, 
          max = 150,
          value = 20,
          step = 1
        ),
        
        selectInput(
          ns("color_palette_go_gsea"),
          "Palette des couleurs (p.adjust)", 
          choices = c(
            "Viridis" = "viridis",
            "Plasma" = "plasma",
            "Magma" = "magma",
            "Inferno" = "inferno",
            "Bleu -> Rouge" = "blue_red"
          ),
          selected = "viridis"
        )
      ),
      
      
      #------------------ Tableau GSEA GO term -------------------
      box(title = "Table résultats GSEA", 
          width = 12, 
          height = 900,
          status = "primary",
          solidHeader = TRUE,
          downloadButton(ns("download_table_gsea_go"), "Télécharger le tableau (CSV)"),
          withSpinner(
            dataTableOutput(ns("go_gsea_table_results")),
            image = "loading.GIF"
          )
      )
    )
  )
}
