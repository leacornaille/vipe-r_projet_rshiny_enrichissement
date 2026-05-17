#----------------------------------------------------------------
# auteur: Léa Cornaille, Christine Lin, Julien Chevreau, Miquel Moli Gonzalez
# mail: lea.cornaille@hotmail.com
# Affiliation: Université de Rouen
# Date: 10-2025

# Description: Ce script permet de créer une interface en Rshiny. 
# Il centralise les différents modules de l'application et gère les interactions entre eux.
# Il contient notamment la lecture du fichier de données, le filtrage des gènes en fonction des seuils de log2FC et p-value,
# ainsi que la gestion de l'affichage des résultats et des graphiques.
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
    
    if (nrow(df_deg) == 0) {
      showModal(modalDialog(title = "Fichier vide",
                            "Le fichier chargé ne contient aucune ligne de données.",
                            easyClose = TRUE, footer = modalButton("Fermer")))
      return(NULL)
    }
    
    # Fonction pour récupérer les ENTREZ ID à partir des GeneSymbol
    retrieve_entrezID <- function(df_deg){
      req(df_deg, OrgDb_selected())
      df_deg$ENTREZID <- mapIds(x=OrgDb_selected(), keys=df_deg$GeneName, column="ENTREZID", 
                                  keytype = "SYMBOL", multiVals = "first") # 1er match retourné si plusieurs
      df_deg$ENTREZID[is.na(df_deg$ENTREZID)] = "Not found"
      return(df_deg)
    }
    
    # Conversion en numérique des colonnes critiques
    df_deg <- retrieve_entrezID(df_deg)
    df_deg$log2FC <- as.numeric(df_deg$log2FC)
    df_deg$padj <- as.numeric(df_deg$padj)
    df_deg$pval <- as.numeric(df_deg$pval)
    # Réordonner les colonnes
    df_deg <- df_deg[,c("GeneName", "ID", "ENTREZID", "log2FC", "pval", "padj")]
    
    pct_found <- mean(df_deg$ENTREZID != "Not found") * 100
    if (pct_found < 20) {
      showNotification(paste0("Seulement ", round(pct_found), "% des gènes ont été mappés à un ENTREZID. 
    Vérifiez que l'organisme sélectionné est correct."), type = "warning", duration = 10)
    }
    return(df_deg)
  })
  
  # gènes filtrés en fonction des sliders 
  filtered_genes <- reactive({
    req(deg_data(), input$slider_pval, input$slider_fc)

    # Conversion en data.frame pour éviter les problèmes avec data.table
    df_deg <- as.data.frame(deg_data())
    
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
    
    # Dans filtered_genes(), à la fin :
    if (nrow(df_filtered) == 0) {
      showNotification("Aucun gène ne passe les seuils actuels. Essayez d'assouplir log2FC ou p-value.", 
                       type = "warning", duration = 6)
    }
    
    # Retourner le data.frame filtré
    df_filtered
  })
  
  # les gènes à afficher selon les case cochées (up et down)
  filtered_genes_display <- reactive({
    req(filtered_genes())
    filtered_genes <- filtered_genes()
    
    # Si aucune case n'est cochée: tableau vide
    if (is.null(input$regulation_choice) || length(input$regulation_choice) == 0) {
      return(filtered_genes[0, ])  # renvoie un data.frame vide
    }
    
    # Filtrage selon Up / Down sélectionnés
    filtered_genes[filtered_genes$Regulation %in% input$regulation_choice, ]
  })
  
  # nombre de gènes filtrés
  output$nb_filtered_genes_box <- renderValueBox({
    req(filtered_genes())
    filtered_genes <- filtered_genes()
    # somme des gènes up et/ou down 
    n_up <- sum(filtered_genes$Regulation == "Up", na.rm = TRUE)
    n_down <- sum(filtered_genes$Regulation == "Down", na.rm = TRUE)
    n_total <- nrow(filtered_genes)
    
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
    req(deg_data())
    deg_data <- deg_data()
    log2fc_vals <- as.numeric(deg_data$log2FC)
    log2fc_vals <- log2fc_vals[!is.na(log2fc_vals)]
    sliderInput("slider_fc", "Log2FC", min = 0, max = round(max(abs(log2fc_vals)), 2), value = 0.5)
  })
  
  # slider en fonction de la p-value
  output$slider_pval <- renderUI({ 
    req(deg_data())
    sliderInput("slider_pval", "P-value ajustée", min=0, max=1, value=0.1) 
  })
  
  ### volcano plot
  volcano_plot("volcano_plot_module", deg_data = deg_data,
              pval_threshold = reactive(input$slider_pval),
              fc_threshold = reactive(input$slider_fc),
              reset_all = reactive(input$reset_all))
  
  # permet le téléchargement du tableau filtré (up ou down ou les deux)
  output$downloadData <- downloadHandler(
    filename = function() { "filtered_genes.csv" },
    content = function(file) {
      req(filtered_genes())                  
      write.csv(filtered_genes_display(), file, row.names = FALSE)
    }
  )
  
  # version des packages utilisés
  get_package_versions <- function() {
    versions <- sapply(list_packages, function(p) as.character(packageVersion(p)))
    data.frame(Package = list_packages, Version = versions, row.names = NULL)
  }
  
  # Affiche les informations sur l'application
  observeEvent(input$info_btn, {
    showModal(
      modalDialog(
        title = "À propos de VIPE-R",
        HTML(
          "<p><b>Auteurs :</b> Julien Chevreau, Léa Cornaille, Christine Lin, Miquel Moli</p>
         <p><b>Email :</b> lea.cornaille@hotmail.com</p>
         <p><b>Affiliation :</b> Université de Rouen</p>
         <p><b>Projet :</b> Analyse d'enrichissement fonctionnel</p>
         <p><b>Date :</b> 05-2026</p>
         <p><b>Version de VIPE-R :</b> 1.0 </p>"
        ),
        DT::renderDataTable({
          datatable(get_package_versions(), options = list(dom='t', paging=FALSE))
        }),
        easyClose = TRUE,
        footer = modalButton("Fermer")
      )
    )
  })
  
  
  # Sélection de la base de données OrgDb en fonction de l'espèce choisie
  OrgDb_selected <- reactive({
    switch(input$select,
           "humain" = org.Hs.eg.db,
           "souris" = org.Mm.eg.db)
  })
  
  go_ora_res <- go_ora_plot("ora_go_module",
                            deg_data = deg_data,
                            filtered_genes = filtered_genes,
                            OrgDb_selected = OrgDb_selected,
                            pval_threshold = reactive(input$slider_pval),
                            fc_threshold = reactive(input$slider_fc))
  
  go_gsea_res <- go_gsea_plot("gsea_go_module",
                              deg_data = deg_data,
                              OrgDb_selected = OrgDb_selected)
  
  path_ora_res <- path_ora_server("ora_path_module",
                                  deg_data = deg_data,
                                  filtered_genes = filtered_genes,
                                  OrgDb_selected = OrgDb_selected,
                                  pval_threshold = reactive(input$slider_pval),
                                  fc_threshold = reactive(input$slider_fc))
  
  path_gsea_res <- path_gsea_server("gsea_path_module", 
                                   deg_data = deg_data, 
                                   OrgDb_selected = OrgDb_selected
                                   )
  
  recap_server("recap_module",
               go_ora_module = go_ora_res,
               go_gsea_module = go_gsea_res,
               path_ora_module = path_ora_res,
               path_gsea_module = path_gsea_res)
}