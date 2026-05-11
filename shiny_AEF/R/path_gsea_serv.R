# Fonction pour générer les plots de l'onglet Pathway GSEA
# TODO : Checker que le tableau n'est pas vide ?

path_gsea_server <- function(id, deg_data, OrgDb_selected) { # filtered_genes
  moduleServer(id, function(input, output, session) {
    
    # TODO : Mettre ces fonctions dans le shared func pour les partager avec Miquel
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
      # nombre de permutations ?
      geneList = build_geneList(deg_data, input$rank_type_gsea)
      print(paste0("KEGG db : ",organism_kegg()))
      if (input$pathway_db == "kegg"){
        gsea = gseKEGG(
          geneList = geneList,
          organism = organism_kegg(),
          keyType =  "ncbi-geneid",
          minGSSize     = 10,
          maxGSSize     = 500,
          pAdjustMethod = input$padjust_method_path_gsea,
          verbose       = FALSE
        )
      } else if (input$pathway_db == "reactome"){
        gsea = gsePathway(
          geneList = geneList,
          organism = organism_reactome(),
          minGSSize     = 10,
          maxGSSize     = 500,
          pAdjustMethod = input$padjust_method_path_gsea,
          verbose       = FALSE
        )
      }
      print("gse done")
      return(gsea)
    })
    
    # ---- Génération du plot ----
    render_gsea_plot <- function(choice) {
      req(gsea_res())
      res <- gsea_res()
      
      res_tbl <- res@result
      res_tbl <- res_tbl[!is.na(res_tbl$core_enrichment) & nchar(res_tbl$core_enrichment) > 0, ]
      validate(need(nrow(res_tbl) > 0, "Aucun pathway valide"))
      top_id <- res_tbl$ID[1]
      
      switch(
        choice,
        "gseaplot" = gseaplot2(res, geneSetID = top_id),
        "dotplot" = dotplot(res, showCategory = input$n_cat_path_gsea),
        "emapplot" = {
          sim <- pairwise_termsim(res)
          emapplot(sim)
        },
        "ridgeplot" = ridgeplot(res),
      )
    }
    
    # Afficher les plots
    output$gsea_path_plot <- renderPlot({
      p <- render_gsea_plot(input$select_graph_gsea_path)
      if (input$select_graph_gsea_path != "gseaplot") {
        p <- p + ggtitle(input$plot_title_gsea_path)
      }
      p
    })
    
    output$path_gsea_table_results <- DT::renderDataTable({
      req(gsea_res())
      df = as.data.frame(gsea_res()@result)
    },
    options = list(pageLength = 10, scrollX = TRUE, order = list(list(5, "asc")) ))
    
    # # Renvoi résultats pour table
    # return(list(
    #   enrich_res = gsea_res
    # ))
    
    # Label précis reflétant les paramètres du dernier run
    source_label <- reactive({
      req(gsea_res())
      db_label <- switch(input$pathway_db,
                         "kegg" = "KEGG",
                         "reactome" = "Reactome",
                         input$pathway_db
      )
      paste0("Pathway GSEA (", db_label, ")")
    })
    
    # Test debug récupérer analyse dans manhattan plot
    observe({
      
      cat("\n=== PATH GSEA DEBUG ===\n")
      
      print(source_label())
      
      res <- gsea_res()
      
      if (!is.null(res)) {
        print(class(res))
        print(nrow(as.data.frame(res)))
      }
      
    })
    
    # Renvoi résultats pour table
    return(list(
      enrich_res = gsea_res,
      source_label = source_label
    ))
  })
}