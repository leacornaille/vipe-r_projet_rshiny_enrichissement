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
                
                selectInput(
                  ns("univers_ora_path"),
                  "Choix de l'univers",
                  choices = c(
                    "Génome de référence (recommandé)" = "gen_ref",
                    "Gène de l'analyse RNA-seq" = "gene_list"
                  )
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
                ),
                
                numericInput(
                  ns("pval_ora"),
                  "Seuil p-value ORA",
                  value = 0.05,
                  min = 0,
                  max = 0.1,
                  step = 0.01
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
    
    # ------ visualisation resultats ORA_pathway ----------------------------------------
    fluidRow(
      box(
        title = "Visualisation ORA",
        width = 8,
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        selectInput(
          ns("select_graph"),
          "Type de graphique",
          choices = c(
            "Dotplot" = "dotplot_ora_path",
            "Barplot" = "barplot_ora_path",
            "Cnetplot" = "cnetplot_ora_path",
            "Emaplot" = "emaplot_ora_path",
            "Mapping pathway" = "pathview_ora"
          )
        ),
        
        # plot avec taille modifiable par l'utilisateur
        jqui_resizable(plotOutput(ns("ora_plot_path")))
      ),
      
      # ------ paramètre visuel---------------------------------------------------
      box(
        title = "Paramètre visuel",
        width = 4,
        status = "warning",
        collapsible = T,
        
        textInput(
          ns("plot_title"),
          "Titre du graphique",
          value = "ORA – Enrichissement des pathways"
        ),
        
        # nombre de pahtway à afficher
        sliderInput(
          ns("n_terms"),
          "Nombre de pathways affichés",
          min = 1,
          max = 50,
          value = 5,
          step = 1
        ),
        
        # palette de couleur
        selectInput(
          ns("color_palette"),
          "Palette de couleurs (p.adjust)",
          choices = c(
            "Viridis" = "viridis",
            "Plasma" = "plasma",
            "Magma" = "magma",
            "Inferno" = "inferno",
            "Bleu → Rouge" = "blue_red",
            "Vert → Orange" = "green_orange"
          ),
          selected = "viridis"
        )
      ),
      
      box(
        title = "Tableau résultats ORA",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        DT::dataTableOutput(ns("table_results"))
      )
    )
  )
}