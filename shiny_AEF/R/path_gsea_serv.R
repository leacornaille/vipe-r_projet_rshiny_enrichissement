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
    
    
    geneList = build_geneList(deg_data)
    # ---- Calcul GSEA ----
    gsea_res <- eventReactive(input$runGSEA, {

      # nombre de permutations ?
      gseKEGG(
        geneList      = geneList,
        OrgDb         = OrgDb_selected(),
        keyType       = "ENTREZID",
        ont           = input$ont,
        minGSSize     = 10,
        maxGSSize     = 500,
        pAdjustMethod = "BH",
        # attention : laisser le choix à l'utilisateur ?
        # pvalueCutoff  = 1, # laisser le choix à l'utilisateur (cf. ORA GO Christine)
        verbose       = FALSE
      )
    })
    
    
    
    # ---- Génération du plot ----
    render_gsea_plot <- function(choice) {
      req(gsea_res())
      res <- gsea_res()
      
      res_tbl <- res@result
      res_tbl <- res_tbl[!is.na(res_tbl$core_enrichment) & nchar(res_tbl$core_enrichment) > 0, ]
      validate(need(nrow(res_tbl) > 0, "Aucun GO term valide"))
      top_id <- res_tbl$ID[1]
      
      gseaplot2(res, geneSetID = top_id)
      
      switch(
        choice,
        "gseaplot" = gseaplot2(res, geneSetID = top_id),
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
    
    output$go_gsea_table_results <- DT::renderDataTable({
      req(gsea_res())
      df = as.data.frame(renderDataTable@result)
    },
    options = list(pageLength = 10, scrollX = TRUE, order = list(list(5, "asc")) ))
    
    # Renvoi résultats pour table
    return(list(
      enrich_res = gsea_res
    ))
  })
}