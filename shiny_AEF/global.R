#' *------------------------------------------------------*
#' Authors: 
#' Mail: 
#' Date: 
#' Affiliation: University of Rouen Normandie
#' Code: 
#' *------------------------------------------------------*
#' TODO :


list_of_dependencies = c("shiny", "shinydashboard", "shinyBS", "shinyWidgets", 
                         "shinydashboardPlus", "fresh", "plotly", "DT", "waiter",
                         "data.table","clusterProfiler", "org.Mm.eg.db", "DOSE")

for (package in list_of_dependencies){
  if (!require(package, character.only = T)){
    install.packages(package)
    library(package, character.only = T)
  }
}