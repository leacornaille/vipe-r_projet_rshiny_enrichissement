# création d'un vecteur nommé pour GSEA
build_gene_list <- function(deg_data, rank_type){
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

# Palettes de couleurs pour laisser le choix à l'utilisateur
color_palette <- function(palette) {
  list(
    switch(palette,
           "viridis" = scale_fill_viridis_c(option = "D"),
           "plasma" = scale_fill_viridis_c(option = "plasma"),
           "magma" = scale_fill_viridis_c(option = "magma"),
           "inferno" = scale_fill_viridis_c(option = "inferno"),
           "mako" = scale_fill_viridis_c(option = "mako"),
           "rocket" = scale_fill_viridis_c(option = "rocket"),
           "cividis" = scale_fill_viridis_c(option = "cividis"),
           "turbo" = scale_fill_viridis_c(option = "turbo"),
           "YlOrRd" = scale_fill_distiller(palette = "YlOrRd", direction = 1),
           "blue_red" = scale_fill_gradient(low = "blue", high = "red"),
           "green_orange" = scale_fill_gradient(low = "limegreen", high = "darkorange2")
    ),
    switch(palette,
           "viridis" = scale_color_viridis_c(option = "D"),
           "plasma" = scale_color_viridis_c(option = "plasma"),
           "magma" = scale_color_viridis_c(option = "magma"),
           "inferno" = scale_color_viridis_c(option = "inferno"),
           "mako"  = scale_color_viridis_c(option = "mako"),
           "rocket" = scale_color_viridis_c(option = "rocket"),
           "cividis" = scale_color_viridis_c(option = "cividis"),
           "turbo" = scale_color_viridis_c(option = "turbo"),
           "YlOrRd" = scale_color_distiller(palette = "YlOrRd", direction = 1),
           "blue_red" = scale_color_gradient(low = "blue", high = "red"),
           "green_orange" = scale_color_gradient(low = "limegreen", high = "darkorange2")
    )
  )
}
  
  