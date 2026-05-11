#' -----------------------------------------------------------------------------
# auteur: Léa Cornaille, Christine Lin, Julien Chevreau, Miquel Moli Gonzalez
# mail: lea.cornaille@hotmail.com
# Affiliation: Université de Rouen
# Date: 10-2025
#
#' ------------------------------------------------------------------------------
#' TODO :

list_of_dependencies = c("shiny", "shinydashboard", "shinyBS", "shinyWidgets", 
                         "shinydashboardPlus", "fresh", "plotly", "DT", "waiter",
                         "data.table","BiocManager", "shinycssloaders","shinyjqui", 
                         "markdown", "ggbeeswarm", "ggplot2", "dplyr", "stringr", "ggrepel", "ggtext",
                         "ggraph", "igraph", "GO.db", "ggarchery", "shinybusy")
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



