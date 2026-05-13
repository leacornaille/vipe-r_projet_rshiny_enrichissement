path_ora_server <- function(id, deg_data, filtered_genes, OrgDb_selected, pval_threshold, fc_threshold) {
  moduleServer(id, function(input, output, session) {
    
    output$filter_info <- renderUI({ 
      req(pval_threshold(), fc_threshold()) 
      panel( heading = "Critères actifs", status = "primary", 
             tags$div( class = "filter-info", 
                       tags$span(class = "padj", paste0("p.adjust ≤ ", pval_threshold())),
                       tags$span(class = "logfc", paste0("|log2FC| ≥ ", fc_threshold())) 
             ) 
      ) 
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
    
    enrich_res_ora_path <- eventReactive(input$run_ora_path, {
      req(OrgDb_selected(), deg_data())
      
      df <- filtered_genes()
      
      if (input$gene_type == "up") {
        df <- df[df$Regulation == "Up", ]
      } else if (input$gene_type == "down") {
        df <- df[df$Regulation == "Down", ]
      } else {
        df <- df[df$Regulation %in% c("Up", "Down"), ]
      }
      
      ids <- df$ENTREZID
      ids <- unique(ids[!is.na(ids) & ids != "Not found"])
      
      if (length(ids) == 0) {
        showNotification("Aucun gène valide trouvé", type = "warning")
        return(NULL)
      }
      
      univ <- if (input$univers_ora_path == "gene_list") {
        unique(deg_data()$ENTREZID)
      } else {
        keys(OrgDb_selected(), keytype = "ENTREZID")
      }
      
      showNotification(paste("Analyse avec", length(ids), "gènes"), type = "message", duration = 3)
      
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
        } else {
          enrichKEGG(
            gene = ids,
            universe = univ,
            organism = organism_kegg(),
            pvalueCutoff = input$pval_ora,
            pAdjustMethod = input$p_adjust_method
          )
        }
      }, error = function(e) {
        showNotification(paste("Erreur ORA :", e$message), type = "error", duration = 10)
        NULL
      })
    })
    
    observe({
      req(enrich_res_ora_path())
      res <- enrich_res_ora_path()
      n <- nrow(as.data.frame(res))
      updateSliderInput(session, "n_terms", max = max(1, min(n, 50)))
    })
    
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
      
      fc_vector <- setNames(deg_data()$log2FC, deg_data()$ENTREZID)
      
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
    
    observe({
      req(enrich_res_ora_path())
      res <- enrich_res_ora_path()
      
      voie_ids_ora <- setNames(
        res$ID,
        res$Description
      )
      updateSelectInput(
        session,
        "pathview_kegg_id",
        choices = voie_ids_ora
      )
    })
    
    output$pathview_plot <- renderImage({
      req(enrich_res_ora_path(), input$pathview_kegg_id)
      
      geneList   <- setNames(deg_data()$log2FC, deg_data()$ENTREZID)
      pathway_id <- input$pathview_kegg_id
      file_png   <- paste0(pathway_id, ".pathview.png")
      
      if (!file.exists(file_png)) {
        withProgress(message = "Chargement Pathview...", value = 0, {
          
          incProgress(0.2, detail = "Préparation des données...")
          Sys.sleep(0.1)
          
          incProgress(0.3, detail = "Connexion KEGG...")
          tryCatch({
            pathview(
              gene.data  = geneList,
              pathway.id = pathway_id,
              species    = organism_kegg(),
              limit      = list(gene = max(abs(geneList)), cpd = 1)
            )
          }, error = function(e) {
            showNotification(paste("Erreur Pathview :", e$message), type = "error", duration = 10)
          })
          
          incProgress(0.5, detail = "Génération de l'image...")
        })
      }
      
      req(file.exists(file_png))
      list(
        src = file_png,
        contentType = "image/png",
        width = "100%",
        height = "100%",
        deleteFile  = FALSE
      )
    }, deleteFile = FALSE)
    
    observeEvent(input$run_pathview, {
      req(input$pathview_kegg_id)
      showModal(modalDialog(
        title     = "Pathview",
        size      = "xl",
        easyClose = TRUE,
        footer    = FALSE,
        tags$head(tags$style(".modal-dialog { width: 90vw !important; max-width: 90vw !important; }")),
        tags$div(
          style = "width:100%; overflow:auto; max-height:75vh;",
          imageOutput(session$ns("pathview_plot"),
                      width  = "100%",
                      height = "100%")
        )
      ))
    })
    
    # Nettoyage à la fermeture de session
    session$onSessionEnded(function() {
      files_to_remove <- c(
        paste0(input$pathview_kegg_id, ".png"),
        paste0(input$pathview_kegg_id, ".xml"),
        paste0(input$pathview_kegg_id, ".pathview.png")
      )
      invisible(file.remove(files_to_remove[file.exists(files_to_remove)]))
    })
    
    output$table_results <- DT::renderDataTable({
      req(enrich_res_ora_path())
      DT::datatable(
        as.data.frame(enrich_res_ora_path()),
        options = list(scrollX = TRUE, pageLength = 15)
      )
    })
    
    source_label <- reactive({
      req(enrich_res_ora_path())
      db_label <- switch(input$pathway_db,
                         "kegg" = "KEGG",
                         "reactome" = "Reactome",
                         input$pathway_db
      )
      paste0("Pathway ORA (", db_label, ")")
    })
    
    return(list(
      enrich_res = enrich_res_ora_path,
      source_label = source_label
    ))
  })
}