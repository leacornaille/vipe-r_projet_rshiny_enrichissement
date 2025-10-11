#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
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
# ce script server.R correspond au côté serveur et ne fonctionne que si il y a 
# également un script ui.R
#--------------------------------------------------------------------------


library(shiny)

# Define server
function(input, output, session) {
  
  # Affiche les informations sur le fichier uploadé
  output$file1_contents <- renderPrint({
    req(input$file)
    print(input$file)
  })
  
  # Lecture du fichier CSV (tout le code dans les accolades)
  data <- reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })
  
  # Affiche la table sous forme de datatable
  output$table <- renderDataTable({
    req(data())
    datatable(data())
  })
  
  # permet le téléchargement 
  output$downloadData <- downloadHandler(
    filename = function() { "data.csv" },
    content = function(file) {
      req(data())                  
      write.csv(data(), file, row.names = FALSE)
    }
  )
  
  observeEvent(input$info_btn, {
    showModal(
      modalDialog(
        title = "À propos de VIPE-R",
        HTML(
          "<p><b>Auteur :</b> Léa Cornaille</p>
         <p><b>Email :</b> lea.cornaille@hotmail.com</p>
         <p><b>Affiliation :</b> Université de Rouen</p>
         <p><b>Projet :</b> Analyse d'enrichissement fonctionnel</p>
         <p><b>Date :</b> 10-2025</p>"
        ),
        easyClose = TRUE,
        footer = modalButton("Fermer")
      )
    )
  })
}