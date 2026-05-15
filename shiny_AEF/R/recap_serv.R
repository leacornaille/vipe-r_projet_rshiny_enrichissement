# ------------------------------------------------------------------------------
# recap_serv.R
# Module serveur — Manhattan plot style g:Profiler
#
# Un reactiveVal `accumulated_results` stocke une LISTE NOMMÉE par label.
# Chaque fois qu'un module enfant lance un nouveau run (son eventReactive se
# déclenche), un observeEvent le détecte et met à jour l'entrée correspondante.
# Deux runs avec le même label : remplacement (ex : deux BP consécutifs).
# Deux labels différent : coexistence dans le Manhattan plot (ex : BP + MF).
# 
# Chaque module d'enrichissement renvoie :
#   list(enrich_res = <eventReactive>, source_label = <reactive character>)
# -----------------------------------------------------------------------------

recap_server <- function(id,
                         go_ora_module = NULL,
                         go_gsea_module = NULL,
                         path_ora_module = NULL,
                         path_gsea_module = NULL) {
  
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # ------ Palette couleur par label exact -----------------------------------
    source_palette <- c(
      "GO ORA (BP)" = "#1b4332",
      "GO ORA (MF)" = "#0F6E56",
      "GO ORA (CC)" = "#1D9E75",
      "GO GSEA (BP)" = "#0077b6",
      "GO GSEA (MF)" = "#023e8a",
      "GO GSEA (CC)" = "#03045e",
      "Pathway ORA (KEGG)" = "#a4133c",
      "Pathway ORA (Reactome)" = "#c9184a",
      "Pathway GSEA (KEGG)" = "#ffba08",
      "Pathway GSEA (Reactome)" = "#e85d04"
    )
    
    # permet de récupérer la bonne couleur qui correspond au label 
    # met gris sinon
    get_color <- function(label) {
      col <- source_palette[label]
      if (is.na(col)) "#888888" else unname(col)
    }
    
    # --- Modules utilisés --------------------------------------------------------- 
    # is_gsea permet de récupérer les bons champs dans le résultat
    mod_list <- list(
      list(mod = go_ora_module, is_gsea = FALSE),
      list(mod = go_gsea_module, is_gsea = TRUE),
      list(mod = path_ora_module, is_gsea = FALSE),
      list(mod = path_gsea_module, is_gsea = TRUE)
    )
    
    # --- Extraction d'un résultat en data.frame -------------------------------
    extract_df <- function(res, label, is_gsea) {
      tryCatch({
        # si res null ou label null alors rien
        if (is.null(res) || is.null(label)) return(NULL)
        
        # on met sous forme de data frame
        df <- as.data.frame(res)
        if (nrow(df) == 0) return(NULL)
        
        # création dataframe avec les champs communs à toutes les analyses
        out <- data.frame(
          ID = df$ID,
          Description = df$Description,
          p.adjust = df$p.adjust,
          source = label,
          stringsAsFactors = FALSE
        )
        
        # champs spécifique gsea
        if (is_gsea) {
          out$count <- df$setSize
          out$NES <- df$NES
          nes_abs <- abs(df$NES)
          r_min <- min(nes_abs, na.rm = TRUE)
          r_max <- max(nes_abs, na.rm = TRUE)
          out$generatio <- if (r_max > r_min)
            (nes_abs - r_min) / (r_max - r_min)
          else rep(0.5, nrow(df))
          # champs spécifique ora
        } else {
          out$count <- df$Count
          out$NES <- NA_real_
          gr <- df$GeneRatio
          
          # on calcule le ratio en séparant les deux nombres et en faisant le rapport
          parts <- strsplit(gr, "/")
          out$generatio <- sapply(parts, function(x)
            as.numeric(x[1]) / as.numeric(x[2]))
        }
        # calcul du log10p avec un plancher pour éviter les -inf
        out$log10p <- -log10(pmax(out$p.adjust, 1e-300))
        out
      }, error = function(e) NULL)
    }
    
    # --- conserver tous les résultats lancés ----------------------------------
    # on utilise les label, list("GO ORA (BP)" = df1, "GO ORA (MF)" = df2, ...)
    accumulated_results <- reactiveVal(list())
    
    # Pour chaque module, observer les nouveaux runs et ajouter
    lapply(mod_list, function(entry) {
      mod <- entry$mod
      is_gsea <- entry$is_gsea
      if (is.null(mod)) return()
      
      # on teste si il y a bien res et label
      observeEvent(mod$enrich_res(), {
        res <- mod$enrich_res()
        label <- mod$source_label()
        
        df <- extract_df(res, label, is_gsea)
        if (is.null(df)) return()
        
        # Mise à jour de la liste : remplacement si même label, ajout sinon
        current <- accumulated_results()
        current[[label]] <- df
        accumulated_results(current)
        
        # Message qui apparait dans l'onglet en cours
        showNotification(
          paste0("Résultats ajoutés au recap : ", label," (", nrow(df), " termes)"),
          type = "message",
          duration = 4
        )
      }, ignoreNULL = TRUE, ignoreInit = FALSE)
    })
    
    # Agrégation pour le plot
    all_results <- reactive({
      acc <- accumulated_results()
      if (length(acc) == 0) return(NULL)
      # do.call permet de faire rbind sur tous les éléments de la liste
      do.call(rbind, acc)
    })
    
    # --- Checkboxes analyse disponibles --------------------------------------
    output$source_checkboxes <- renderUI({
      df <- all_results()
      if (is.null(df)) {
        return(helpText("Aucune analyse n'a encore été lancée."))
      }
      
      sources_dispo <- unique(df$source)
      
      choice_labels <- lapply(sources_dispo, function(src) {
        col <- get_color(src)
        num_term <- sum(df$source == src)
        tags$span(
          tags$span(style = paste0(
            "display:inline-block; width:10px; height:10px;",
            "border-radius:50%; background:", col,
            "; margin-right:6px; vertical-align:middle;"
          )),
          src,
          tags$span(paste0(" (", num_term, " termes)"),
          style = "color:#888; font-size:0.9em;")
        )
      })
      
      checkboxGroupInput(
        ns("selected_sources"),
        label = NULL,
        choiceNames = choice_labels,
        choiceValues = sources_dispo,
        selected = sources_dispo
      )
    })
    
    # --- Construction des données pour le plot --------------------------------
    plot_data <- eventReactive(input$build_plot, {
      df <- all_results()
      
      validate(need(!is.null(df),
                    "Lancez au moins une analyse."))
      
      sources_sel <- input$selected_sources
      validate(need(length(sources_sel) > 0,
                    "Sélectionnez au moins une source."))
      
      df <- df[df$source %in% sources_sel, ]
      
      # garder les top N par source
      df <- df %>%
        dplyr::group_by(source) %>%
        dplyr::slice_max(log10p, n = input$nbr_points, with_ties = FALSE) %>% # termes avec même padj GSEA GO
        dplyr::ungroup()
      
      raw_size <- switch(
        input$size_metric,
        "count" = df$count,
        "generatio" = df$generatio,
        "uniform" = rep(1, nrow(df))
      )
      
      raw_size[is.na(raw_size)] <- min(raw_size, na.rm = TRUE)
      s_min <- min(raw_size, na.rm = TRUE)
      s_max <- max(raw_size, na.rm = TRUE)
      
      df$pt_size <- if (s_max > s_min) {
        3 + 6 * (raw_size - s_min) / (s_max - s_min)
      } else {
        rep(5, nrow(df))
      }

      # identifiant pour plotly
      df$uid <- seq_len(nrow(df))
      df
    })
   
    output$manhattan_plot <- renderPlotly({
      df <- plot_data()
      
      df_labels <- df %>%
        dplyr::group_by(source) %>%
        dplyr::slice_max(log10p, n = input$n_labels) %>%
        dplyr::ungroup()
      
      p <- ggplot(df, aes(
        x = source,
        y = log10p,
        color = source,
        size = pt_size,
        key = uid,
        text = paste0(
          "<b>", Description, "</b><br>",
          "Source: ", source, "<br>",
          "-log10(p.adjust): ", round(log10p, 3), "<br>",
          "p.adjust: ", signif(p.adjust, 3), "<br>",
          "Genes: ", count,
          ifelse(!is.na(NES), paste0("<br>NES: ", round(NES, 3)), "")
        )
      )) +
        ggbeeswarm::geom_quasirandom(
          width = 0.3,
          alpha = 0.7
        ) +
        
        geom_text(
          data = df_labels,
          aes(label = Description),
          size = 3,
          vjust = -0.7,
          check_overlap = TRUE
        ) +
        
        geom_hline(yintercept = -log10(input$pval_threshold),
                   linetype = "dashed",
                   color = "grey50") +
        
        scale_color_manual(values = source_palette) +
        
        scale_size_continuous(range = c(2, 7), guide = "none") +
        
        labs(x = NULL, y = "-log10(p.adjust)") +
        
        theme_minimal() +
        theme(
          legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1)
        )
      
      ggplotly(p, tooltip = "text")
    })
  
    # --- Détail terme cliqué ----------------------------------------------
    output$selected_term_info <- renderUI({
      click <- event_data("plotly_click")
      if (is.null(click)) {
        return(p("Cliquez sur un point pour afficher les détails du terme.",
                 style = "color:#888; font-style:italic;"))
      }
      df  <- plot_data()
      idx <- which(df$uid == click$key)
      if (length(idx) == 0) return(NULL)
      row <- df[idx[1], ]
      tagList(
        tags$strong(row$Description), tags$br(),
        tags$span(paste("ID :", row$ID)), tags$br(),
        tags$span(paste("Source :", row$source)), tags$br(),
        tags$span(paste("p.adjust :",
                        formatC(row$p.adjust, format = "e", digits = 2))), tags$br(),
        tags$span(paste("\u2212log\u2081\u2080(p.adjust) :",
                        round(row$log10p, 3))), tags$br(),
        tags$span(paste("Gènes :", row$count)),
        if (!is.na(row$NES)) tags$span(paste(" | NES :", round(row$NES, 3)))
      )
    })
  })
}