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
# Affiliation: Université de Rouen
# Date: 10-2025

# Description: Ce script permet de créer une interface en Rshiny. 
# Il contient pour l'instant uniquement la mise en forme de l'application
# Il intégrera par la suite des fonctions permettant l'analyse d'enrichissement
# ce script ui.R correspond au côté utilisateur et ne fonctionne que si il y a 
# également un script serveur.R
#--------------------------------------------------------------------------

# chargement des packages
library(shiny)
library(shinydashboard)
library(fresh)
library(DT)
library(shinyWidgets)

# thème permettant de changer les couleurs de base
mytheme <- create_theme(
  adminlte_color(
    light_blue = "#2a9d8f",
    blue = "#264653",
    aqua= "#74c69d"
  )
)

### Construction du Dashboard ###

# En tête
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

# Barre de gauche
sidebar <-dashboardSidebar(
  # menuItem = création d'une case clicable au niveau de la sidebar
  sidebarMenu(
    menuItem("Accueil", tabName="home", icon=icon("home"))
  ),
  
  # interaction avec l'utilisateur qui doit rentrer un fichier
  fileInput("file", "Choisissez un fichier csv"),
  
  # permet de sélectionner une espèce
  
  
  selectInput( 
    "select", 
    "Sélectionné un organisme:", 
    list("homo sapiens" = "humain", "mus musculus" = "souris", "gallus gallus" = "poulet")),
  
  # créer les onglets dans sidebar
  sidebarMenu(
    menuItem("Visualisation des données", tabName = "inspection", icon = icon("eye")),
    menuItem("Enrichissement (GO term)", icon = icon("sitemap"), tabName = "enrichissement")
  )
)

# Corps
body <- dashboardBody(
  tags$head(
  ),
  
  # utilisation du thème personnalisé
  use_theme(mytheme),
  # tabItems : regroupe ensuite tout mes tabItem correspondant aux menuItem  
  tabItems(
    
    # Onglet Accueil
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
      
      # 
      # Tabset interactif pour faciliter la lisibilité du guide d'utilisation
      tabsetPanel(
        id = "guide_tabs",
        tabPanel("Introduction", 
                 p("Bienvenue sur VIPE-R ! Cette section explique comment utiliser l'application.")),
        tabPanel("Importation des données", 
                 p("Vous pouvez importer vos fichiers CSV via le menu à gauche.")),
        tabPanel("Visualisation", 
                 p("Ajustez les seuils de Log2FC et p-value et explorez vos graphiques interactifs.")),
        tabPanel("Téléchargement", 
                 p("Téléchargez vos résultats filtrés via le bouton 'Télécharger'.")),
        tabPanel("Enrichissement", 
                 p("Explorez les GO terms pour identifier les processus biologiques associés.")),
      )
    ),
    
    # Onglet Visualisation
    tabItem(tabName = "inspection",
            h2("Visualisation des données de DEG"),
            
            fluidRow( #  fluidRow permet de fixer ce qu'il y a dans la ligne
              # box pour le boxplot
              box(
                title = "Volcano plot", status = "primary", solidHeader = TRUE,
                width = 6,  
                plotOutput("plot", height = 250),
                collapsible = T  
              ),
              # box pour une autre figure ou autre
              box(
                title = "Autres visualisation", status = "primary", solidHeader = TRUE,
                width = 6,  
                plotOutput("plot", height = 250),
                collapsible = T  
              )
            ),
            
            fluidRow(
              # box avec les sliders
              box(
                title = "Valeur seuil", solidHeader = TRUE,
                width = 6,
                chooseSliderSkin(skin= "Flat", color ="#264653"),
                sliderInput("sliderfc", "Log2FC:", 1, 100, 50),
                sliderInput("sliderpval", "p-value:", 0, 1, 0.01),
                collapsible = T
              ),
              
              # box contenant le tableau donné en entrée
              box(
                title = "Tableau", status = "info", solidHeader = TRUE,
                width = 6,
                dataTableOutput("table"),
                collapsible = T
              )
            ),
            # bouton download 
              downloadButton("downloadData", "Télécharger")
    ),

    # Onglet Enrichissement
    tabItem(tabName = "enrichissement",
            h2("Enrichissement (GO term)")
    )
  )
)

# construire l’interface utilisateur complète du tableau de bord Shiny
ui <-  dashboardPage(header,sidebar, body,
                     tags$head(
                       tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
                     ))
