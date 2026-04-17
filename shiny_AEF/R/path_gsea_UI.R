#---------------------------------- GO GSEA UI ----------------------------------#

# Fonction ui pour l'onglet GO term de GSEA 
go_gsea_ui <- function(id) {
  # Creation d'un namespace pour le module
  ns <- NS(id)
  
  # Interface utilisateur
  tagList(
    h2("Enrichissement (Pathway)"),
    h3("Méthode GSEA"),
    
    #------------------ Paramètres de la GSEA GO term -------------------
    fluidRow(
      box(title = "Paramètres GSEA", 
          solidHeader = TRUE,
          status = "primary",
          width = 12,
          selectInput(ns("rank_type_gsea"), "Classement des gènes :",
                      choices = c("log2FC" = "log2FC",
                                  "padj"  = "padj")),
          selectInput(ns("ont"), "Ontologie :",
                      choices = c("BP"="BP","CC"="CC","MF"="MF")),
          actionButton(ns("runGSEA"), "Run", icon = icon("play"), class="btn-success")
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
