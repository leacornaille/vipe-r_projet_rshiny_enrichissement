#---------------------------------- GO ORA UI ----------------------------------#

# Fonction ui pour l'onglet GO term de ORA 
go_ora_ui <- function(id) {
  # Creation d'un namespace pour le module
  ns <- NS(id)
  
  # Interface utilisateur
  tagList(
    h2("Enrichissement (GO term)"),
    h3("Méthode ORA"),
    
    #------------------ Paramètres de l'ORA GO term -------------------
    fluidRow(
      box(title = "Paramètres", solidHeader = TRUE, width = 12,
          selectInput(ns("reg_type"), "Type de régulation :",
                      choices = c("Overexpressed" = "overexpress",
                                  "Underexpress"  = "underexpress",
                                  "Both"          = "both")),
          selectInput(ns("ont"), "Ontologie :",
                      choices = c("BP"="BP","CC"="CC","MF"="MF")),
          actionButton(ns("runGO"), "Run", icon = icon("play"), class="btn-success")
      )
    ),
    
    #------------------ Plots ORA GO term -------------------
    fluidRow(
      box(title = "plot1", width = 12, height = 900,
          selectInput(ns("select_graph_ora_go1"), "Type de graphique :",
                      choices = c("dotplot","barplot","cnetplot", "treeplot", "netplot", "goplot")),
          withSpinner(plotOutput(ns("ora_go_plot1")), image = "loading.GIF")
      ),
      box(title = "plot2", width = 12, height = 900,
          selectInput(ns("select_graph_ora_go2"), "Type de graphique :",
                      choices = c("dotplot","barplot","cnetplot", "treeplot", "netplot", "goplot")),
          withSpinner(plotOutput(ns("ora_go_plot2")), image = "loading.GIF")
      )
    )
  )
}
