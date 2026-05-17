# Ce module correspond à la partie "Enrichissement (Pathway) - Méthode ORA" de l'application.
# Il correspond à la partie UI 
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
            
            column(
              width = 6,
              radioButtons(
                ns("gene_type"),
                "Type de gènes",
                choices = c(
                  "Sur-exprimés" = "up",
                  "Sous-exprimés" = "down",
                  "Sur + Sous exprimés" = "both"
                ),
                selected = "both"
              )
            ),
            column(
              width = 6,
              uiOutput(ns("filter_info"))
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
                bsTooltip(ns("pathway_db"),
                          "KEGG : base généraliste, couvre métabolisme et signalisation.<br> Reactome : plus détaillée, orientée voies humaines. Les deux sont complémentaires.",
                          placement = "bottom"),
                
                selectInput(
                  ns("univers_ora_path"),
                  "Choix de l'univers",
                  choices = c(
                    "Génome de référence" = "gen_ref",
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
          
          fluidRow(
            column(12, align = "center",
                   actionButton(ns("run_ora_path"), "Lancer ORA", icon = icon("play"))
            )
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
            "Emaplot" = "emaplot_ora_path"
          )
        ),
        
        # plot avec taille modifiable par l'utilisateur
        withSpinner(jqui_resizable(plotOutput(ns("ora_plot_path")), options = list(handles = "se")),image = "loading.GIF")
      ),
      
      # ------ paramètre visuel---------------------------------------------------
      box(
        title = "Paramètres visuels",
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
          "Palette de couleurs",
          choices = c(
            "Viridis" = "viridis",
            "Plasma" = "plasma",
            "Magma" = "magma",
            "Inferno" = "inferno",
            "Mako" = "mako",
            "Rocket" = "rocket",
            "Cividis" = "cividis",
            "Turbo" = "turbo",
            "Jaune → Rouge" = "YlOrRd",
            "Bleu → Rouge" = "blue_red",
            "Vert → Orange" = "green_orange"
          ),
          selected = "viridis"
        )
      ),
      # si la base est kegg alors la box pathview s'affiche
      conditionalPanel(
        condition = paste0("input['", ns("pathway_db"), "'] == 'kegg'"),
        box(
          title = "Pathview",
          width = 4,
          status = "primary",
          collapsible = TRUE,
          
          selectInput(ns("pathview_kegg_id"), "Voie métabolique", choices = NULL),
          
          actionButton(
            ns("run_pathview"),
            "Afficher la voie dans Pathview",
            icon  = icon("play"),
            width = "100%"
          )
        )
      ),
      # tableau des résultats ORA
      box(
        title = "Tableau résultats ORA",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        downloadButton(ns("download_table_ora_path"), "Télécharger le tableau (CSV)"),
        DT::dataTableOutput(ns("table_results"))
      )
    )
  )
}