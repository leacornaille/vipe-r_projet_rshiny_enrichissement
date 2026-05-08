non_null_entrezID <- function(deg_data){
  genes = genes[genes$entrezID != "Not Found",]
}

# Gene mapping to perform ORA and GSEA on EntrezID
map_genes <- function(deg_data, OrgDb_selected){
  validate(need(nrow(deg_data) > 0, "Aucun gène ne passe les filtres !"))

  # ---- Mapping ENSEMBL -> ENTREZID ----
  mapped <- bitr(
    deg_data$ID,
    fromType = "ENSEMBL",
    toType = "ENTREZID",
    OrgDb = OrgDb_selected
  )
  
  if (nrow(mapped) == 0) {
    showNotification("Aucun gène mappé à l'OrgDb !", type = "error")
    return(NULL)
  }
  
  # Merge avant ranking
  deg_data <- merge(deg_data, mapped, by.x = "ID", by.y = "ENSEMBL")
  return(deg_data)
}

# création d'un vecteur nommé pour GSEA
build_geneList <- function(deg_data, rank_type){
    # req(deg_data)
    # deg_data <- deg_data()
    
    # Enlever les gènes pour lesquels les ENTREZID sont "Not found"
    deg_data <- deg_data[deg_data$ENTREZID != "Not found",]
    
    # Tri décroissant comme attendu par GSEA
    gene_list <- deg_data[[rank_type]]
    names(gene_list) <- deg_data$ENTREZID
    gene_list <- sort(gene_list, decreasing = TRUE)
    
    return(gene_list)
}

organism_reactome <- function(OrgDb_selected){
  req(OrgDb_selected())
  if (identical(OrgDb_selected(), org.Mm.eg.db)) "mouse"
  else if (identical(OrgDb_selected(), org.Hs.eg.db)) "human"
  else NULL
}

organism_kegg <- function(OrgDb_selected){
  req(OrgDb_selected())
  if (identical(OrgDb_selected(), org.Mm.eg.db)) "mmu"
  else if (identical(OrgDb_selected(), org.Hs.eg.db)) "hsa"
  else NULL
}

# Palettes de couleurs pour laisser le choix à l'utilisateur
color_palette <- function(palette) {
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
  
  