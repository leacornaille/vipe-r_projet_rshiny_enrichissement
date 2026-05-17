# Ce module correspond à la partie "Enrichissement (GO term) - Méthode ORA" de l'application.
# Il correspond à la partie UI de ce module, qui permet à l'utilisateur de sélectionner les paramètres de l'analyse, de visualiser les résultats à travers différents types de graphiques, et d'explorer les termes GO spécifiques.

# Fonction ui pour l'onglet GO term de ORA 
go_ora_ui <- function(id) {
  # Creation d'un namespace pour le module
  ns <- NS(id)
  
  # Interface utilisateur
  tabItem(
    h2("Enrichissement (GO term)"),
    h3("Méthode ORA"),
    
    #------------------ Paramètres de l'ORA GO term ----------------------------
    fluidRow(
      box(
        title = "Paramètre ORA",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE, 
        
        fluidRow(
          box(
            title = "Données DEG à analyser",
            width = 4,
            status = "info",
            
            column(
              width = 6,
              radioButtons(
                ns("reg_type"), 
                "Type de gènes",
                choices = c(
                  "Sur-exprimés" = "overexpress",
                  "Sous-exprimés"  = "underexpress",
                  "Sur + Sous-exprimés" = "both"
                ),
                selected = "both"
              )
            ),
            column(
              width = 6,
              uiOutput(ns('filter_info_box'))
            )
          ),
          
          # ------ paramètre statistiques ORA ------------------------------------
          box(
            title = "Paramètres statistiques ORA",
            width = 8,
            status = "primary",
            fluidRow(
              column(
                width = 4,
                selectInput(
                  ns("ont"),
                  "Ontologie GO",
                  choices = c(
                    "Biological Process (BP)" = "BP",
                    "Molecular Function (MF)" = "MF",
                    "Cellular Component (CC)" = "CC"
                  ),
                  selected = "BP"
                ),
                selectInput(
                  ns("univers_ora_go"),
                  "Choix de l'univers",
                  choices = c(
                    "Génome de référence" = "gen_ref",
                    "Gène de l'analyse RNA-seq" = "gene_list"
                  )
                )
              ),
              column(
                width = 4,
                selectInput(
                  ns("padjust_method_go_ora"),
                  "Méthode de correction multiple",
                  choices = c(
                    "Benjamini-Hochberg (FDR)" = "BH",
                    "Bonferroni" = "bonferroni",
                    "Holm" = "holm",
                    "Benjamini-Yekutieli" = "BY",
                    "Aucune" = "none"
                  ),
                  selected = "BH"
                ),
                numericInput(
                  ns("pval_ora_go"),
                  "Seuil p-value ORA",
                  value = 0.05,
                  min = 0,
                  max = 0.1,
                  step = 0.01
                )
              ),
              column(
                width = 4,
                h5("Redondance des termes GO"),
                helpText("Les termes GO sont souvent redondants. En cochant cette option, les termes redondants seront éliminés."),
                checkboxInput(
                  ns("simplify_ora_go"),
                  "Eliminer les termes GO redondants",
                  value = TRUE
                )
              )
            )
          ),
          
          fluidRow(
            column(12, align = "center",
                   actionButton(ns("runGO"), "Lancer ORA", icon = icon("play"))
            )
          )
        )
      )
    ),
    
    fluidRow(
      box(
        title = "Visualisation ORA",
        width = 8,
        height = 600,
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        selectInput(
          ns("select_graph_ora_go1"),
          "Type de graphique",
          choices = c(
            "dotplot",
            "barplot",
            "cnetplot",
            "treeplot",
            "netplot",
            "goplot"
          )
        ),
        
        withSpinner(jqui_resizable( plotOutput(ns("ora_go_plot1")), options = list(handles = "se")),image = "loading.GIF")
      ),
      
      box(
        title = "Paramètre visuel",
        width = 4,
        status = "warning",
        collapsible = TRUE,
        
        # ------ titre du plot -------------------------------------------------
        textInput(
          ns("plot_title_ora_go"),
          "Titre du graphique",
          value = "ORA - Enrichissement des GoTerm"
        ),
        
        # ------ nombre de go termes -------------------------------------------
        sliderInput(
          ns("n_cat_go_ora"),
          "Nombre de GO terms affichés",
          min = 5, 
          max = 50,
          value = 20,
          step = 1
        ),
        
        # ------ choix des couleurs du graphe --------------------------------------
        selectInput(
          ns("color_palette_go_ora"),
          "Palette des couleurs (p.adjust)", 
          choices = c(
            "Viridis" = "viridis",
            "Plasma" = "plasma",
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
      
      # ------ tableau de résultats --------------------------------------------
      box(
        title = "Tableau résultats ORA GO term",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        downloadButton(ns("download_table_ora_go"), "Télécharger le tableau (CSV)"),
        br(), br(),
        DT::dataTableOutput(ns("ora_go_table"))
        
      )
    )
  )
}