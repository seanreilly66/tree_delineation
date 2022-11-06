# ==============================================================================
#
# Structural raster generation
#
# ==============================================================================
#
# Author: Sean Reilly, sean.reilly66@gmail.com
#
# Created: 23 Oct 2022
#
# ==============================================================================

library(lidR)
library(terra)
library(tidyverse)
library(glue)

# ================================= User inputs ================================


las_file <- 'data/neon_sample/lidar/JERC_003.laz'
imagery_file <- 'data/neon_sample/rgb/JERC_003.tif'

output_folder <- 'data/temp'


# ================================ Read in data ================================ 

las <- readLAS(las_file, select = 'cr') %>%
  normalize_height(tin())

spectral <- rast(imagery_file, lyrs = 1)


# =============================== CHM generation =============================== 

p2r <- rasterize_canopy(las, res = 0.1, p2r(0.2, na.fill = tin()))
dsmtin <- rasterize_canopy(las, res = 0.1, dsmtin())
pitfree <- rasterize_canopy(las, res = 0.1, pitfree())

layers <- c(p2r, dsmtin, pitfree)
names(layers) <- c("p2r", "dsmtin", "pitfree")
plot(layers)

# ==============================================================================