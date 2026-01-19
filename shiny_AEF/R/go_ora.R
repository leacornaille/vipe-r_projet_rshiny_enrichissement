
# Fonction pour générer les plots de l'onglet Go term ORA 

go_ora_plot <- function(id, filtered_genes, OrgDb_selected){
  moduleServer(id, function(input, output, session){

    #----------------Filtrage selon le type de régulation choisi -----------------
    genes_filtered_type <- reactive({
      df <- filtered_genes()
      req(df)
      
      # Filtrage selon le type de régulation choisi
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

      # Création de la liste de gènes
      gene_list <- unique(df$ID)   # Ensembl IDs
    
      # Enrichissement GO term via enrichGO
      enrichGO(
        gene          = gene_list,
        OrgDb         = OrgDb_selected(),
        keyType       = "ENSEMBL",
        ont           = input$ont,
        pAdjustMethod = "BH",
        pvalueCutoff  = 0.05,
        qvalueCutoff  = 0.2,
        readable = TRUE
      )
    })
    
    # ---- fonction plot ORA GO term ------
    render_go_plot <- function(choice) {
      res <- enrich_res()
      req(res)
      

      # Pour treeplot et netplot : calcul des similarités entre termes
      if (choice %in% c("treeplot", "netplot")) {
        res <- tryCatch(
          enrichplot::pairwise_termsim(res),
          error = function(e) NULL
          )}


      # Génération du plot en fonction du choix
      switch(choice,
             "barplot" = barplot(res, showCategory = 10),
             "dotplot"   = dotplot(res, showCategory = 10),
             "cnetplot"  = cnetplot(res),
             "treeplot"  = enrichplot::treeplot(res, showCategory = 10),
             "netplot" = enrichplot::emapplot(res, showCategory = 10),
             "goplot" = goplot(res)
             )
        }
    
    # Affiche les plots 
    output$ora_go_plot1 <- renderPlot(render_go_plot(input$select_graph_ora_go1))
    output$ora_go_plot2 <- renderPlot(render_go_plot(input$select_graph_ora_go2))

    # Renvoi résultats pour table
    return(list(
      enrich_res = enrich_res
      ))
    })
}
