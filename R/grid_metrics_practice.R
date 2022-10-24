# ==============================================================================
#
# Grid metrics calculation
#
# ==============================================================================
#
# Author: Sean Reilly, sean.reilly66@gmail.com
#
# Created: 23 Oct 2022
#
# ===============================================================================

library(lidR)
library(terra)
library(tidyverse)
library(glue)

# ================================= User inputs ================================

# In R, assignment can be achieved with either <- or =. I prefer <- because I 
# it makes the code a bit easier to read but there is no functional difference
# if you prefer =. On windows, alt - is a keyboard shortcut for <- 

# For now, we'll work with a single las file and corresponding image. The file 
# extension for this needs to start in the working directory.

las_file_name <- 'data/neon_sample/lidar/JERC_003.laz'

imagery_file_name <- 'data/neon_sample/rgb/JERC_003.tif'

output_folder <- 'data/temp'


# ================== Prepare las and tif data for computation =================

# First thing is to read in the las file and take a look at it. For now, all we
# need are the xyz coordinates and the point classification so I'm going to use 
# select = 'c'. By default, lidR always reads in the coordinates and select can 
# be used to pick additional columns of information. In this case, I'm also asking
# for it to include the classification column which contains values that designate
# if the point is ground or not. There are additional classes which you can google
# if you are interested but for now we will need the ground points to be identified
# in order to height normalize the data Feel free to read in the data again without 
# select to see what other information is in the file

las <- readLAS(las_file_name, select = 'c')

# Once it's read in, you'll see it in the environment pane. Try clicking on it 
# and exploring how it's organized. See if you can find the DATA where the actual
# coordinate values are stored. We can see the first few rows of the data with 
# this command. You'll notice that by not assigning this to anything, it will 
# instead print the values to the console.

head(las@data)

# Let's plot it to see what it looks like. For this I am first going to use the
# function decimate_points to thin the point cloud. This reduces the computational
# load since loading the full thing can crash your computer pretty easily if you
# don't have a powerful machine. Depending on the power of your computer, you 
# can change the point density within random(). This will take a minute to load.
# You'll notice here that I'm using a pipe %>% to feed the output from one 
# function to the next. This is a part of the tidyverse which is a powerful set
# of packages for data manipulation. What the pipe does is takes the output from
# one function and feeds it to the next as the first argument. in R, by convention
# the first argument is almost always the data on which to operate so this can be a
# really useful tool to creating more readible code and avoid having to save
# every intermediate step in data manipulation. You can chain together as many 
# functions as you want with pipes.

decimate_points(las, random(10)) %>%
  plot()

# The first thing we need to do is to height normalize the data. This removes
# the terrain and isolates the canopy. We can use the default tin algorithm 
# which doesn't require any parameters. 

las <- normalize_height(las, tin())

# Let's see what that gets us

decimate_points(las, random(10)) %>%
  plot()

# Next let's read in the spectral raster data. We will need this to define the
# resolution for the grid metrics later on. 

spectral <- rast(imagery_file_name)

# Let's see what that gets us.

plot(spectral)


# ================== Function for canopy metrics calculation =================== 

# We want to extract max height, 95th percentile height, and 75th percentile 
# heights from the point cloud. We do this by creating a function that finds
# these values from a given vector of Z (height values). The lidR grid_metrics
# function we are going to use later requires these values be output as a list
# so after we have computed them we will wrap them in a list.
# I've put code for 75th percentile here but see if you can figure out the rest.
# remember, you can do ?quantile in the console to pull up the documentation

z_metrics <- function(z) {
  
  p75 <- quantile(z, probs = 0.75, na.rm = TRUE)
  
  #p95
  
  #p100
  
  output_metrics <- list(
    p75 = p75
  )
  
  return(output_metrics)
  
}


# ========================== Grid metric computation =========================== 

# Now we are ready to generate our height rasters. We are going to do this by
# applying the function we wrote to the lidar point cloud using pixel metrics
# We can use the spectral raster as the input resolution which will ensure that
# the new height raster and our spectral data align and have the same size. The
# function expects a single band raster so I am using [[1]] to index to the first
# band.


height_raster <- pixel_metrics(las, func = z_metrics(Z), res = spectral[[1]])

# let's see what that gets us

plot(height_raster)


# =========================== File name manipulation =========================== 

# Now that we know how to generate the rasters, we need to devise our file
# management strategy. This is what I was alluding to on Friday. The challenge
# is this: 
# 1) identify all of the lidar (.las) files we need to process
# 2) read in a single one
# 3) find the corresponding spectral .tif file and read it in as well
# 4) generate the height rasters
# 4) write the output to file with a new name that we can relate to the others

# This is a good coding problem that will get you working through more complicated
# string and data manipulations. In the neon_sample folder, you'll find two 
# subfolders, one with .laz (compressed form of .las) and one with .tif files
# First extract all of the file names from the folders. 
# Then create a for loop that iterates over the .laz file names. Within the loop,
# identify the matching spectral file name. Perform a manipulation to the 
# tif file name that appends _height to the filename (before the file extnesion)

# see how far you get with this and let me know if you get stuck. Some things
# you may find helfpul

# list.files()
# https://stringr.tidyverse.org/
# https://glue.tidyverse.org/
# str_detect()

# x = 5:10
# for (i in x) {
#   y = glue('current i: {i}')
#   print(y)
# }




  