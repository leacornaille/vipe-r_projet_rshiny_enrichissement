# Ce module gère la création du volcano plot à partir des données de DEG, avec des options de filtrage basées sur les seuils de p-value et de log2FC. 
# Il permet également à l'utilisateur de sélectionner des points sur le volcano plot pour afficher les détails dans un tableau, et offre la possibilité de télécharger les gènes sélectionnés.
volcano_plot <- function(id, deg_data, pval_threshold, fc_threshold, reset_all) {
  moduleServer(id, function(input, output, session) {
    
    make_vplot <-function(deg_data, pval_threshold, fc_threshold){
     return (renderPlotly({
      df_deg <- deg_data()
      req(df_deg)
      
      # S'assurer que les valeurs sont numériques
      log2fc_deg <- as.numeric(df_deg$log2FC)
      padj_deg <- as.numeric(df_deg$padj)
      
      # Calculer -log10(padj) avec protection contre valeurs nulles
      padj_log <- -log10(padj_deg)
      
      # Colore en rouge les gènes sur-régulés et en vert les sous-régulés significatif
      colors <- ifelse(
        padj_log >= -log10(pval_threshold()) & log2fc_deg >= fc_threshold(), 
        "#74c69d",
        ifelse(
          padj_log >= -log10(pval_threshold()) & log2fc_deg <= -fc_threshold(),
          "#FF6B6B",
          "lightgrey"
        )
      )
      
      # texte affiché au survol d'un point
      hover_text <- paste(
        "Gène :", df_deg$GeneName, "<br>",
        "log2FC :", round(log2fc_deg, 3), "<br>",
        "padj :", signif(padj_deg, 3), "<br>",
        "-log10(padj) :", round(padj_log, 3)
      )
      
      # apparence du volcano plot
      vplot <- plot_ly(
        x = ~log2fc_deg, 
        y = ~padj_log, 
        type = "scatter",
        mode = "markers", 
        marker = list(color = colors),
        text = hover_text, 
        hoverinfo = "text",
        source = "volcano"
      ) %>%
        event_register("plotly_selected") %>%
        layout(
          title = "Volcano plot",
          xaxis = list(title = "Log2FC"),
          yaxis = list(title = "-log10(padj)")
        )
      
      vplot
    }))
  }
    output$plotly = make_vplot(deg_data, pval_threshold, fc_threshold)
    
    
    # permet de garder en mémoire les points selectionné sur le volcano plot
    selected_point_volcano <- reactiveVal(NULL)
    
    # récupère les points selectionnés et renvoie les indices
    observe({
      s <- tryCatch(
        plotly::event_data("plotly_selected", source = "volcano"),
        error = function(e) NULL
      )
      if (is.null(s)) return()   # rien à faire si aucun point sélectionné
      
      selected_point_volcano(deg_data()[s$pointNumber + 1, ])
    })
   
    # Réinitialise la sélection sur le tableau
    observeEvent(reset_all(), {
      selected_point_volcano(NULL)
      output$plotly = make_vplot(deg_data, pval_threshold, fc_threshold)
    }) 
    
    # Affiche le tableau avec les points sélectionnés
    output$selected_points_table <- renderDataTable({
      req(selected_point_volcano())
      datatable(selected_point_volcano(), options = list(scrollX=T))
    })
    
    # téléchargement du tableau avec les points selectionnées par l'utilisateur
    output$downloadSelected <- downloadHandler(
      filename = function() { "selected_genes.csv" },
      content = function(file) {
        req(selected_point_volcano())  # assure qu'il y a des points sélectionnés
        write.csv(selected_point_volcano(), file, row.names = FALSE)
      }
    )
  })
}