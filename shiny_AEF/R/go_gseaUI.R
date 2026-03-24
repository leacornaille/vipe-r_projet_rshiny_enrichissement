#---------------------------------- GO GSEA UI ----------------------------------#

# Fonction ui pour l'onglet GO term de GSEA 
go_gsea_ui <- function(id) {
  # Creation d'un namespace pour le module
  ns <- NS(id)
  
  # Interface utilisateur
  tagList(
    h2("Enrichissement (GO term)"),
    h3("Méthode GSEA"),
    
    #------------------ Paramètres de la GSEA GO term -------------------
    fluidRow(
      box(title = "Paramètres GSEA", solidHeader = TRUE, width = 12,
          selectInput(ns("reg_type_gsea"), "Type de régulation :",
                      choices = c("Overexpressed" = "overexpress",
                                  "Underexpress"  = "underexpress",
                                  "Both"          = "both")),
          selectInput(ns("ont"), "Ontologie :",
                      choices = c("BP"="BP","CC"="CC","MF"="MF")),
          actionButton(ns("runGSEA"), "Run", icon = icon("play"), class="btn-success")
      )
    ),
    
    #------------------ Plots GSEA GO term -------------------
    fluidRow(
      box(title = "Visualisation GSEA - plot1", width = 12, height = 900,
          selectInput(ns("select_graph_gsea_go1"), "Type de graphique :",
                      choices = c("gseaplot", "dotplot", "emapplot", "ridgeplot")),
          withSpinner(plotOutput(ns("gsea_go_plot1")), image = "loading.GIF")
      ),
      box(title = "Visualisation GSEA - plot2", width = 12, height = 900,
          selectInput(ns("select_graph_gsea_go2"), "Type de graphique :",
                      choices = c("gseaplot", "dotplot", "emapplot", "ridgeplot")),
          withSpinner(plotOutput(ns("gsea_go_plot2")), image = "loading.GIF")
      )
    )
  )
}
