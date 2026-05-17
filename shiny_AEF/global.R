#' -----------------------------------------------------------------------------
# auteur: Léa Cornaille, Christine Lin, Julien Chevreau, Miquel Moli Gonzalez
# mail: lea.cornaille@hotmail.com
# Affiliation: Université de Rouen
# Date: 10-2025
# Ce script global.R est chargé au lancement de l'application Shiny. 
# Il est utilisé pour charger les bibliothèques nécessaires et effectuer toute initialisation requise avant que l'interface utilisateur et le serveur ne soient exécutés.
#' ------------------------------------------------------------------------------

# Paquets CRAN avec leur versions
list_of_dependencies = c("shiny", "shinydashboard", "shinyBS", "shinyWidgets", 
                         "shinydashboardPlus", "fresh", "plotly", "DT", "waiter",
                         "data.table","BiocManager", "shinycssloaders","shinyjqui", 
                         "markdown", "ggbeeswarm", "ggplot2", "dplyr", "stringr", 
                         "ggrepel", "ggtext", "ggraph", "igraph", "ggarchery",
                         "shinybusy")
dependencies_versions = c("1.12.1", "0.7.3", "0.63.0", "0.9.0", "2.0.6", "0.2.2",
                          "4.11.0", "0.34.0", "0.2.5.1", "1.18.0", "1.30.27", 
                          "1.1.0", "0.4.1", "2.0", "0.7.3", "4.0.1","1.1.4", 
                          "1.6.0", "0.9.6", "0.1.2", "2.2.2", "2.2.1", "0.4.4", 
                          "0.3.3")

# Installer et charger les packages s'ils ne le sont pas
for (i in 1:length(list_of_dependencies)){
  if (!require(list_of_dependencies[i], character.only = T)){
    install.packages(paste0(list_of_dependencies[i],"@",dependencies_versions[i]))
    library(list_of_dependencies[i], character.only = T)
  }
}

# Paquets Bioconductor avec leur versions
bioconductor_dependencies = c("clusterProfiler","GO.db", "org.Mm.eg.db", "DOSE", 
                              "pathview", "enrichplot","org.Hs.eg.db","reactome.db",
                              "ReactomePA")
bioc_dep_version = c("4.18.4", "3.22.0", "3.22.0", "4.4.0", "1.50.0", "1.30.4", "3.22.0", "1.54.0",
                     "1.95.0")
# Installer et charger les packages s'ils ne le sont pas
for (i in 1:length(bioconductor_dependencies)){
  if (!require(bioconductor_dependencies[i], character.only = T)){
    BiocManager::install(bioconductor_dependencies[i], version = bioc_dep_version[i])
    library(bioconductor_dependencies[i], character.only = T)
  }
}

list_packages = c("shiny", "shinydashboard", "shinyBS", "shinyWidgets", 
                  "shinydashboardPlus", "fresh", "plotly", "DT", "waiter",
                  "data.table","BiocManager", "shinycssloaders","shinyjqui", 
                  "markdown", "ggbeeswarm", "ggplot2", "dplyr", "stringr", "ggrepel", "ggtext",
                  "ggraph", "igraph", "ggarchery", "shinybusy","clusterProfiler","GO.db", "org.Mm.eg.db", "DOSE", 
                  "pathview", "enrichplot","org.Hs.eg.db","ReactomePA", "reactome.db" )