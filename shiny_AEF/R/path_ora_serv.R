path_ora_server <- function(id, deg_data, filtered_genes, OrgDb_selected, pval_threshold, fc_threshold) {
  moduleServer(id, function(input, output, session) {
    
    # box info utilisé pour filtrage 
    output$filter_info <- renderUI({ 
      req(pval_threshold(), fc_threshold()) 
      panel( heading = "Critères actifs", status = "primary", 
             tags$div( class = "filter-info", 
                       tags$span(class = "padj", paste0("p.adjust ≤ ", pval_threshold())),
                       tags$span(class = "logfc", paste0("|log2FC| ≥ ", fc_threshold())) 
                     ) 
           ) 
    })
    
    # Organism Reactome
    organism_reactome <- reactive({
      req(OrgDb_selected())
      if (identical(OrgDb_selected(), org.Mm.eg.db)) "mouse"
      else if (identical(OrgDb_selected(), org.Hs.eg.db)) "human"
      else NULL
    })
    
    # Organism KEGG
    organism_kegg <- reactive({
      req(OrgDb_selected())
      if (identical(OrgDb_selected(), org.Mm.eg.db)) "mmu"
      else if (identical(OrgDb_selected(), org.Hs.eg.db)) "hsa"
      else NULL
    })
    
    # ORA analysis
    enrich_res_ora_path <- eventReactive(input$run_ora_path, {
      req(OrgDb_selected(), deg_data())
      
      df <- filtered_genes()
      
      # Filtrage Up / Down / Both
      if (input$gene_type == "up") {
        df <- df[df$Regulation == "Up", ]
      } else if (input$gene_type == "down") {
        df <- df[df$Regulation == "Down", ]
      } else {
        df <- df[df$Regulation %in% c("Up", "Down"), ]
      }
      
      # Gènes d’intérêt ORA (ENTREZID)
      ids <- df$ENTREZID
      ids <- ids[!is.na(ids) & ids != "Not found"]
      ids <- unique(ids)
      
      if (length(ids) == 0) {
        showNotification("Aucun gène valide trouvé", type = "warning")
        return(NULL)
      }
      
      # Universe
      univ <- if (input$univers_ora_path == "gene_list") {
        unique(deg_data()$ENTREZID)
      } else {
        req(OrgDb_selected())
        keys(OrgDb_selected(), keytype = "ENTREZID")
      }
      
      # Message informatif
      msg <- paste("Analyse avec", length(ids), "gènes")
      if (!is.null(univ)) {
        msg <- paste0(msg, " (universe: ", length(univ), " gènes)")
      }
      showNotification(msg, type = "message", duration = 3)
      
      # Enrichement
      tryCatch({
        if (input$pathway_db == "reactome") {
          enrichPathway(
            gene = ids,
            universe = univ,
            organism = organism_reactome(),
            pvalueCutoff = input$pval_ora,
            pAdjustMethod = input$p_adjust_method,
            readable = TRUE
          )
        } else if (input$pathway_db == "kegg") {
          enrichKEGG(
            gene = ids,
            universe = univ,
            organism = organism_kegg(),
            pvalueCutoff = input$pval_ora,
            pAdjustMethod = input$p_adjust_method
          )
        }
      }, error = function(e) {
        showNotification(
          paste("Erreur ORA :", e$message),
          type = "error",
          duration = 10
        )
        NULL
      })
    })
    
    # update slider dynamique
    observe({
      req(enrich_res_ora_path())
      n <- nrow(as.data.frame(enrich_res_ora_path()))
      updateSliderInput(session, "n_terms", max = min(n, 50))
    })
    
    # renderPlot — identique pour tous les graphiques
    all_path_plots <- reactive({
      req(enrich_res_ora_path())
      res <- enrich_res_ora_path()
      
      res_readable <- tryCatch(
        setReadable(res, OrgDb = OrgDb_selected(), keyType = "ENTREZID"),
        error = function(e) res
      )
      
      res_sim <- tryCatch(
        enrichplot::pairwise_termsim(res, method = "JC"),
        error = function(e) NULL
      )
      
      fc_vector <- setNames(deg_data()$log2FC, deg_data()$GeneName)
      
      list(
        barplot_ora_path  = barplot(res, showCategory = input$n_terms),
        dotplot_ora_path  = dotplot(res, showCategory = input$n_terms),
        cnetplot_ora_path = cnetplot(res_readable, showCategory = input$n_terms,
                                     foldChange = fc_vector),
        emaplot_ora_path  = if (!is.null(res_sim))
          enrichplot::emapplot(res_sim, showCategory = input$n_terms) else NULL
      )
    })
    
    output$ora_plot_path <- renderPlot({
      plots <- all_path_plots()
      p <- plots[[input$select_graph]]
      suppressWarnings(
        p + color_palette(input$color_palette) + ggtitle(input$plot_title)
      )
    }, res = 85)
    
    # table results
    output$table_results <- DT::renderDataTable({
      req(enrich_res_ora_path())
      res <- enrich_res_ora_path()
      
      DT::datatable(
        as.data.frame(res),
        options = list(scrollX = TRUE, pageLength = 15)
      )
    })
    
    # Label précis reflétant les paramètres du dernier run
    source_label <- reactive({
      req(enrich_res_ora_path())
      db_label <- switch(input$pathway_db,
                         "kegg"     = "KEGG",
                         "reactome" = "Reactome",
                         input$pathway_db
      )
      paste0("Pathway ORA (", db_label, ")")
    })
    
    
    # Renvoi résultats pour table
    return(list(
      enrich_res = enrich_res_ora_path,
      source_label = source_label
    ))
  })
}