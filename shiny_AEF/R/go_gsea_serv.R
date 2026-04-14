# Fonction pour générer les plots de l'onglet GO term GSEA

go_gsea_plot <- function(id, deg_data, OrgDb_selected) { # filtered_genes
  moduleServer(id, function(input, output, session) {
    
    # ---- Préparation : création d'un vecteur nommé pour GSEA ----
    ranked_genes <- reactive({
      df <- deg_data()
      
      # Enlever les gènes pour lesquels les ENTREZID sont "Not found"
      df <- df[df$ENTREZID != "Not found",]

      # Tri décroissant comme attendu par GSEA
      gene_list <- df$log2FC # ATTENTION
      names(gene_list) <- df$ENTREZID
      gene_list <- sort(gene_list, decreasing = TRUE)
      
      return(gene_list)
    })
    
    # ---- Calcul GSEA ----
    
    gsea_res <- eventReactive(input$runGSEA, {
      # validate(need(nrow(genes_filtered_type()) > 0, "Aucun gène ne passe les filtres !"))
      
      geneList <- ranked_genes()
      # nombre de permutations ?
      gseGO(
        geneList      = geneList,
        OrgDb         = OrgDb_selected(),
        keyType       = "ENTREZID",
        ont           = input$ont,
        minGSSize     = 15,
        maxGSSize     = 500,
        pAdjustMethod = "BH",
        # attention : laisser le choix à l'utilisateur ?
        # pvalueCutoff  = 1, # laisser le choix à l'utilisateur (cf. ORA GO Christine)
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
    
    output$go_gsea_table_results <- DT::renderDataTable({
      res <- gsea_res()
      req(res)
      df <- as.data.frame(res@result)
      # df[, c("ID", "Description", "GeneRatio", "BgRatio", "pvalue", "p.adjust", "qvalue", "geneID", "Count")]
    },
    options = list(pageLength = 10, scrollX = TRUE, order = list(list(5, "asc")) ))
    
    # Renvoi résultats pour table
    return(list(
      enrich_res = gsea_res
    ))
  })
}