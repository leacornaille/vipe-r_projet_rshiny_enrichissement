path_gsea_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2("Enrichissement (Pathway)"),
    h3("Méthode GSEA"),
    
    fluidRow(
      box(
        title = "Paramètres GSEA",
        solidHeader = TRUE,
        status = "primary",
        width = 12,
        
        fluidRow(
          box(
            title = "Classement des gènes",
            width = 3,
            status = "info",
            helpText("log2FC (recommandé) : classe les gènes par intensité de régulation. padj : classe par significativité statistique."),
            column(
              width = 12,
              radioButtons(
                ns("rank_type_gsea"),
                "Critère de classement :",
                choices  = c("log2FC" = "log2FC", "padj" = "padj"),
                selected = "log2FC"
              )
            )
          ),
          
          box(
            title  = "Paramètres statistiques GSEA",
            width  = 9,
            status = "primary",
            fluidRow(
              column(
                width = 4,
                selectInput(
                  ns("pathway_db"),
                  "Base de données Pathway",
                  choices  = c("KEGG" = "kegg", "Reactome" = "reactome"),
                  selected = "kegg"
                ),
                numericInput(
                  ns("nperm_go_gsea"),
                  "Nombre de permutations",
                  value = 1000,
                  step = 50.0
                )
                bsTooltip(ns("pathway_db"),
                          "KEGG : base généraliste, couvre métabolisme et signalisation. Reactome : plus détaillée, orientée voies humaines. Les deux sont complémentaires.",
                          placement = "bottom")
              ),
              column(
                width = 4,
                selectInput(
                  ns("padjust_method_path_gsea"),
                  "Méthode de correction multiple",
                  choices = c(
                    "Benjamini-Hochberg (FDR)" = "BH",
                    "Bonferroni" = "bonferroni",
                    "Holm" = "holm",
                    "Benjamini-Yekutieli" = "BY",
                    "Aucune" = "none"
                  ),
                  selected = "BH"
                )
              ),
              column(
                width = 4,
                numericInput(
                  ns("pval_path_gsea"), "Seuil p-value GSEA",
                  value = 0.05, min = 0, max = 1, step = 0.01
                ),
              )
            )
          ),
          
          fluidRow(
            column(12, align = "center",
                   actionButton(ns("runGSEA"), "Lancer GSEA",
                                icon = icon("play"), class = "btn-success")
            )
          )
        )
      )
    ),
    
    fluidRow(
      # ------ Visualisation --------------------------------------------------
      box(
        title = "Visualisation GSEA",
        width = 8,
        status = "primary",
        solidHeader = TRUE,
        collapsible = TRUE,
        
        selectInput(
          ns("select_graph_gsea_path"),
          "Type de graphique :",
          choices = c(
            "GSEA plot" = "gseaplot",
            "Dotplot" = "dotplot",
            "Emaplot" = "emapplot",
            "Ridgeplot" = "ridgeplot",
            "Cnetplot" = "cnetplot"
          )
        ),
        withSpinner(
          jqui_resizable(plotOutput(ns("gsea_path_plot")), options = list(handles = "se")),
          image = "loading.GIF"
        )
      ),
      
      # ---- Paramètres visuels ----
      box(
        title = "Paramètres visuels",
        width = 4,
        status = "warning",
        collapsible = TRUE,
        
        textInput(ns("plot_title_gsea_path"), "Titre du graphique",
                  value = "GSEA – Enrichissement Pathway"),
        
        sliderInput(ns("n_cat_path_gsea"), "Nombre de pathways affichés",
                    min = 1, max = 50, value = 20, step = 1),
        
        selectInput(
          ns("color_palette_path_gsea"),
          "Palette de couleurs",
          choices = c(
            "Viridis" = "viridis",
            "Plasma" = "plasma",
            "Magma" = "magma",
            "Inferno" = "inferno",
            "Bleu → Rouge" = "blue_red"
          ),
          selected = "viridis"
        )
      ),
      
      # ------ Pathview (KEGG) ------------------------------------------------
      conditionalPanel(
        condition = paste0("input['", ns("pathway_db"), "'] == 'kegg'"),
        box(
          title = "Pathview",
          width = 4,
          status = "primary",
          collapsible = TRUE,
          
          selectInput(ns("pathview_kegg_id_gsea"), "Voie métabolique", choices = NULL),
          
          actionButton(
            ns("run_pathview_gsea"),
            "Afficher la voie dans Pathview",
            icon  = icon("play"),
            width = "100%"
          )
        )
      ),
      
      # ---- Tableau ----
      box(
        title = "Table résultats GSEA",
        width = 12,
        status = "info",
        solidHeader = TRUE,
        collapsible = TRUE,
        downloadButton(ns("download_table_gsea_path"), "Télécharger le tableau (CSV)"),
        withSpinner(
          DT::dataTableOutput(ns("path_gsea_table_results")),
          image = "loading.GIF"
        )
      )
    )
  )
}