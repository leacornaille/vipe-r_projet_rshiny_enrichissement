
# Fonction pour générer les plots de l'onglet Go term ORA 
go_ora_plot <- function(id, deg_data, filtered_genes, OrgDb_selected, pval_threshold, fc_threshold){
  moduleServer(id, function(input, output, session){

    # ------ box info pour le filtrage -----------------------------------------
    output$filter_info_box <- renderUI({
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


    # ------ ORA enrichGO ------------------------------------------------------
    enrich_res_ora <- eventReactive(input$runGO, {
      req(OrgDb_selected(), deg_data())
      
      df <- filtered_genes()
      
      # Filtrage Up / Down / Both
      if (input$reg_type == "overexpress") {
        df <- df[df$Regulation == "Up", ]
      } else if (input$reg_type == "underexpress") {
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
      
      # Universe : soit les gènes de la liste, soit tous les gènes de l'organisme
      univ <- if (input$univers_ora_go == "gene_list") {
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

      # Enrichissement GO term via enrichGO
      res <- enrichGO(
        gene = ids,
        OrgDb = OrgDb_selected(),
        universe = univ,
        keyType = "ENTREZID",
        ont = input$ont,
        pAdjustMethod = input$padjust_method_go_ora,
        pvalueCutoff = input$pval_ora_go,
        readable = TRUE
      )
      
      # Simplification des termes GO redondants si demandée
      if (!is.null(res) && nrow(as.data.frame(res)) > 0 && isTRUE(input$simplify_ora_go)) {
        tryCatch(
          res <- clusterProfiler::simplify(res, cutoff = 0.7, by = "p.adjust", select_fun = min),
          error = function(e) {
            showNotification(paste("simplify() a échoué :", e$message), type = "warning", duration = 5)
          }
        )
      }
      res
    })
    
    # ------ Graphiques --------------------------------------------------------
    all_go_plots <- reactive({
      req(enrich_res_ora())
      res <- enrich_res_ora()
      req(res)

      # # Pour treeplot et netplot : calcul des similarités entre termes
      res_sim <- tryCatch(
        enrichplot::pairwise_termsim(res),
        error = function(e) NULL
      )

      list(
        barplot = barplot(res, showCategory = input$n_cat_go_ora),
        dotplot = dotplot(res, showCategory = input$n_cat_go_ora),
        cnetplot = cnetplot(res),
        treeplot = if (!is.null(res_sim))
          enrichplot::treeplot(res_sim, showCategory = input$n_cat_go_ora) else NULL,
        netplot = if (!is.null(res_sim))
          enrichplot::emapplot(res_sim, showCategory = input$n_cat_go_ora) else NULL,
        goplot = goplot(res)
      )
    })



    # ---------------- Affichage des plots ---------------------------------------
    output$ora_go_plot1 <- renderPlot({
      plots <- all_go_plots()
      req(plots)
      p <- plots[[input$select_graph_ora_go1]]
      req(p)
      
      title <- input$plot_title_ora_go
      
      # treeplot retourne un objet patchwork → traitement séparé
      if (input$select_graph_ora_go1 == "treeplot") {
        p + patchwork::plot_annotation(
          title = title,
          theme = ggplot2::theme(
            plot.title = ggplot2::element_text(size = 18, face = "bold", hjust = 0.5)
          )
        )
      } else {
        suppressWarnings(
          p + color_palette(input$color_palette_go_ora) +
            ggtitle(title) +
            ggplot2::theme(
              plot.title = ggplot2::element_text(size = 18, face = "bold", hjust = 0.5)
            )
        )
      }
    }, res = 85)

    output$ora_go_table <- DT::renderDataTable({
      res <- enrich_res_ora()
      req(res)
      df <- as.data.frame(res)
    },
    options = list(pageLength = 15, scrollX = TRUE, order = list(list(5, "asc"))))

    # Label précis reflétant les paramètres du dernier run
    source_label <- reactive({
      req(enrich_res_ora())
      paste0("GO ORA (", input$ont, ")")
    })
    
    # Téléchargement du tableau
    output$download_table_ora_go <- downloadHandler(
      filename = function() { paste0("GO_ORA_", input$ont, "_results.csv") },
      content = function(file) {
        res <- enrich_res_ora()
        req(res)
        write.csv(as.data.frame(res), file, row.names = FALSE)
      }
    )
    

    # Renvoi résultats pour table
    return(list(
      enrich_res = enrich_res_ora,
      source_label = source_label
      ))
    })
}
