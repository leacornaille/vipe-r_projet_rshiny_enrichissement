filter_deg_data = function(deg_data){
  genes = genes[genes$entrezID != "Not Found",]
  
}












color_scales <- function(palette) {
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
  
  