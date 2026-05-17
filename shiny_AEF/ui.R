#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

#----------------------------------------------------------------
# auteur: Léa Cornaille
# mail: lea.cornaille@hotmail.com
# Affiliation: INSERM Unité ADEN
# Date: 11-2025

# Description: Ce script permet de créer une interface en Rshiny. 
# Il contient pour l'instant uniquement la mise en forme de l'application
# Il intégrera par la suite des fonctions permettant l'analyse d'enrichissement
# ce script ui.R correspond au côté utilisateur et ne fonctionne que si il y a 
# également un script serveur.R
#--------------------------------------------------------------------------

# thème permettant de changer les couleurs de base
mytheme <- create_theme(
  adminlte_color(
    light_blue = "#2a9d8f",
    blue = "#264653",
    aqua= "#74c69d",
    yellow = "#669bbc"
  )
)

### Construction du Dashboard ###

#------ En tête ----------------------------------------------------------------
header <- dashboardHeader(title = tags$div(
  tags$img(src = "logo.png", height = "40px", style = "margin-right:10px;"),
  "VIPE-R"),
  tags$li(
    class = "dropdown",
    style = "padding-top: 5px;",
    actionButton("info_btn", label = NULL, icon = icon("info-circle"), 
                 style = "color: #fff; background: transparent; border: none;font-size: 20px")
  )
)

#------ Barre de gauche --------------------------------------------------------
sidebar <-dashboardSidebar(
  # menuItem = création d'une case clicable au niveau de la sidebar
  sidebarMenu(
    menuItem("Accueil", tabName="home", icon=icon("home"))
  ),
  
  # interaction avec l'utilisateur qui doit rentrer un fichier
  fileInput("file", "Choisissez un fichier csv", multiple =FALSE, accept =c("text/csv",
    "text/tab-separated-values",
    "text/plain",
    ".csv",
    ".tsv",
    ".txt")
  ),
  bsTooltip("file", "Colonnes requises : gene, log2FoldChange, padj. Séparateur : virgule ou tabulation.", placement = "right"),
  
  # permet de sélectionner une espèce
  selectInput( 
    "select", 
    "Sélectionner un organisme:", 
    list("homo sapiens" = "humain", "mus musculus" = "souris")),
  p("⚠ choisissez l'organisme qui correspond à vos données",style = "text-align: center;"),
  
  # créer les onglets dans sidebar
  sidebarMenu(
    menuItem("Visualisation des données", tabName = "inspection", icon = icon("eye")),
    menuItem("Enrichissement (GO term)", icon = icon("sitemap"), tabName = "enrichissement", startExpanded = TRUE,
             menuSubItem("ORA", tabName = "ora_go"),
             menuSubItem("GSEA", tabName = "gsea_go")),
    menuItem("Enrichissement (Pathway)", icon = icon("chart-pie"),tabName = "pathway", startExpanded = TRUE,
             menuSubItem("ORA", tabName = "ora_path"),
             menuSubItem("GSEA", tabName = "gsea_path")),
    menuItem("Récapitulatif", icon = icon("chart-column"), tabName = "recap")
  )
)

