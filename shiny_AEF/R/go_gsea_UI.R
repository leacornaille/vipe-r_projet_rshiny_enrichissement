#---------------------------------- GO GSEA UI ----------------------------------#

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
           
          # paramètres statistiques ORA 
          box(
            title = "Paramètres statistiques ORA",
            width = 8,
            status = "primary",
            
            fluidRow(
              column(
                width = 6,
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
                
                # selectInput(
                #   ns("univers_gsea_go"),
                #   "Choix de l'univers",
                #   choices = c(
                #     "Génome de référence (recommandé)" = "gen_ref",
                #     "Gène de l'analyse RNA-seq" = "gene_list"
                #   )
                # )
              ),
                
              column(
                width = 6,
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
          width = 12, 
          height = 900,
          status = "primary",
          solidHeader = TRUE,
          selectInput(ns("select_graph_gsea_go1"), "Type de graphique :",
                      choices = c("gseaplot", "dotplot", "emapplot", "ridgeplot")),
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
          max = 50,
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
          # selectInput(ns("select_graph_gsea_go2"), "Type de graphique :",
          #             choices = c("gseaplot", "dotplot", "emapplot", "ridgeplot")),
          withSpinner(
            dataTableOutput(ns("go_gsea_table_results")),
            image = "loading.GIF"
          )
      )
    )
  )
}
