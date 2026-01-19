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
                         "data.table","BiocManager")
for (package in list_of_dependencies){
  if (!require(package, character.only = T)){
    install.packages(package)
    library(package, character.only = T)
  }
}

bioconductor_dependencies = c("clusterProfiler", "org.Mm.eg.db", "DOSE", "pathview","ReactomePA")
for (package in bioconductor_dependencies){
  if (!require(package, character.only = T)){
    BiocManager::install(package)
    library(package, character.only = T)
  }
}

source('R/go_ora.R')
source('R/go_oraUI.R')

library('org.Hs.eg.db')
library("shinycssloaders")