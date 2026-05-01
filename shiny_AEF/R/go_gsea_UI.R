#---------------------------------- GO GSEA UI ----------------------------------#

# Fonction ui pour l'onglet GO term de GSEA 
go_gsea_ui <- function(id) {
  # Creation d'un namespace pour le module
  ns <- NS(id)
  
  # Interface utilisateur
  tagList(
    h2("Enrichissement (GO terms)"),
    h3("Méthode ORA"),
    
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
            # selectInput(
            #   ns("rank_type_gsea"), 
            #   "Choisir le critère de classement :",
            #   choices = c("log2FC" = "log2FC", "padj"  = "padj")),
           
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
                
                selectInput(
                  ns("univers_ora_go"),
                  "Choix de l'univers",
                  choices = c(
                    "Génome de référence (recommandé)" = "gen_ref",
                    "Gène de l'analyse RNA-seq" = "gene_list"
                  )
                )
              ),
                
              column(
                width = 6,
                selectInput(
                  ns("padjust_method_go_ora"),
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
                  ns("pval_ora_go"),
                  "Seuil p-value ORA",
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
