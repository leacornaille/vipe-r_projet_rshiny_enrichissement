recap_ui <- function(id) {
  ns <- NS(id)
  
  tabItem(
    tabName = "recap",
    
    h2("Visualisation globale des résultats"),
    p("Ce graphique agrège l'ensemble des analyses d'enrichissement lancées dans l'application.
       Chaque source (GO ORA, GO GSEA, Pathway ORA…) forme un bloc sur l'axe x.
       Les résultats s'accumulent à chaque Run : relancer avec d'autres paramètres ajoute
       une nouvelle entrée ou remplace l'ancienne si le nom est identique."),
    
    fluidRow(
      
      # --- Paramètres graphiques -----------------------------------------------
      box(
        title = "Paramètres graphiques",
        width = 3,
        status = "warning",
        solidHeader = FALSE,
        collapsible = TRUE,
        
        h4("Analyse à afficher"),
        helpText("Seules les analyses déjà lancées sont disponibles."),
        uiOutput(ns("source_checkboxes")),
        
        hr(),
        helpText("1.30 correspond à p.adjust = 0.05 | 2.00 correspond à p.adjust = 0.01"),
        sliderInput(
          ns("pval_threshold"),
          label   = HTML("Seuil &minus;log<sub>10</sub>(p.adjust)"),
          min = 0, max = 10, value = 1.30, step = 0.05,
          ticks = FALSE
        ),
        
        
        numericInput(
          ns("n_labels"),
          label = "Top N termes annotés",
          value = 10, min = 0, max = 50, step = 1
        ),
        
        numericInput(
          ns("nbr_points"),
          label = "Nbr de points à afficher par analyse",
          value = 10, min = 1, max = 50, step = 1
        ),
        
        radioButtons(
          ns("size_metric"),
          label = "Taille des points",
          choices = c(
            "Count / setSize" = "count",
            "GeneRatio / NES" = "generatio",
            "Uniforme" = "uniform"
          ),
          selected = "count"
        ),
        helpText("Count et GeneRatio s'appliquent aux résultats ORA. 
        NES (Normalized Enrichment Score) s'applique aux résultats GSEA. 
        Uniforme est valable dans tous les cas."),
        
        hr(),
        
        actionButton(
          ns("build_plot"),
          label = tags$span(icon("chart-bar"), " Construire le plot"),
          class = "btn-primary btn-block"
        ),
        
        br()
      ),
      
      # --- Manhattan plot --------------------------------------------------
      box(
        title = "Manhattan plot",
        width = 9,
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        withSpinner(
          plotlyOutput(ns("manhattan_plot"), height = "500px"),
          image = "this-is.gif",
          image.width  = 400,
          image.height = 300
        )
      )
    ),
    
    # --- Détail du terme cliqué ----------------------------------------------
    fluidRow(
      box(
        title  = tags$span(icon("info-circle"), " Terme sélectionné"),
        status = "info",
        solidHeader = TRUE,
        width = 12,
        collapsible = TRUE,
        collapsed = FALSE,
        uiOutput(ns("selected_term_info"))
      )
    )
  )
}