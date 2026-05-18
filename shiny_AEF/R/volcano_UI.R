# Ce module correspond à la partie "Volcano plot" de l'application.
# Il correspond à la partie UI de ce module, qui permet à l'utilisateur de visualiser les résultats de l'analyse différentielle à travers un volcano plot interactif, et d'explorer les gènes spécifiques en fonction de leurs caractéristiques (log2FC, p-value, etc.).
volcano_plot_ui <- function(id){
  vplotly_ns = NS(id) # Regarde les sortie du module 
  
      box(
        title = "Volcano plot", status = "primary", solidHeader = TRUE,
        width = 6,  
        withSpinner(plotlyOutput(vplotly_ns("plotly"), height = 420), image = "loading.GIF", image.width = 200, image.height = 150),
        collapsible = T  
      )
}

selected_table_ui <- function(id){
  selected_table_ns = NS(id)

  tabPanel(
    "Données sélectionnées",
    DTOutput(selected_table_ns("selected_points_table")),
    downloadButton(selected_table_ns("downloadSelected"), "Télécharger")
  )
}