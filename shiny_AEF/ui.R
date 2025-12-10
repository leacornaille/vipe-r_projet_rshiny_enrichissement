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

# chargement des packages
library(shiny)
library(shinydashboard)
library(shinyBS)
library(fresh)
library(DT)
library(shinyWidgets)
library(shinydashboardPlus)
library(plotly)
library(waiter)
library(data.table)
library(clusterProfiler)
library(org.Mm.eg.db)
library(DOSE)


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
  fileInput("file", "Choisissez un fichier csv"),
  
  # permet de sélectionner une espèce
  selectInput( 
    "select", 
    "Sélectionner un organisme:", 
    list("homo sapiens" = "humain", "mus musculus" = "souris", "gallus gallus" = "poulet")),
  
  # créer les onglets dans sidebar
  sidebarMenu(
    menuItem("Visualisation des données", tabName = "inspection", icon = icon("eye")),
    menuItem("Enrichissement (GO term)", icon = icon("sitemap"), tabName = "enrichissement", startExpanded = TRUE,
             menuSubItem("ORA", tabName = "ora_go"),
             menuSubItem("GSEA", tabName = "gsea_go")),
    menuItem("Enrichissement (Pathway)", icon = icon("chart-pie"),tabName = "pathway", startExpanded = TRUE,
             menuSubItem("ORA", tabName = "ora_path"),
             menuSubItem("GSEA", tabName = "gsea_path"))
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
        tabPanel("Importation des données", 
                 h3("Importer vos fichiers"),
                 p("Vous pouvez importer vos fichiers CSV via le menu à gauche."),
                 tags$ul(
                   tags$li("Les colonnes obligatoires sont : GeneName, ID, baseMean, log2FC, pval, padj"),
                   tags$li("Formats acceptés : CSV, TSV, TXT"),
                   tags$li("En cas d'erreur, un message s'affichera automatiquement")
                 )),
        tabPanel(
          "Visualisation données DEG",
          h3("Analyse et exploration des gènes différentiellement exprimés"),
          p("Ajustez les seuils de Log2FC et p-value pour faire varier le volcano plot."),
          
          p("Un volcano plot permet de visualiser les gènes différentiellement exprimés :"),
          tags$ul(
            tags$li("L'axe X représente le Log2 fold change (Log2FC)."),
            tags$li("L'axe Y représente le -log10(p-value)."),
            tags$li("Les gènes significativement régulés vers le haut ou vers le bas apparaissent généralement en rouge ou bleu.")
          ),
          
          p("Seuils par défaut : Log2FC = 1 et p-value = 0.05. Vous pouvez ajuster ces valeurs pour filtrer les gènes."),
          p("Les gènes colorés sont significatifs."),
          
          p("Fonctionnalités interactives disponibles :"),
          tags$ul(
            tags$li("Vous pouvez sélectionner des gènes directement sur le volcano plot et les afficher dans un tableau."),
            tags$li("Il est possible de télécharger le volcano plot en image."),
            tags$li("Vous pouvez également télécharger les tables de gènes filtrés selon les seuils choisis et le sens de régulation.")
          )
        ),
        tabPanel("Enrichissement", 
                 p("Explorez les GO terms pour identifier les processus biologiques associés."))
      )
    ),
    
    # ------ Onglet Visualisation ----------------------------------------------
    tabItem(tabName = "inspection",
            h2("Visualisation des données de DEG"),
            
            fluidRow( #  fluidRow permet de fixer ce qu'il y a dans la ligne
              # box pour le boxplot
              box(
                title = "Volcano plot", status = "primary", solidHeader = TRUE,
                width = 6,  
                plotlyOutput("plotly", height = 350),
                collapsible = T  
              ),
              
              # Summary box pour le total de gènes filtrés
              valueBoxOutput("nb_filtered_genes_box", width = 4),
              
              # box avec les sliders
              box(
                title = "Valeur seuil", solidHeader = TRUE,
                width = 6,
                chooseSliderSkin(skin= "Flat", color ="#264653"),
                uiOutput("slider_fc"),
                uiOutput("slider_pval"),
                bsTooltip("slider_fc", "Seuil de log2FC pour filtrer les gènes", placement = "top"),
                bsTooltip("slider_pval", "Seuil de p-value ajustée", placement = "top"),
                collapsible = T,
                actionButton("reset_all", "Réinitialiser")
              )
            ),
            
            # box contenant les tableaux de DEG (initial, filtré et sélectionné manuellement)
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
                tabPanel(
                  "Données sélectionnées",
                  DTOutput("selected_points_table"),
                  downloadButton("downloadSelected", "Télécharger")
                )
              )
            ),
    ),
    
    # ------ Onglet ORA GO term -----------------------------------------------
    tabItem(tabName = "ora_go",
            h2("Enrichissement (GO term)"),
            h3("Méthode ORA"),
            
            fluidRow(
              box(title = "Paramètres", solidHeader = TRUE, width = 12,
                  selectInput("reg_type", "Choisir le type de régulation :",
                              choices = c("Overexpressed" = "overexpress", 
                                          "Underexpress" ="underexpress",
                                          "Both" ="both"),
                              selected="both"),
                  selectInput("ont", "Choisir ontologie :", 
                              choices = c("Biological Process" = "BP",
                                          "Cellular Component" ="CC", 
                                          "Molecular Function" = "MF"),
                              selected="BP"),
                  actionButton("runGO", "Run", icon=icon("play"), class="btn-success"))
            ),
            
            fluidRow(
              box(title = "plot1", width=12,  height = 900,  solidHeader =TRUE, 
                  selectInput("select_graph1", "Sélectionner le type de graphique :", 
                              choices = c("dotplot" = "dotplot", 
                                          "ridgeplot" = "ridgeplot", 
                                          "cnetplot" = "cnetplot")),
                  plotOutput("go_plot1")),
              
              box(title = "plot2", width=12,  height = 600,  solidHeader =TRUE, 
                  selectInput("select_graph2", "Sélectionner le type de graphique :", 
                              choices = c("dotplot" = "dotplot", 
                                          "ridgeplot" = "ridgeplot", 
                                          "cnetplot" = "cnetplot")),
                  plotOutput("go_plot2"))
            ),
            
            fluidRow(
              box(title = "Tableau résultats ORA",
                  width = 12,
                  collapsible = TRUE
              )
            )
    ),
    
    # ------ Onglet GSEA GO term ----------------------------------------------
    tabItem(tabName = "gsea_go",
            h2("Enrichissement (GO term)"),
            h3("Méthode GSEA"),
            
            fluidRow(
              box(title = "Paramètre GSEA", 
                  width = 12, 
                  collapsible = TRUE
              )
            ),
            
            fluidRow(
              box(title = "Figure", 
                  width = 6,
                  status = "warning",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  selectInput( 
                    "select_graph", 
                    "Sélectionner le type de graphique:", 
                    list("dotplot" = "dotplot_gsea_go", "ridge_plot" = "ridge_gsea_go", "fig3" = "fig3"))
              ),
              box(title = "Figure",
                  width = 6,
                  status = "warning",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  
                  selectInput( 
                    "select_graph", 
                    "Sélectionner le type de graphique:", 
                    list("dotplot" = "dotplot_gsea_go", "ridge_plot" = "ridge_gsea_go", "fig3" = "fig3"))
              )
            ),
            
            fluidRow(
              box(title = "Tableau résultats GSEA",
                  width = 12,
                  collapsible = TRUE
              )
            )
    ) ,
    # ------ Onglet ORA Pathway -----------------------------------------------
    tabItem(tabName = "ora_path",
            h2("Enrichissement (Pathway)"),
            h3("Méthode ORA"),
            
            fluidRow(
              box(title = "Paramètre ORA", 
                  width = 12, 
                  collapsible = TRUE
              )
            ),
            
            fluidRow(
              box(title = "Figure", 
                  width = 6,
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  selectInput( 
                    "select_graph", 
                    "Sélectionner le type de graphique:", 
                    list("dotplot" = "dotplot_ora_path", "ridge_plot" = "ridge_ora_path", "fig3" = "fig3"))
              ),
              box(title = "Figure",
                  width = 6,
                  status = "primary",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  
                  selectInput( 
                    "select_graph", 
                    "Sélectionner le type de graphique:", 
                    list("dotplot" = "dotplot_oea_path", "ridge_plot" = "ridge_ora_path", "fig3" = "fig3"))
              )
            ),
            
            fluidRow(
              box(title = "Tableau résultats ORA",
                  width = 12,
                  collapsible = TRUE
              )
            )
    ),
    
    # ------ Onglet GSEA Pathway ----------------------------------------------
    tabItem(tabName = "gsea_path",
            h2("Enrichissement (Pathway)"),
            h3("Méthode GSEA"),
            
            fluidRow(
              box(title = "Paramètre GSEA", 
                  width = 12, 
                  collapsible = TRUE
              )
            ),
            
            fluidRow(
              box(title = "Figure", 
                  width = 6,
                  status = "warning",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  selectInput( 
                    "select_graph", 
                    "Sélectionner le type de graphique:", 
                    list("dotplot" = "dotplot_gsea_path", "ridge_plot" = "ridge_gsea_path", "fig3" = "fig3"))
              ),
              box(title = "Figure",
                  width = 6,
                  status = "warning",
                  solidHeader = TRUE,
                  collapsible = TRUE,
                  
                  selectInput( 
                    "select_graph", 
                    "Sélectionner le type de graphique:", 
                    list("dotplot" = "dotplot_gsea_path", "ridge_plot" = "ridge_gsea_path", "fig3" = "fig3"))
              )
            ),
            
            fluidRow(
              box(title = "Tableau résultats GSEA",
                  width = 12,
                  collapsible = TRUE
              )
            )
    )
  )
)

# construire l’interface utilisateur complète du tableau de bord Shiny
ui <-  dashboardPage(header,sidebar, body)
