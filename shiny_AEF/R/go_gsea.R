# Fonction pour générer les plots de l'onglet GO term GSEA

go_gsea_plot <- function(id, deg_data, OrgDb_selected) { # filtered_genes
  moduleServer(id, function(input, output, session) {
    
    #attention, pour GSEA, on utilise tous les gènes, pas Up ou Down au choix comme pour l'ORA
    genes_filtered_type <- reactive({
      df <- deg_data() # filtered_genes
      req(df)
      df
    })
    
    # ---- Préparation : création d'un vecteur nommé pour GSEA ----
    ranked_genes <- reactive({
      df <- genes_filtered_type()
      req(df)
      
      # Tri décroissant comme attendu par GSEA
      gene_list <- df$log2FC
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
      
      print(length(geneList)) # doit être >1000 si possible
      print(sum(!is.na(names(geneList))))  # doit être = length(geneList))
      
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
    
    # Afficher les plots
    output$gsea_go_plot1 <- renderPlot(render_gsea_plot(input$select_graph_gsea_go1))
    output$gsea_go_plot2 <- renderPlot(render_gsea_plot(input$select_graph_gsea_go2))
    
    
    # Renvoi résultats pour table
    return(list(
      enrich_res = gsea_res
    ))
  })
}