path_ora_server <- function(id, deg_data, filtered_genes, OrgDb_selected, pval_threshold, fc_threshold) {
  moduleServer(id, function(input, output, session) {
    
    # filtered_genes provenant du serveur principal
    gene_list <- reactive({
      df <- filtered_genes()
      req(df)
      
      # Filtrer selon le type
      if (input$gene_type == "up") {
        df <- df[!is.na(df$Regulation) & df$Regulation == "Up", ]
      } else if (input$gene_type == "down") {
        df <- df[!is.na(df$Regulation) & df$Regulation == "Down", ]
      } else if (input$gene_type == "both") {
        df <- df[!is.na(df$Regulation) & df$Regulation %in% c("Up", "Down"), ]
      }
      
      if (nrow(df) == 0) return(character(0))
      
      genes <- df$GeneName
      genes[!is.na(genes) & genes != ""]
    })
    
    # box info utilisé pour filtrage
    output$filter_info <- renderUI({
      req(pval_threshold(), fc_threshold())
      panel(
          heading = "Critères actifs",
          status = "primary",
        tags$div(
          class = "filter-info",
          tags$span(class = "padj", paste0("p.adjust ≤ ", pval_threshold())),
          tags$span(class = "logfc", paste0("|log2FC| ≥ ", fc_threshold()))
        )
      )
    })
    
    # Universe : utiliser deg_data (données brutes)
    universe <- eventReactive(input$run_ora_path, {
      # Ne s'exécute que quand on clique sur le bouton
      df <- deg_data()
      req(df)
      
      if (nrow(df) == 0) return(NULL)
      
      genes <- unique(df$GeneName)
      genes <- genes[!is.na(genes) & genes != ""]
      
      if (length(genes) == 0) return(NULL)
      
      # Convertir en ENTREZ ID
      tryCatch({
        ids <- mapIds(
          OrgDb_selected(),
          keys = genes,
          column = "ENTREZID",
          keytype = "SYMBOL",
          multiVals = "first"
        )
        ids <- ids[!is.na(ids)]
        unique(ids)
      }, error = function(e) {
        showNotification(
          paste("Erreur conversion universe:", e$message),
          type = "warning"
        )
        NULL
      })
    })
    
    entrezID <- reactive({
      req(OrgDb_selected(), gene_list())
      
      genes <- gene_list()
      if (length(genes) == 0) return(character(0))
      
      tryCatch({
        ids <- mapIds(
          OrgDb_selected(),
          keys = genes,
          column = "ENTREZID",
          keytype = "SYMBOL",
          multiVals = "first"
        )
        
        ids <- ids[!is.na(ids)]
        unique(ids)
      }, error = function(e) {
        showNotification(
          paste("Erreur conversion gènes:", e$message),
          type = "error"
        )
        character(0)
      })
    })
    
    organism_reactome <- reactive({
      req(OrgDb_selected())
      if (identical(OrgDb_selected(), org.Mm.eg.db)) "mouse"
      else if (identical(OrgDb_selected(), org.Hs.eg.db)) "human"
      else NULL
    })
    
    organism_kegg <- reactive({
      req(OrgDb_selected())
      if (identical(OrgDb_selected(), org.Mm.eg.db)) "mmu"
      else if (identical(OrgDb_selected(), org.Hs.eg.db)) "hsa"
      else NULL
    })
    
    universe_genome <- reactive({
      req(OrgDb_selected())
      keys(OrgDb_selected(), keytype = "ENTREZID")
    })
    
    enrich_res <- eventReactive(input$run_ora_path, {
      req(organism_kegg())
      req(organism_reactome())
      
      ids <- entrezID()
      
      if (length(ids) == 0) {
        showNotification("Aucun gène valide trouvé", type = "warning")
        return(NULL)
      }
      
      if (input$univers_ora_path == "gene_list"){
        univ <- universe()
      } else {
        univ <- universe_genome()
      }
      
      # Message informatif
      msg <- paste("Analyse avec", length(ids), "gènes")
      if (!is.null(univ)) {
        msg <- paste0(msg, " (universe: ", length(univ), " gènes)")
      }
      showNotification(msg, type = "message", duration = 3)
      
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
    
    observe({
      req(enrich_res())
      n <- nrow(as.data.frame(enrich_res()))
      updateSliderInput(session, "n_terms", max = min(n, 50))
    })
    
    # Une seule fonction — retourne fill + color simultanément
    # ggplot2 ignore celle qui n'est pas utilisée dans le plot
    ora_scales <- function(palette) {
      list(
        switch(palette,
               "viridis"      = scale_fill_viridis_c(option = "D",       name = "p.adjust"),
               "plasma"       = scale_fill_viridis_c(option = "plasma",   name = "p.adjust"),
               "magma"        = scale_fill_viridis_c(option = "magma",    name = "p.adjust"),
               "inferno"      = scale_fill_viridis_c(option = "inferno",  name = "p.adjust"),
               "mako"         = scale_fill_viridis_c(option = "mako",     name = "p.adjust"),
               "rocket"       = scale_fill_viridis_c(option = "rocket",   name = "p.adjust"),
               "cividis"      = scale_fill_viridis_c(option = "cividis",  name = "p.adjust"),
               "turbo"        = scale_fill_viridis_c(option = "turbo",    name = "p.adjust"),
               "YlOrRd"       = scale_fill_distiller(palette = "YlOrRd",  name = "p.adjust", direction = 1),
               "blue_red"     = scale_fill_gradient(low = "blue",         high = "red",         name = "p.adjust"),
               "green_orange" = scale_fill_gradient(low = "limegreen",    high = "darkorange2", name = "p.adjust")
        ),
        switch(palette,
               "viridis"      = scale_color_viridis_c(option = "D",       name = "p.adjust"),
               "plasma"       = scale_color_viridis_c(option = "plasma",   name = "p.adjust"),
               "magma"        = scale_color_viridis_c(option = "magma",    name = "p.adjust"),
               "inferno"      = scale_color_viridis_c(option = "inferno",  name = "p.adjust"),
               "mako"         = scale_color_viridis_c(option = "mako",     name = "p.adjust"),
               "rocket"       = scale_color_viridis_c(option = "rocket",   name = "p.adjust"),
               "cividis"      = scale_color_viridis_c(option = "cividis",  name = "p.adjust"),
               "turbo"        = scale_color_viridis_c(option = "turbo",    name = "p.adjust"),
               "YlOrRd"       = scale_color_distiller(palette = "YlOrRd",  name = "p.adjust", direction = 1),
               "blue_red"     = scale_color_gradient(low = "blue",         high = "red",         name = "p.adjust"),
               "green_orange" = scale_color_gradient(low = "limegreen",    high = "darkorange2", name = "p.adjust")
        )
      )
    }
    
    # renderPlot — identique pour tous les graphiques
    all_path_plots <- reactive({
      req(enrich_res())
      res <- enrich_res()
      
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
      req(plots)
      p <- plots[[input$select_graph]]
      req(p)
      p + ora_scales(input$color_palette) + ggtitle(input$plot_title)
    }, res = 85)
    
    output$table_results <- DT::renderDataTable({
      req(enrich_res())
      
      res <- enrich_res()
      
      DT::datatable(
        as.data.frame(res),
        options = list(scrollX = TRUE, pageLength = 15)
      )
    })
    
  })
}