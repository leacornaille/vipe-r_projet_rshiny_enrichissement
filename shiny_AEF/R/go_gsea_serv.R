# Ce module gère la partie GSEA pour les termes GO, avec différents types de plots (dotplot, emapplot, gseaplot, ridgeplot, treeplot, goplot) 
# et un tableau interactif des résultats. 
# Il prend en entrée les données de DEGs et l'OrgDb sélectionné pour effectuer l'enrichissement.

go_gsea_plot <- function(id, deg_data, OrgDb_selected) { # filtered_genes
  moduleServer(id, function(input, output, session) {
    
    # ---- Préparation : création d'un vecteur nommé pour GSEA ----
    ranked_genes <- reactive({
      deg_data <- deg_data()
      
      df <- build_gene_list(deg_data, input$rank_type_gsea)
      df
    })
    
    # ---- Calcul GSEA ----
    gsea_res <- eventReactive(input$runGSEA, {
      
      geneList <- ranked_genes()
      validate(need(length(geneList) > 0, "Aucun gène valide pour la GSEA."))
      
      if (isTRUE(input$use_permutation_go_gsea)) {
        gseGO(
          geneList = geneList,
          OrgDb = OrgDb_selected(),
          keyType = "ENTREZID",
          ont = input$ont,
          minGSSize = 15,
          maxGSSize = 500,
          pAdjustMethod = input$padjust_method_go_gsea,
          pvalueCutoff = input$padj_thr_gsea,
          verbose = FALSE,
          nPerm = as.numeric(input$nperm_go_gsea)
        )
      } else {
        gseGO(
          geneList = geneList,
          OrgDb = OrgDb_selected(),
          keyType = "ENTREZID",
          ont = input$ont,
          minGSSize = 15,
          maxGSSize = 500,
          pAdjustMethod = input$padjust_method_go_gsea,
          pvalueCutoff = input$padj_thr_gsea,
          verbose = FALSE
        )
      }
    })
    
    # ---- Génération du plot ----
    render_gsea_plot <- function(choice) {
      res <- gsea_res()
      req(res)
      
      res@result <- res@result[!is.na(res@result$core_enrichment) & nchar(res@result$core_enrichment) > 0, ]
      validate(need(nrow(res@result) > 0, "Aucun terme GO enrichi"))
      
      # récupérer le GO choisi dans le tableau des résultats GSEA (ID + description)
      sel_go_id <- selected_go_id()
      
      # Calcul de la matrice de distance des termes pour certains plots
      sim <- pairwise_termsim(res)
      
      switch(
        choice,
        "gseaplot" = gseaplot2(
          x = res, 
          geneSetID = sel_go_id, 
          title = if (length(sel_go_id) == 1) {
            paste0(input$plot_title_gsea_go, " ", "(", sel_go_id, " - ", res@result$Description[res@result$ID == sel_go_id][1], ")")}
          else {input$plot_title_gsea_go}
        ),
        
        "dotplot" = dotplot(
          object = res, 
          showCategory = min(input$n_cat_gsea, nrow(res@result)),
          title = input$plot_title_gsea_go,
          color = 'p.adjust'
        ),
        
        "emapplot" = {
          validate(
            need(nrow(as.data.frame(res)) > 1,
                 "Pas assez de termes enrichis pour emapplot")
          )
          emapplot(sim, 
                   showCategory = min(input$n_cat_gsea, nrow(res@result)),
                   color = 'p.adjust')
        },
        
        
        "ridgeplot" = ridgeplot(
          x = res,
          showCategory = as.numeric(min(input$n_cat_gsea, nrow(res@result))),
        ),
        
        "treeplot" =  {
          validate(
            need(nrow(as.data.frame(res)) > 1,
                 "Pas assez de termes enrichis pour emapplot")
          )
          treeplot(
            x = sim,
            showCategory = min(input$n_cat_gsea, nrow(res@result)),
          )
        },
        
        "goplot" = goplot(
          x = res,
          showCategory = as.numeric(min(input$n_cat_gsea, nrow(res@result)))
        )
      )
    }
    
    # Afficher les plots
    output$gsea_go_plot1 <- renderPlot({
      p <- render_gsea_plot(input$select_graph_gsea_go1)
      # Ajouter palette seulement au dotplot, ridgeplot, empalot
      if (input$select_graph_gsea_go1 %in% c("dotplot", "emapplot", "ridgeplot", "goplot")) {
        p <- p + color_palette(input$color_palette_go_gsea)
      }
      p
    })
    
    # Tableau interactif : terme GO sélectionné pour le GSEA plot
    output$go_gsea_table_results <- DT::renderDataTable({
      res <- gsea_res()
      req(res)
      df <- as.data.frame(res@result)
    },
    
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
    
    # Label avec les paramètres du dernier run pour recap_serv (Manhattan Plot)
    source_label <- reactive({
      req(gsea_res())
      paste0("GO GSEA (", input$ont, ")")
    })
    
    # Téléchargement du tableau
    output$download_table_gsea_go <- downloadHandler(
      filename = function() { paste0("GO_GSEA_", input$ont, "_results.csv") },
      content = function(file) {
        res <- gsea_res()
        req(res)
        write.csv(as.data.frame(res@result), file, row.names = FALSE)
      }
    )
    
    
    # Renvoi résultats pour table du Manhattan Plot
    return(list(
      enrich_res = gsea_res,
      source_label = source_label
    ))
  })
}