#------ Corps --------------------------------------------------------------------
body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),
  
  # utilisation du thème personnalisé
  use_theme(mytheme),
  # tabItems : regroupe ensuite tout mes tabItem correspondant aux menuItem  
  tabItems(
    
    # ------ Onglet Accueil ------------------------------------------------------
    tabItem(
      tabName = "home",
      tags$div(
        style = "display:flex; align-items:center;",  
        tags$img(src = "logo.png", height = "60px", style = "margin-right:15px;"),
        tags$h2("VIPE-R: Visualisation Interactive des Profils d’Enrichissements - R")
      ),
      h3("Interface pour l'analyse d'enrichissement fonctionnel."),
      p("Cette interface a été créee dans le cadre de l'UE analyse en 
        sciences omiques du master de bioinformatique de L'université de Rouen Normandie"),
      
      # Tabset interactif pour faciliter la lisibilité du guide d'utilisation
      tabsetPanel(
        id = "guide_tabs",
        tabPanel(
          "Introduction",
          
          h3("Bienvenue sur VIPE-R !"),
          
          p("VIPE-R est une application interactive conçue pour faciliter l'analyse et la visualisation des données de gènes différentiellement exprimés (DEG)."),
          
          p("L'objectif de VIPE-R est de :"),
          
          tags$ul(
            tags$li("Permettre l'exploration interactive des résultats d'analyses transcriptomiques."),
            tags$li("Visualiser facilement les gènes régulés positivement ou négativement grâce à des volcano plots."),
            tags$li("Identifier rapidement les gènes d'intérêt et générer des tables filtrées selon vos critères."),
            tags$li("Télécharger les visualisations et les données pour un usage dans des publications ou des analyses complémentaires."),
            tags$li("Faciliter la comparaison entre différents groupes ou conditions expérimentales.")
          ),
          
          p("Cette application est particulièrement adaptée pour les biologistes et bioinformaticiens souhaitant :"),
          tags$ul(
            tags$li("Explorer leurs données de manière intuitive et interactive."),
            tags$li("Gagner du temps dans l'analyse et l'interprétation des résultats."),
            tags$li("Communiquer leurs résultats via des graphiques et tableaux prêts à l'emploi.")
          ),
          
          p("Prenez le temps de parcourir les différentes sections pour découvrir toutes les fonctionnalités et tirer le meilleur parti de VIPE-R !")
        ),
        
        tabPanel(
          "Guide d'utilisation",
          tags$iframe(
            src = "guide_utilisation.html",
            style = "border: none; display: block;",
            width = "70%",
            height = "800px"
          )
        ),

        tabPanel(
          "Enrichissement fonctionnel",
          tags$iframe(
            src = "theorie_ora_gsea.html",
            style = "border: none; display: block;",
            width = "70%",
            height = "800px"
          )
        ),
        tabPanel(
          "Interprétation des figures",
          tags$iframe(
            src = "analyse_figures.html",
            style = "border: none; display: block;",
            width = "70%",
            height = "800px"
          )
        ),
      )
    ),
    
    # ------ Onglet Visualisation ----------------------------------------------
    tabItem(tabName = "inspection",
            h2("Visualisation des données de DEG"),
            
            fluidRow( #  fluidRow permet de fixer ce qu'il y a dans la ligne
              # box pour le boxplot
              volcano_plot_ui("volcano_plot_module"),
              
              # Summary box pour le total de gènes filtrés
              valueBoxOutput("nb_filtered_genes_box", width = 4),
              
              # box avec les sliders
              box(
                title = "Valeur seuil", solidHeader = TRUE,
                width = 6,
                chooseSliderSkin(skin= "Flat", color ="#264653"),
                helpText("Ces seuils définissent les gènes considérés comme différentiellement exprimés et serviront d'entrée aux analyses d'enrichissement."),
                uiOutput("slider_fc"),
                uiOutput("slider_pval"),
                bsTooltip("slider_fc", "Seuil de log2FC pour filtrer les gènes", placement = "top"),
                bsTooltip("slider_pval", "Seuil de p-value ajustée", placement = "top"),
                collapsible = T,
                actionButton("reset_all", "Réinitialiser la sélection du tableau")
              )
            ),
            
            # box contenant les tableaux de DEG (initial, filtré et sélectionné manuellement)
            fluidRow(
              box(
                title = "Tableaux", status = "info", solidHeader = TRUE,
                collapsible = TRUE,
                width = 12,
                
                tabsetPanel(
                  # tableau des données DEG brutes
                  tabPanel(
                    "Données DEG brutes",
                    dataTableOutput("table")
                  ),
                  # tableau des données DEG filtré
                  tabPanel(
                    "Données DEG filtrées (Up/Down)",
                    prettyCheckboxGroup(
                      inputId = "regulation_choice",
                      label = "Choix d'affichage",
                      choices = c("Up", "Down"),
                      status = "danger",
                      shape = "curve",
                      outline = TRUE,
                      inline = TRUE
                    ),
                    DTOutput("table_filtered"),
                    downloadButton("downloadData", "Télécharger")
                  ),
                  # tableau des données DEG selectionné par l'utilisateur
                  selected_table_ui("volcano_plot_module"),
                )
              ),
            )
    ),
    
    # ------ Onglet ORA GO term -----------------------------------------------
    tabItem(
      tabName = "ora_go",
      go_ora_ui("ora_go_module")   
    ),

    # ------ Onglet GSEA GO term ----------------------------------------------
    tabItem(
      tabName = "gsea_go",
      go_gsea_ui("gsea_go_module")   
    ),
    
    # ------ Onglet ORA Pathway -----------------------------------------------
    tabItem(
      tabName = "ora_path",
      path_ora_ui("ora_path_module")   
    ),
    
    # ------ Onglet GSEA Pathway ----------------------------------------------
    tabItem(
      tabName = "gsea_path",
      path_gsea_ui("gsea_path_module")
    ),
    
    # ------ Onglet Récapitulatif ---------------------------------------------
    tabItem(
      tabName = "recap",
      recap_ui("recap_module")
    )
  )
)

# construire l’interface utilisateur complète du tableau de bord Shiny
ui <-  dashboardPage(header,sidebar, body)
