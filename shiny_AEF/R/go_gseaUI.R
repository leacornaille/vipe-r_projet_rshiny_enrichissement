# Fonction pour générer les plots de l'onglet GO term GSEA

go_gsea_plot <- function(id, deg_data, OrgDb_selected) { # filtered_genes
  moduleServer(id, function(input, output, session) {
    
    #attention, pour GSEA, on utilise tous les gènes, pas Up ou Down au choix comme pour l'ORA
    genes_filtered_type <- reactive({
      df <- deg_data()
      req(df)
      df
    })
    
    # ---- Préparation : création d'un vecteur nommé pour GSEA ----
    ranked_genes <- reactive({
      df <- genes_filtered_type()
      req(df)
      
      # Tri décroissant comme attendu par GSEA
      req(input$rank_type_gsea)
      rank_type <- input$rank_type_gsea
      rank_type = input$rank_type_gsea
      gene_list <- df[[rank_type]] # log2FC or padj
      names(gene_list) <- df$ID
      gene_list <- sort(gene_list, decreasing = TRUE)
      
      gene_list
    })
    
    # ---- Calcul GSEA ----
    
    gsea_res <- eventReactive(input$runGSEA, {
      df <- genes_filtered_type()
      
      validate(need(nrow(df) > 0, "Aucun gène ne passe les filtres !"))
      
      gl <- ranked_genes()
      
      # ---- Mapping ENSEMBL -> ENTREZID ----
      mapped <- bitr(
        names(gl),
        fromType = "ENSEMBL",
        toType = "ENTREZID",
        OrgDb = OrgDb_selected()
      )
      
      if (nrow(mapped) == 0) {
        showNotification("Aucun gène mappé à l'OrgDb !", type = "error")
        return(NULL)
      }
      
      # Merge avant ranking
      df <- merge(df, mapped, by.x = "ID", by.y = "ENSEMBL")
      
      # Construire la geneList
      geneList <- df$log2FC
      names(geneList) <- df$ENTREZID
      
      geneList <- sort(geneList, decreasing = TRUE)
      geneList <- geneList[!duplicated(names(geneList))]
      geneList <- geneList[!is.na(geneList)]
      
      gseGO(
        geneList      = geneList,
        OrgDb         = OrgDb_selected(),
        # checker le format attendu (ou ID, org.Mm.eg.db)
        keyType       = "ENTREZID",
        ont           = input$ont,
        minGSSize     = 15,
        maxGSSize     = 500,
        pAdjustMethod = "BH",
        # attention : laisser le choix à l'utilisateur ?
        # pvalueCutoff  = 1,
        verbose       = FALSE
      )
    })
    
    # ---- Génération du plot ----
    render_gsea_plot <- function(choice) {
      res <- gsea_res()
      req(res)
      
      res_tbl <- res@result
      res_tbl <- res_tbl[!is.na(res_tbl$core_enrichment) & nchar(res_tbl$core_enrichment) > 0, ]
      validate(need(nrow(res_tbl) > 0, "Aucun GO term valide"))
      top_id <- res_tbl$ID[1]
      
      gseaplot2(res, geneSetID = top_id)
      
      switch(
        choice,
        "gseaplot" = gseaplot2(res, geneSetID = top_id),
        "dotplot" = dotplot(res, showCategory = 15),
        "emapplot" = {
          sim <- pairwise_termsim(res)
          emapplot(sim)
        },
        "ridgeplot" = ridgeplot(res),
      )
    }
    
    gsea_table <- reactive({
      res <- gsea_res()
      req(res)
      
      tbl <- as.data.frame(res@result)
      tbl <- tbl[!is.na(tbl$core_enrichment) & nchar(tbl$core_enrichment) > 0, ]
      validate(need(nrow(tbl) > 0, "Aucun GO term valide"))
      
      tbl
    })
    
    # Afficher les plots
    output$gsea_go_plot1 <- renderPlot(render_gsea_plot(input$select_graph_gsea_go1))
    output$go_gsea_table_results <- renderDataTable({
      datatable(gsea_table(),
                options = list(scrollX = TRUE, 
                               scrollY = TRUE))})
    
    # 
    # # Affiche la table non filtré sous forme de datatable
    # output$table <- renderDataTable({
    #   req(deg_data())
    #   datatable(deg_data(), options = list(scrollX=T))
    # })
    
    # Renvoi résultats pour table
    return(list(
      enrich_res = gsea_res
    ))
  })
}