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
      
      geneList <- ranked_genes()
      validate(need(length(geneList) > 0, "Aucun gène valide pour la GSEA."))
      
      gseGO(
        geneList      = geneList,
        OrgDb         = OrgDb_selected(),
        keyType       = "ENTREZID",
        ont           = input$ont,
        minGSSize     = 15,
        maxGSSize     = 500,
        pAdjustMethod = input$padjust_method_go_gsea,
        pvalueCutoff  = input$pval_ora_gsea,
        verbose       = FALSE
      )
      
      # nombre de permutations ?
      
    })
    
    # ---- Génération du plot ----
    render_gsea_plot <- function(choice) {
      res <- gsea_res()
      req(res)
      
      res_tbl <- res@result
      res_tbl <- res_tbl[!is.na(res_tbl$core_enrichment) & nchar(res_tbl$core_enrichment) > 0, ]
      validate(need(nrow(res_tbl) > 0, "Aucun terme GO valide"))
      # top_id <- res_tbl$ID[1]
      sel_go_id <- selected_go_id() # GO choisi dans le tableau des résultats GSEA
      
      gseaplot2(res, geneSetID = sel_go_id)
      
      switch(
        choice,
        "gseaplot" = gseaplot2(res, geneSetID = sel_go_id),
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
    
    # Tableau interactif : terme GO sélectionné pour le GSEA plot
    output$go_gsea_table_results <- DT::renderDataTable({
      res <- gsea_res()
      req(res)
      df <- as.data.frame(res@result)
    },
    selection = "single", # une seule (terme GO) ligne sélectionnable à la fois

    options = list(pageLength = 10, scrollX = TRUE, order = list(list(5, "asc")) ))
    
    # Sélection d'un terme GO du tableau pour les plots
    selected_go_id <- reactive({
      res <- gsea_res()
      req(res)
      
      df <- as.data.frame(res@result)
      idx_selGO <- input$go_gsea_table_results_rows_selected
      
      # Si rien de sélectionné, top 1 par défaut
      if (is.null(idx_selGO) || length(idx_selGO) == 0) {
        return(df$ID[1])
      }
      df$ID[idx_selGO]
    })
    
    # Renvoi résultats pour table
    return(list(
      enrich_res = gsea_res
    ))
  })
}