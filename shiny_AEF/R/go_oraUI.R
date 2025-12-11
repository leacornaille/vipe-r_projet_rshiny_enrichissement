


# Fonction ui pour l'onglet GO term de ORA 
go_ora_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2("Enrichissement (GO term)"),
    h3("Méthode ORA"),
    
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
    
    fluidRow(
      box(title = "plot1", width = 12, height = 900,
          selectInput(ns("select_graph1"), "Type de graphique :",
                      choices = c("dotplot","ridgeplot","cnetplot")),
          withSpinner(plotOutput(ns("go_plot1")))
      ),
      box(title = "plot2", width = 12, height = 600,
          selectInput(ns("select_graph2"), "Type de graphique :",
                      choices = c("dotplot","ridgeplot","cnetplot")),
          withSpinner(plotOutput(ns("go_plot2")))
      )
    )
  )
}
