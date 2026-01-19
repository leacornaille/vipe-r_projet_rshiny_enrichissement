path_ora_ui <- function(id) {
  ns <- NS(id)
  
  tabItem(
    tabName = "ora_path",
    
    h2("Enrichissement (Pathway)"),
    h3("Méthode ORA"),
    
    fluidRow(
      box(
        title = "Paramètres ORA",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        fluidRow(
          
          # données DEG
          box(
            title = "Données DEG à analyser",
            width = 4,
            status = "info",
            
            radioButtons(
              ns("gene_type"),
              "Type de gènes",
              choices = c(
                "Sur-exprimés" = "up",
                "Sous-exprimés" = "down",
                "Sur + Sous exprimés" = "both"
              ),
              selected = "both"
            ),
            
            numericInput(
              ns("pval_deg"),
              "Seuil p-value ajustée (DEG)",
              value = 0.05,
              min = 0,
              max = 1,
              step = 0.01
            )
          ),
          
          # paramètres statistiques ORA
          box(
            title = "Paramètres statistiques ORA",
            width = 8,
            status = "primary",
            fluidRow(
              column(
                width = 6,
                selectInput(
                  ns("pathway_db"),
                  "Base de données Pathway",
                  choices = c(
                    "KEGG" = "kegg",
                    "Reactome" = "reactome"
                  ),
                  selected = "kegg"
                ),
                
                numericInput(
                  ns("pval_ora"),
                  "Seuil p-value ORA",
                  value = 0.05,
                  min = 0,
                  max = 0.1,
                  step = 0.01
                )
              ),
              
              column(
                width = 6,
                selectInput(
                  ns("p_adjust_method"),
                  "Méthode de correction multiple",
                  choices = c(
                    "Benjamini–Hochberg (FDR)" = "BH",
                    "Bonferroni" = "bonferroni",
                    "Holm" = "holm",
                    "Benjamini–Yekutieli" = "BY",
                    "Aucune" = "none"
                  ),
                  selected = "BH"
                )
              )
            )
          ),
          
          actionButton(
            ns("run_ora_path"),
            "Lancer ORA",
            icon = icon("play")
          )
        )
      )
    ),
    
    fluidRow(
      box(
        title = "Visualisation ORA",
        width = 6,
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        selectInput(
          ns("select_graph"),
          "Type de graphique",
          choices = c(
            "Dotplot" = "dotplot_ora_path",
            "Barplot" = "barplot",
            "Mapping pathway" = "emapplot"
          )
        ),
        
        plotOutput(ns("dotplot_ora_path"), height = 400)
      ),
      
      box(
        title = "Tableau résultats ORA",
        width = 6,
        status = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        DT::dataTableOutput(ns("table_results"))
      )
    )
  )
}