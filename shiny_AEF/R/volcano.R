volcano_plot <- function(id, deg_data, pval_threshold, fc_threshold) {
  moduleServer(id, function(input, output, session) {
    
    output$plotly <- renderPlotly({
      input$reset_all
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
        "#FF6B6B",
        ifelse(
          padj_log >= -log10(pval_threshold()) & log2fc_deg <= -fc_threshold(),
          "#74c69d",
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
    })
  })
}