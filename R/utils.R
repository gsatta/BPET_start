


## FUNCTION: download Tenerife municipalities
get_tenerife_muni <- function(sel_crs = "EPSG:25828") {
    
    ## Get Spain municipalities
        spanish_muni_sf <- gisco_get_communes(
        country = "Spain",
        cache = TRUE,
        update_cache = TRUE
    ) |> 
        st_transform(sel_crs)
    
    ## Get Tenerife Island
    tenerife_sf <- gisco_get_nuts(
        country    = "Spain",
        resolution = "01",
        nuts_level = 3
    ) |> 
        filter(
            NAME_LATN == "Tenerife"
        ) |> 
        st_transform(sel_crs)  
    
    ## Filter municipalities intersecting Tenerife Island
    tenerife_muni_sf <- st_filter(
        x = spanish_muni_sf,
        y = tenerife_sf
    )
}
