#----------------------------------------------------------------
# auteur: Léa Cornaille
# mail: lea.cornaille@hotmail.com
# Affiliation: Université de Rouen
# Date: 10-2025

# Description: Ce script permet de créer une interface en Rshiny. 
# Il contient pour l'instant la mise en forme de l'application 
# et le premier volet qui permet de visualiser et télécharger les données de DEG
# Il intégrera par la suite des fonctions permettant l'analyse d'enrichissement
# ce script server.R correspond au côté serveur et ne fonctionne que si il y a 
# également un script ui.R
#--------------------------------------------------------------------------

# Define server
function(input, output, session) {
  
  #------Données DEG--------------------------------------------------------------
  
  
  # Affiche les informations sur le fichier uploadé
  output$file1_contents <- renderPrint({
    req(input$file)
    print(input$file)
  })
  
  # Lecture du fichier avec fread (format accepté: csv, tsv et txt)
  deg_data <- reactive({
    req(input$file)
    
    # Vérification extension (et pop-up en cas de mauvais fichier)
    ext <- tools::file_ext(input$file$name)
    if (!ext %in% c("csv","tsv","txt")) {
      showModal(modalDialog(
        title = "Format de fichier incorrect",
        paste("Format :", ext, "Formats acceptés : .csv, .tsv, .txt"),
        easyClose = TRUE,
        footer = modalButton("Fermer")
      ))
      return(NULL)
    }
    
    # Lecture avec fread pour détecter automatiquement le separateur
    isolate({
      df_deg <- fread(input$file$datapath)
      
      # Vérification colonnes obligatoires (et pop-up si elles manquent)
      required_cols <- c("GeneName","ID","baseMean","log2FC","pval","padj")
      missing <- setdiff(required_cols, colnames(df_deg))
      if (length(missing) > 0) {
        showModal(modalDialog(
          title = "Colonnes manquantes",
          HTML(paste0("Votre fichier doit contenir :", paste(required_cols, collapse=", "),
                      "<br>Colonnes absentes :", paste(missing, collapse=", "))),
          easyClose = TRUE,
          footer = modalButton("Fermer")
        ))
        return(NULL)
      }
      
      # Conversion en numérique des colonnes critiques
      df_deg$log2FC <- as.numeric(df_deg$log2FC)
      df_deg$padj <- as.numeric(df_deg$padj)
      df_deg$baseMean <- as.numeric(df_deg$baseMean)
      df_deg$pval <- as.numeric(df_deg$pval)
      
      return(df_deg)
    })
  })
  
  # gènes filtrés en fonction des sliders 
  filtered_genes <- reactive({
    df_deg <- deg_data()
    req(df_deg, input$slider_pval, input$slider_fc)
    
    # Conversion en data.frame pour éviter les problèmes avec data.table
    df_deg <- as.data.frame(df_deg)
    
    # Créer un vecteur logique pour le filtrage
    keep <- !is.na(df_deg$log2FC) & 
      !is.na(df_deg$padj) &
      (df_deg$padj <= input$slider_pval) &
      (abs(df_deg$log2FC) >= input$slider_fc)
    
    # Appliquer le filtre
    df_filtered <- df_deg[keep, ]
    
    # Ajouter la colonne "Regulation" (en fonction du seuil log2fc)
    df_filtered$Regulation <- ifelse(
      df_filtered$log2FC >= input$slider_fc, "Up", "Down"
    )
    
    # Retourner le data.frame filtré
    df_filtered
  })
  
  
  # les gènes à afficher selon les case cochées (up et down)
  filtered_genes_display <- reactive({
    df_filtre_updown <- filtered_genes()
    req(df_filtre_updown)
    
    # Si aucune case n'est cochée: tableau vide
    if (is.null(input$regulation_choice) || length(input$regulation_choice) == 0) {
      return(df_filtre_updown[0, ])  # renvoie un data.frame vide
    }
    
    # Filtrage selon Up / Down sélectionnés
    df_filtre_updown[df_filtre_updown$Regulation %in% input$regulation_choice, ]
  })
  
  # nombre de gènes filtrés
  output$nb_filtered_genes_box <- renderValueBox({
    df <- filtered_genes()
    req(df)
    # somme des gènes up et/ou down 
    n_up   <- sum(df$Regulation == "Up", na.rm = TRUE)
    n_down <- sum(df$Regulation == "Down", na.rm = TRUE)
    n_total <- nrow(df)
    
    valueBox(
      value = paste0(n_total," gènes DEG"),
      subtitle = paste0("Up: ", n_up, " | Down: ", n_down),
      icon = icon("dna"),
      color = "light-blue"
    )
  })
  
  # Affiche la table non filtré sous forme de datatable
  output$table <- renderDataTable({
    req(deg_data())
    datatable(deg_data(), options = list(scrollX=T))
  })
  
  # Affiche la table filtré sous forme de datatable
  output$table_filtered <- renderDataTable({
    req(filtered_genes_display())
    datatable(filtered_genes_display(), options = list(scrollX=T))
  })
  
  
  # slider en fonction du log2FC
  output$slider_fc <- renderUI({ 
    df_deg <- deg_data()
    req(df_deg)
    log2fc_vals <- as.numeric(df_deg$log2FC)
    log2fc_vals <- log2fc_vals[!is.na(log2fc_vals)]
    sliderInput("slider_fc", "Log2FC", min = 0, max = round(max(abs(log2fc_vals)), 2), value = 0.5)
  })
  
  # slider en fonction de la p-value
  output$slider_pval <- renderUI({ 
    df_deg <- deg_data()
    req(df_deg)
    sliderInput("slider_pval", "P-value ajustée", min=0, max=1, value=0.1) 
  })
  
  ### volcano plot 
  output$plotly <- renderPlotly({
    input$reset_all
    
    df_deg <- deg_data()
    req(df_deg)
    req(input$slider_pval, input$slider_fc)
    
    # S'assurer que les valeurs sont numériques
    log2fc_deg <- as.numeric(df_deg$log2FC)
    padj_deg <- as.numeric(df_deg$padj)
    
    # Calculer -log10(padj) avec protection contre valeurs nulles
    padj_log <- -log10(padj_deg)
    
    # Colore en rouge les gènes sur-régulés et en vert les sous-régulés significatif
    colors <- ifelse(
      padj_log >= -log10(input$slider_pval) & log2fc_deg >= input$slider_fc, 
      "#FF6B6B",
      ifelse(
        padj_log >= -log10(input$slider_pval) & log2fc_deg <= -input$slider_fc,
        "#74c69d",
        "lightgrey"
      )
    )
    
    # texte affiché au survol d'un point
    hover_text <- paste(
      "Gène :", df_deg$GeneName, "<br>",
      "log2FC :", round(log2fc_deg, 3), "<br>",
      "padj :", signif(padj_deg, 3), "<br>",
      "-log10(padj) :", round(padj_log, 3)
    )
    
    # apparence du volcano plot
    p <- plot_ly(
      x = ~log2fc_deg, 
      y = ~padj_log, 
      type = "scatter",
      mode = "markers", 
      marker = list(color = colors),
      text = hover_text, 
      hoverinfo = "text",
      source = "volcano"
    ) %>%
      event_register("plotly_selected") %>%
      layout(
        title = "Volcano plot",
        xaxis = list(title = "Log2FC"),
        yaxis = list(title = "-log10(padj)")
      )
    
    p
  })
  
  # permet de garder en mémoire les points selectionné sur le volcano plot
  selected_point_volcano <- reactiveVal(NULL)
  
  # récupère les points selectionnés et renvoie les indices
  observe({
    s <- tryCatch(
      plotly::event_data("plotly_selected", source = "volcano"),
      error = function(e) NULL
    )
    
    if (is.null(s)) return()   # rien à faire si aucun point sélectionné
    
    df_deg <- deg_data()
    selected_point_volcano(df_deg[s$pointNumber + 1, ])
  })
  
  # Réinitialise la selection quand appuie sur "reset"
  observeEvent(input$reset_all, {
    selected_point_volcano(NULL)
  })
  
  # Affiche le tableau avec les points sélectionnés
  output$selected_points_table <- renderDataTable({
    req(selected_point_volcano())
    datatable(selected_point_volcano(), options = list(scrollX=T))
  })
  
  # permet le téléchargement du tableau filtré (up ou down ou les deux)
  output$downloadData <- downloadHandler(
    filename = function() { "filtered_genes.csv" },
    content = function(file) {
      req(filtered_genes())                  
      write.csv(filtered_genes_display(), file, row.names = FALSE)
    }
  )
  
  # téléchargement du tableau avec les points selectionnées par l'utilisateur
  output$downloadSelected <- downloadHandler(
    filename = function() { "selected_genes.csv" },
    content = function(file) {
      req(selected_point_volcano())  # assure qu'il y a des points sélectionnés
      write.csv(selected_point_volcano(), file, row.names = FALSE)
    }
  )
  
  # version des packages utilisés
  get_package_versions <- function() {
    pkgs <- c(
      "DT",
      "data.table",
      "fresh",
      "plotly",
      "shiny",
      "shinyBS",
      "shinyWidgets",
      "shinydashboard",
      "shinydashboardPlus",
      "waiter"
    )
    versions <- sapply(pkgs, function(p) as.character(packageVersion(p)))
    data.frame(Package = pkgs, Version = versions, row.names = NULL)
  }
  
  # Affiche les informations sur l'application
  observeEvent(input$info_btn, {
    showModal(
      modalDialog(
        title = "À propos de VIPE-R",
        HTML(
          "<p><b>Auteur :</b> Léa Cornaille</p>
         <p><b>Email :</b> lea.cornaille@hotmail.com</p>
         <p><b>Affiliation :</b> Université de Rouen</p>
         <p><b>Projet :</b> Analyse d'enrichissement fonctionnel</p>
         <p><b>Date :</b> 11-2025</p>
         <p><b>Version de VIPE-R :</b> 0.2 </p>"
        ),
        DT::renderDataTable({
          datatable(get_package_versions(), options = list(dom='t', paging=FALSE))
        }),
        easyClose = TRUE,
        footer = modalButton("Fermer")
      )
    )
  })
  
  
  genes_filtered_type <- reactive({
    df <- filtered_genes_display()
    req(df)
    
    if(input$reg_type == "overexpress"){
      df <- df[df$Regulation == "Up", ]
    } else if(input$reg_type == "underexpress"){
      df <- df[df$Regulation == "Down", ]
    }
    df
  })
  
  
  enrich_res <- eventReactive(input$runGO, {
    df <- genes_filtered_type()
    
    validate(
      need(nrow(df) > 0, "Aucun gène ne passe les filtres !")
    )
    
    # Liste de gènes ENSEMBL (important !)
    gene_list <- df$ID  # adapter selon le nom de colonne
    
    OrgDb_selected <- switch(input$select,
                             "humain" = org.Hs.eg.db,
                             "souris" = org.Mm.eg.db)
    
    enrichGO(
      gene          = gene_list,
      OrgDb         = OrgDb_selected,
      keyType       = "ENSEMBL",
      ont           = input$ont,
      pAdjustMethod = "BH",
      pvalueCutoff  = 0.05,
      qvalueCutoff  = 0.2
    )
  })
  
  # ---- cnetplot ----
  output$go_plot1 <- renderPlot({
    req(enrich_res())
    
    if(input$select_graph1 =="ridgeplot"){
      ridgeplot(enrich_res(), showCategory = 10)
    } else if(input$select_graph1 =="dotplot"){
      dotplot(enrich_res())
    } else if (input$select_graph1 =="cnetplot"){
      cnetplot(enrich_res(), showCategory = 10)
    }
  })
  
  output$go_plot2<- renderPlot({
    req(enrich_res())
    if(input$select_graph2 =="ridgeplot"){
      ridgeplot(enrich_res(), showCategory = 10)
    } else if(input$select_graph2 =="dotplot"){
      dotplot(enrich_res())
    } else if (input$select_graph2 =="cnetplot"){
      cnetplot(enrich_res(), showCategory = 10)
    }
    
    
    
  })
  
  
  
  
  
  
}