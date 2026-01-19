path_ora_server <- function(id, deg_data, filtered_genes,OrgDb_selected) {
  moduleServer(id, function(input, output, session) {
    
    #  filtered_genes provenant du serveur principal
    gene_list <- reactive({
      df <- filtered_genes()
      req(df)
      
      if (input$gene_type == "up") {
        df <- df[df$Regulation == "Up", ]
      } else if (input$gene_type == "down") {
        df <- df[df$Regulation == "Down", ]
      } else if (input$gene_type == "both") {
        df <- df[df$Regulation %in% c("Up","Down")]
      }
      df$GeneName   # la colonne gène 
    })
    
    universe <- reactive({
      df <- deg_data()
      req(df)
      if (nrow(df) == 0) return(character(0))
      unique(df$GeneName)
    })
    
    
    entrezID <- reactive({
      req(OrgDb_selected(), gene_list())
      mapIds(
        OrgDb_selected(),
        keys = gene_list(),
        column = "ENTREZID",
        keytype = "SYMBOL",
        multiVals = "first"
      ) %>% na.omit() %>% unique()
    })
    
    organism_code <- reactive({
      req(OrgDb_selected())
      if (identical(OrgDb_selected(), org.Mm.eg.db)) "mmu"
      else if (identical(OrgDb_selected(), org.Hs.eg.db)) "hsa"
    })
    
    enrich_res <- eventReactive(input$run_ora_path, {
      req(entrezID(), universe(), organism_code())
      
      tryCatch({
        if (input$pathway_db == "reactome") {
          enrichPathway(
            gene          = entrezID(),
            universe      = universe(),
            organism      = organism_code(),
            pvalueCutoff  = input$pval_ora,
            pAdjustMethod = input$p_adjust_method,
            readable      = TRUE
          )
        } else if (input$pathway_db == "kegg") {
          enrichKEGG(
            gene          = entrezID(),
            universe      = universe(),
            organism      = organism_code(),
            pvalueCutoff  = input$pval_ora,
            pAdjustMethod = input$p_adjust_method
          )
        }
      }, error = function(e) {
        showNotification(paste("Erreur ORA :", e$message), type = "error", duration = 10)
        NULL
      })
    })
    
    
    output$dotplot_ora_path <- renderPlot({
      req(enrich_res())
      dotplot(enrich_res())
    })
    
    output$table_results <- DT::renderDataTable({
      req(enrich_res())
      as.data.frame(enrich_res())
    })
    
  })
}
