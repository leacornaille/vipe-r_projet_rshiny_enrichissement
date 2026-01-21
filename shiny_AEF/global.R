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
                         "data.table","BiocManager", "shinycssloaders")
for (package in list_of_dependencies){
  if (!require(package, character.only = T)){
    install.packages(package)
    library(package, character.only = T)
  }
}


bioconductor_dependencies = c("clusterProfiler", "org.Mm.eg.db", "DOSE", "pathview", "enrichplot","org.Hs.eg.db","ReactomePA")
for (package in bioconductor_dependencies){
  if (!require(package, character.only = T)){
    BiocManager::install(package)
    library(package, character.only = T)
  }
}

library("ggraph")
library("igraph")
library("GO.db")
library('ggarchery')
library("shinybusy")


