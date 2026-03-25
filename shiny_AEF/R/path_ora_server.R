path_ora_server <- function(id, deg_data, filtered_genes, OrgDb_selected) {
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
    
    # variant de couleur pour les graphs
    ora_fill_scale <- function(palette) {
      switch(
        palette,
        "viridis"  = scale_fill_viridis_c(option = "D", name = "p.adjust"),
        "plasma"   = scale_fill_viridis_c(option = "plasma", name = "p.adjust"),
        "magma"    = scale_fill_viridis_c(option = "magma", name = "p.adjust"),
        "inferno"  = scale_fill_viridis_c(option = "inferno", name = "p.adjust"),
        "blue_red" = scale_fill_gradient(low = "blue", high = "red", name = "p.adjust"),
        "green_orange" = scale_fill_gradient(low= "limegreen" ,high = "darkorange2", name = "p.adjust")
      )
    }
    
    
    all_path_plots <- reactive({
      req(enrich_res())
      res <- enrich_res()
      req(res)
      
      # # Pour treeplot et netplot : calcul des similarités entre termes
      res_sim <- tryCatch(
        enrichplot::pairwise_termsim(res),
        error = function(e) NULL
      )
      
      list(
        barplot_ora_path = barplot(res, showCategory = input$n_terms),
        dotplot_ora_path = dotplot(res, showCategory = input$n_terms),
        cnetplot_ora_path = cnetplot(res),
        emaplot_ora_path = if (!is.null(res_sim))
          enrichplot::emapplot(res_sim, showCategory = input$n_terms) else NULL
      )
    })
    
    output$ora_plot_path <- renderPlot({
      plots <- all_path_plots()
      req(plots)
      p <- plots[[input$select_graph]]
      req(p)
      p + ora_fill_scale(input$color_palette) + ggtitle(input$plot_title)
    })
    
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