
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
        pAdjustMethod = input$padjust_method_go_ora,
        pvalueCutoff  = 0.05,
        qvalueCutoff  = 0.2,
        readable = TRUE
      )
    })
    
    all_go_plots <- eventReactive(input$runGO, {
      res <- enrich_res()
      req(res)

      # # Pour treeplot et netplot : calcul des similarités entre termes
      res_sim <- tryCatch(
        enrichplot::pairwise_termsim(res),
        error = function(e) NULL
      )

      list(
        barplot = barplot(res, showCategory = 10),
        dotplot = dotplot(res, showCategory = 10),
        cnetplot = cnetplot(res),
        treeplot = if (!is.null(res_sim))
          enrichplot::treeplot(res_sim, showCategory = 10) else NULL,
        netplot = if (!is.null(res_sim))
          enrichplot::emapplot(res_sim, showCategory = 10) else NULL,
        goplot = goplot(res)
      )
    })

    # ---------------- Affichage des plots ----------------
    output$ora_go_plot1 <- renderPlot({ 
      plots <- all_go_plots() ;
      req(plots) ;
      plots[[input$select_graph_ora_go1]]})

    output$ora_go_plot2 <- renderPlot({ 
      plots <- all_go_plots() ;
      req(plots) ;
      plots[[input$select_graph_ora_go2]]})

    # ---- fonction plot ORA GO term ------
    # render_go_plot <- function(choices) {
    #   res <- enrich_res()
    #   req(res)
      

    #   # Pour treeplot et netplot : calcul des similarités entre termes
    #   if (choices %in% c("treeplot", "netplot")) {
    #     res <- tryCatch(
    #       enrichplot::pairwise_termsim(res),
    #       error = function(e) NULL
    #     )
    #   }


    #   # Génération du plot en fonction du choix
    #   switch(choices,
    #          "barplot" = barplot(res, showCategory = 10),
    #          "dotplot"   = dotplot(res, showCategory = 10),
    #          "cnetplot"  = cnetplot(res),
    #          "treeplot"  = enrichplot::treeplot(res, showCategory = 10),
    #          "netplot" = enrichplot::emapplot(res, showCategory = 10),
    #          "goplot" = goplot(res)
    #          )
    #     }
    
    # # Affiche les plots 
    # output$ora_go_plot1 <- renderPlot(render_go_plot(input$select_graph_ora_go1))
    # output$ora_go_plot2 <- renderPlot(render_go_plot(input$select_graph_ora_go2))


  output$ora_go_table <- DT::renderDataTable({
    res <- enrich_res()
    req(res)
    df <- as.data.frame(res@result)
    df[, c("ID", "Description", "GeneRatio", "BgRatio", "pvalue", "p.adjust", "qvalue", "geneID", "Count")]
  },
  options = list(pageLength = 10, scrollX = TRUE, order = list(list(5, "asc")) ))


    # Renvoi résultats pour table
    return(list(
      enrich_res = enrich_res
      ))
    })
}
