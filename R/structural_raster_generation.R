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
chm_file <- 'data/neon_sample/chm/JERC_003_chm.tif'

output_folder <- 'data/temp'

# ================================ Read in data ================================ 

las <- readLAS(las_file, select = 'cr') %>%
  normalize_height(tin())

spec <- rast(imagery_file, lyrs = 1)

chm <- rast(chm_file)

# =============================== CHM generation =============================== 

# Testing chm algorithms
p2r <- rasterize_canopy(las, res = spec, p2r(0.2, na.fill = tin()))
dsmtin <- rasterize_canopy(las, res = spec, dsmtin())
pitfree <- rasterize_canopy(las, res = spec, pitfree())

layers <- c(p2r, dsmtin, pitfree)
names(layers) <- c("p2r", "dsmtin", "pitfree")
plot(layers, col = height.colors(50))

# testing p2r tin 
p2r_na <- rasterize_canopy(las, res = spec, p2r())
tin_0 <- rasterize_canopy(las, res = spec, p2r(na.fill = tin()))
tin_1 <- rasterize_canopy(las, res = spec, p2r(0.1, na.fill = tin()))
tin_2 <- rasterize_canopy(las, res = spec, p2r(0.2, na.fill = tin()))
tin_3 <- rasterize_canopy(las, res = spec, p2r(0.3, na.fill = tin()))
tin_4 <- rasterize_canopy(las, res = spec, p2r(0.4, na.fill = tin()))

layers <- c(p2r_na, tin_0, tin_1, tin_2, tin_3, tin_4)
names(layers) <- c('na', 'tin_0','tin_1', 'tin_2', 'tin_3', 'tin_4')
plot(layers, col = height.colors(50))

# testing p2r knn idw
knn_0 <- rasterize_canopy(las, res = spec, p2r(na.fill = knnidw()))
knn_1 <- rasterize_canopy(las, res = spec, p2r(0.1, na.fill = knnidw()))
knn_2 <- rasterize_canopy(las, res = spec, p2r(0.2, na.fill = knnidw()))
knn_3 <- rasterize_canopy(las, res = spec, p2r(0.3, na.fill = knnidw()))
knn_4 <- rasterize_canopy(las, res = spec, p2r(0.4, na.fill = knnidw()))

layers <- c(p2r_na, tin_0, tin_1, tin_2, tin_3, tin_4)
names(layers) <- c('na', 'tin_0','tin_1', 'tin_2', 'tin_3', 'tin_4')
plot(layers, col = height.colors(50))

# ==============================================================================