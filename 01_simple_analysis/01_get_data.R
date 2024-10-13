#
# ------------ Mastering R: Best Practices and Essential Tools ------------ #
#
# This script downloads and save:
# - The boundaries of the municipality of La Orotava, in Tenerife
# - A satellite image of the bounding box of the municipality
# ------------------------------------------------------------------------ #

# 1. Load packages --------------------------------------------------------

library(giscoR)
library(mapview)
library(sf)
library(rsi)
library(terra)
library(tictoc)
library(tidyverse)

# 2. Get study area -------------------------------------------------------

## Set constants
sel_crs  <- "EPSG:25828"
sel_muni <- "Orotava, La"

## 2.1. Get Spain municipalities --------------

## Get Spain municipalities
tic()
spanish_muni_sf <- gisco_get_communes(
    country = "Spain",
    cache = TRUE,
    update_cache = TRUE
) |> 
    st_transform(sel_crs)
toc()

## Visualize
mapView(spanish_muni_sf)

## 2.2. Get Tenerife Island -------------------

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

## Visualize
mapview(tenerife_sf)

## 2.3. Get Tenerife municipalities ------------

## Filter municipalities intersecting Tenerife Island
tenerife_muni_sf <- st_filter(
    x = spanish_muni_sf,
    y = tenerife_sf
)

## Visualize
mapView(tenerife_muni_sf)

# 3. Download satellite image ---------------------------------------------

## 3.1. Select a municipality -----------------

## Filter municipality
selected_muni_sf <- tenerife_muni_sf |> 
    filter(
        NAME_LATN == sel_muni
    )

## Visualize
mapView(selected_muni_sf)

## 3.2. Get satellite image -------------------
# create a data folder
fs::dir_create("data/sentinel")

## Download Sentinel-2 image
# tic() # inizia il conteggio del tempo di elaborazione
# 
# sentinel_path <- get_sentinel2_imagery(
#     aoi             = selected_muni_sf,
#     start_date      = "2024-05-04",
#     end_date        = "2024-05-05",
#     output_filename = str_glue("data/sentinel/{selected_muni_sf$id}.tif")
# )
# toc() # termina il conteggio del tempo per l'elaborazione

# Visto che la funzione non funziona, la carico manualmente
sentinel_path <- "./data/sentinel/ES6538026.tif"

## Visualize
sentine_sr <- rast(sentinel_path)

(sentine_sr / 10000) |> 
    plotRGB(4, 3, 2, stretch = "lin")

plot(
    st_geometry(selected_muni_sf),
    add    = TRUE,
    border = "RED",
    lwd    = 2
)

# 4. Export ---------------------------------------------------------------

## Export municipality
write_sf(selected_muni_sf, "data/municipality.geojson")



