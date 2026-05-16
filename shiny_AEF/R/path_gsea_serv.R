path_gsea_server <- function(id, deg_data, OrgDb_selected) {
  moduleServer(id, function(input, output, session) {
    
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
    
    # ---- Calcul GSEA ----
    gsea_res <- eventReactive(input$runGSEA, {
      geneList <- build_geneList(deg_data(), input$rank_type_gsea)
      if (input$pathway_db == "kegg") {
        gsea <- gseKEGG(
          geneList = geneList,
          organism = organism_kegg(),
          keyType = "ncbi-geneid",
          minGSSize = 10,
          maxGSSize = 500,
          pvalueCutoff = input$pval_path_gsea,
          pAdjustMethod = input$padjust_method_path_gsea,
          verbose = FALSE
        )
      } else if (input$pathway_db == "reactome") {
        gsea <- gsePathway(
          geneList = geneList,
          organism = organism_reactome(),
          minGSSize = 10,
          maxGSSize = 500,
          pvalueCutoff = input$pval_path_gsea,
          pAdjustMethod = input$padjust_method_path_gsea,
          verbose = FALSE
        )
      }
      return(gsea)
    })
    
    # ---- Pathway sélectionné dans le tableau ----
    selected_pathway_id <- reactive({
      req(gsea_res())
      df <- as.data.frame(gsea_res()@result)
      idx <- input$path_gsea_table_results_rows_selected
      if (is.null(idx) || length(idx) == 0) return(df$ID[1])
      return(df$ID[idx])
    })
    
    # ---- Mise à jour slider selon résultats ----
    observe({
      req(gsea_res())
      n <- nrow(as.data.frame(gsea_res()@result))
      updateSliderInput(session, "n_cat_path_gsea", max = max(1, min(n, 50)))
    })
    
    # ---- Plots standards (hors pathview) ----
    output$gsea_path_plot <- renderPlot({
      req(gsea_res(), input$select_graph_gsea_path != "pathway")
      res <- gsea_res()
      
      p <- switch(
        input$select_graph_gsea_path,
        "gseaplot" = gseaplot2(res, geneSetID = selected_pathway_id()),
        "dotplot" = dotplot(res, showCategory = input$n_cat_path_gsea),
        "emapplot"  = {
          sim <- pairwise_termsim(res)
          emapplot(sim)
        },
        "ridgeplot" = ridgeplot(res),
        "cnetplot" = cnetplot(res)
      )
      
      if (!input$select_graph_gsea_path %in% c("gseaplot")) {
        p <- p + ggtitle(input$plot_title_gsea_path)
      }
      p
    })
    
    # ---- Pathview : même logique que ORA ----
    
    # Alimentation du selectInput pathview depuis le tableau
    observe({
      req(gsea_res())
      res <- gsea_res()
      df <- as.data.frame(res@result)
      voie_ids <- setNames(df$ID, df$Description)
      updateSelectInput(session, "pathview_kegg_id_gsea", choices = voie_ids)
    })
    
    # Génération + affichage dans modal avec barre de progression
    observeEvent(input$run_pathview_gsea, {
      req(input$pathview_kegg_id_gsea, input$pathway_db == "kegg")
      pathway_id <- input$pathview_kegg_id_gsea
      file_png <- paste0(pathway_id, ".pathview.png")
      
      withProgress(message = "Génération Pathview...", value = 0, {
        incProgress(0.2, detail = "Préparation des données...")
        geneList <- build_geneList(deg_data(), input$rank_type_gsea)
        
        incProgress(0.3, detail = "Connexion KEGG...")
        if (!file.exists(file_png)) {
          tryCatch({
            pathview(
              gene.data  = geneList,
              pathway.id = pathway_id,
              species = organism_kegg(),
              limit = list(gene = max(abs(geneList)), cpd = 1)
            )
          }, error = function(e) {
            showNotification(paste("Erreur Pathview :", e$message), type = "error", duration = 10)
            return()
          })
        }
        incProgress(0.5, detail = "Affichage...")
      })
      
      req(file.exists(file_png))
      showModal(modalDialog(
        title = "Pathview",
        size = "xl",
        easyClose = TRUE,
        footer = actionButton(session$ns("close_pathview_gsea"), "Fermer", class = "btn-default"),
        tags$head(tags$style(".modal-dialog { width: 90vw !important; max-width: 90vw !important; }")),
        tags$div(
          style = "width:100%; overflow:auto; max-height:75vh;",
          imageOutput(session$ns("pathview_plot_gsea"),
                      width  = "100%",
                      height = "auto")
        )
      ))
    })
    
    output$pathview_plot_gsea <- renderImage({
      req(input$pathview_kegg_id_gsea)
      file_png <- paste0(input$pathview_kegg_id_gsea, ".pathview.png")
      req(file.exists(file_png))
      list(
        src = file_png,
        contentType = "image/png",
        width = "100%",
        height = "auto",
        deleteFile = FALSE
      )
    }, deleteFile = FALSE)
    
    # Fermeture + nettoyage
    observeEvent(input$close_pathview_gsea, {
      pathway_id <- input$pathview_kegg_id_gsea
      removeModal()
      invisible(file.remove(c(
        paste0(pathway_id, ".pathview.png"),
        paste0(pathway_id, ".png"),
        paste0(pathway_id, ".xml")
      )[file.exists(c(
        paste0(pathway_id, ".pathview.png"),
        paste0(pathway_id, ".png"),
        paste0(pathway_id, ".xml")
      ))]))
    })
    
    # ---- Tableau résultats ----
    output$path_gsea_table_results <- DT::renderDataTable({
      req(gsea_res())
      as.data.frame(gsea_res()@result)
    }, options = list(pageLength = 10, scrollX = TRUE, order = list(list(5, "asc")),
                      selection = "single"))
    
    # Téléchargement du tableau
    output$download_table_gsea_path <- downloadHandler(
      filename = function() { paste0("Pathway_GSEA_", input$pathway_db, "_results.csv") },
      content = function(file) {
        req(gsea_res())
        write.csv(as.data.frame(gsea_res()@result), file, row.names = FALSE)
      }
    )
    
    # ---- Source label ----
    source_label <- reactive({
      req(gsea_res())
      db_label <- switch(input$pathway_db,
                         "kegg"     = "KEGG",
                         "reactome" = "Reactome",
                         input$pathway_db)
      paste0("Pathway GSEA (", db_label, ")")
    })
    
    return(list(
      enrich_res   = gsea_res,
      source_label = source_label
    ))
  })
}