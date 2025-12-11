
# Fonction pour générer les plots de l'onglet Go term ORA 

go_ora_plot <- function(id, filtered_genes_display, OrgDb_selected){
  moduleServer(id, function(input, output, session){
    
    # ---- Filtre les donées : selon la sélection de l'utilisateur Down/Up/Both ----
    genes_filtered_type <- reactive({
      df <- filtered_genes_display()
      req(df)
      
      if (input$reg_type == "overexpress") {
        df <- df[df$Regulation == "Up", ]
      } else if (input$reg_type == "underexpress") {
        df <- df[df$Regulation == "Down", ]
      }
      df
    })
    
    
    # ----ORA enrichGO ----
    enrich_res <- eventReactive(input$runGO, {
      df <- genes_filtered_type()
      
      validate(
        need(nrow(df) > 0, "Aucun gène ne passe les filtres !")
      )
      
      gene_list <- df$ID   # Ensembl IDs
      
      
      enrichGO(
        gene          = gene_list,
        OrgDb         = OrgDb_selected(),
        keyType       = "ENSEMBL",
        ont           = input$ont,
        pAdjustMethod = "BH",
        pvalueCutoff  = 0.05,
        qvalueCutoff  = 0.2
      )
    })
    
    
    # ---- fonction plot ------
    render_go_plot <- function(choice) {
      res <- enrich_res()
      req(res)
      
      switch(choice,
             "ridgeplot" = ridgeplot(res, showCategory = 10),
             "dotplot"   = dotplot(res),
             "cnetplot"  = cnetplot(res, showCategory = 10)
      )
    }
    
    
    # Affiche les plots 
    output$go_plot1 <- renderPlot(render_go_plot(input$select_graph1))
    output$go_plot2 <- renderPlot(render_go_plot(input$select_graph2))
    
    # Renvoi résultats pour table
    return(list(
      enrich_res = enrich_res
    ))
    
  })
}
