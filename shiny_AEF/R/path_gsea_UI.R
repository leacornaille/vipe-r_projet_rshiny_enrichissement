#---------------------------------- GO GSEA UI ----------------------------------#

# Fonction ui pour l'onglet GO term de GSEA 
path_gsea_ui <- function(id) {
  # Creation d'un namespace pour le module
  ns <- NS(id)
  
  # Interface utilisateur
  tagList(
    h2("Enrichissement (Pathway)"),
    h3("Méthode GSEA"),
    
    #------------------ Paramètres de la GSEA Pathway-------------------
    fluidRow(
      box(
        title = "Paramètres GSEA", 
        solidHeader = TRUE,
        status = "primary",
        width = 12,
        
        fluidRow(
          box(
            title = "Classement des gènes",
            width = 4,
            status = "info",
            
            column(
              width = 6,
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
            width = 8,
            status = "primary",
            
            fluidRow(
              column(
                width = 6,
                selectInput(
                  ns("pathway_db"),
                  "Base de données Pathway",
                  choices = c(
                    "KEGG" = "kegg",
                    "Reactome" = "reactome"
                  ),
                  selected = "kegg"
                ),
              ),
              
              column(
                width = 6,
                selectInput(
                  ns("padjust_method_path_gsea"),
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
                  ns("pval_ora_gsea"),
                  "Seuil p-value GSEA",
                  value = 0.05,
                  min = 0,
                  max = 0.1,
                  step = 0.01
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
                "Run", 
                icon = icon("play"), 
                class="btn-success")
            )
          )
        )
      )
    ),
    
    #------------------ Plots GSEA Pathway -------------------
    fluidRow(
      box(title = "Visualisation GSEA", 
          width = 8, 
          height = 900,
          status = "primary",
          solidHeader = TRUE,
          selectInput(ns("select_graph_gsea_path"), "Type de graphique :",
                      choices = c("gseaplot", "dotplot", "emapplot", "ridgeplot", 
                                  "cnetplot")),
          withSpinner(plotOutput(ns("gsea_path_plot")), image = "loading.GIF")
      ),
      
      box(
        title = "Paramètres visuels",
        width = 4,
        status = "warning",
        collapsible = TRUE,
        
        textInput(
          ns("plot_title_gsea_path"),
          "Titre du graphique",
          value = "GSEA Enrichissement Pathway"
        ),
        
        sliderInput(
          ns("n_cat_path_gsea"),
          "Nombre de GO terms affichés",
          min = 5, 
          max = 50,
          value = 20,
          step = 1
        ),
        
        selectInput(
          ns("color_palette_path_gsea"),
          "Palette des couleurs (p.adjust)", 
          choices = c(
            "Viridis" = "viridis",
            "Plasma" = "plasma",
            "Magma" = "magma",
            "Inferno" = "inferno",
            "Bleu → Rouge" = "blue_red"
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
          # selectInput(ns("select_graph_gsea_go2"), "Type de graphique :",
          #             choices = c("gseaplot", "dotplot", "emapplot", "ridgeplot")),
          withSpinner(
            dataTableOutput(ns("path_gsea_table_results")),
            image = "loading.GIF"
          )
      )
    )
  )
}
