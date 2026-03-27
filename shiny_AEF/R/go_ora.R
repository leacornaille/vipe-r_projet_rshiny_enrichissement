
# Fonction pour générer les plots de l'onglet Go term ORA 

go_ora_plot <- function(id, deg_data, filtered_genes, OrgDb_selected, pval_threshold, fc_threshold){
  moduleServer(id, function(input, output, session){

    #----------------Filtrage selon le type de régulation choisi ---------------
    genes_filtered_type <- reactive({
      df <- filtered_genes()
      req(df)

      # Filtrage selon le type de régulation choisi
      if (input$reg_type == "overexpress") {
        df <- df[df$Regulation == "Up", ]
      } else if (input$reg_type == "underexpress") {
        df <- df[df$Regulation == "Down", ]
      }
      df
    })

    # box info pour le filtrage
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



    # ----ORA enrichGO ----
    enrich_res <- eventReactive(input$runGO, {
      df <- genes_filtered_type()

      validate(
        need(nrow(df) > 0, "Aucun gène ne passe les filtres !")
      )

      # Création de la liste de gènes
      genes <- unique(df$GeneName)   

      gene_list <- tryCatch({
        ids<- mapIds(
          OrgDb_selected(),
          keys = genes,
          column = "ENTREZID",
          keytype = "SYMBOL",
          multiVals = "first"
        )
        ids<-ids[!is.na(ids)]
        unique(ids)
      }, error = function(e){
        showNotification(
          paste("Erreur conversion gènes : ", e$message),
          type = "error"
        )
        character(0)
      })

      univ <- if (input$univers_ora_go == "gene_list") {
        unique(deg_data()$ID)   
      } else {
        req(OrgDb_selected())
        keys(OrgDb_selected(), keytype = "ENTREZID")                       # tous les gènes des données DEG
      }



      # Enrichissement GO term via enrichGO
      enrichGO(
        gene          = gene_list,
        OrgDb         = OrgDb_selected(),
        universe      = univ,
        keyType       = "ENTREZID",
        ont           = input$ont,
        pAdjustMethod = input$padjust_method_go_ora,
        pvalueCutoff  = input$pval_ora_go,
        readable = TRUE
      )
    })

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

    all_go_plots <- reactive( {
      req(enrich_res())
      res <- enrich_res()
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



    # ---------------- Affichage des plots ----------------
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
        p + ora_scales(input$color_palette_go_ora) +
          ggtitle(title) +
          ggplot2::theme(
            plot.title = ggplot2::element_text(size = 18, face = "bold", hjust = 0.5)
          )
      }
    }, res = 85)


    output$ora_go_table <- DT::renderDataTable({
      res <- enrich_res()
      req(res)
      df <- as.data.frame(res)
    },
    options = list(pageLength = 15, scrollX = TRUE, order = list(list(5, "asc"))))


    # Renvoi résultats pour table
    return(list(
      enrich_res = enrich_res
      ))
    })
}
