volcano_plot_UI = function(id){
  vplotly_ns = NS(id) # Regarde les sortie du module 
  
  box(
    title = "Volcano plot", status = "primary", solidHeader = TRUE,
    width = 6,  
    withSpinner(plotlyOutput(vplotly_ns("plotly"), height = 350), image = "loading.GIF", image.width = 200, image.height = 150),
    collapsible = T  
  )
}