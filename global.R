# install.packages(c("dplyr", "tidyr","tigris","leaflet","DT","shiny","shinydashboard","sf","ggplot2","viridis"))
library(dplyr)
library(tidyr)
library(tigris)
options(tigris_use_cache = TRUE)
library(leaflet)
library(DT)
library(shiny)
library(shinydashboard)
library(sf)
library(ggplot2)
library(viridis)
################################################################################
# # STOP HERE AND GO TO LINE #209
# ##############################################################################
# ToTitle <- function(cvect) {
#   # Translates characters in character vectors from upper or lower case to
#   # title case.
#   #
#   # Args:
#   #   cvect: A character in a character vector whose case is to be changed.
#   #
#   # Returns:
#   #   The character vector in title case.
#   trans <- strsplit(cvect, " ")[[1]]
#   trans <- paste(toupper(substring(trans, 1,1)), tolower(substring(trans, 2)),
#         sep="", collapse=" ")
#   return(trans)
# }
# 
# FilesReader <- function(paths) {
#   # Reads in a .csv file given its file path and adds a column containing its
#   # corresponding state.
#   #
#   # Args:
#   #   paths: A character vector containing the file paths of the data I need.
#   #
#   # Returns:
#   #   The altered data frame that corresponds to the .csv file.
#   usa.state <- strsplit(paths, "_")
#   usa.state <- paste(usa.state[[1]][8],
#                      ifelse(grepl("Y2017", usa.state[[1]][9]), "",
#                             usa.state[[1]][9]),
#                      sep = " ")
#   usa.state <- ToTitle(usa.state)
#   temp.df <- read.csv(paths, header = TRUE)
#   temp.df$state_name <- usa.state
#   return(temp.df)
# }
# 
# ###############################################################################
# # Import Data
# # setwd('./NYCDSA/R/ShinyProject/Mortality')
# files <- list.files(path = "./data/", pattern = "*.CSV")
# filepaths <- paste0( './data/', files)
# myfiles <- do.call(rbind, lapply(filepaths, FilesReader))
# ###############################################################################
# ### CLEAN DATA ###
# # Isolate Country
# country.years <-
#   myfiles %>%
#   filter(state_name == "United States")
# 
# # Isolate States
# myfiles <-
#   myfiles %>%
#   filter(!(state_name == "United States" | state_name == "District Of"))
# 
# # State and County FIPS
# state.FIPS <-
#   myfiles %>%
#   filter(state_name == location_name) %>%
#   distinct(FIPS) %>%
#   arrange(FIPS)
# 
# # county.FIPS <-
# #   myfiles %>%
# #   distinct(FIPS) %>%
# #   arrange(FIPS)
# 
# # Rename year_id to year
# myfiles <-
#   myfiles %>%
#   rename(year = year_id)
# 
# country.years <-
#   country.years %>%
#   rename(year = year_id)
# 
# # Reorder and get rid of excess columns
# # Remove: location_id, FIPS, cause_id, and sex_id (for now)
# # > names(myfiles)
# # [1] "location_id"   "location_name" "FIPS"          "cause_id"
# # [5] "cause_name"    "sex_id"        "sex"           "year"
# # [9] "mx"            "lower"         "upper"         "state_name"
# # Only keep: "state_name, "location_name", "FIPS", "cause_name", "sex", "year",
# # and "mx"
# myfiles <- myfiles[c(12, 2:3, 5, 7:9)]
# country.years <- country.years[c(12, 2:3, 5, 7:9)]
# 
# # Only keep entries that apply to both genders then remove sex column
# myfiles <- myfiles %>%  filter(sex == "Both")
# myfiles$sex <- NULL
# 
# country.years <- country.years %>%  filter(sex == "Both")
# country.years$sex <- NULL
# 
# # Create a new df from "myfiles" to show data for all years at the state level
# # Delete extra column
# all.state.years <- myfiles %>%  filter(state_name == location_name)
# all.state.years$location_name <- NULL
# 
# # Only keep entries in the year 2014 then remove that column
# myfiles <- myfiles %>% filter(year == 2014)
# myfiles$year <- NULL
# 
# # Create a new df from "myfiles" to show data at the state level
# # Delete extra column
# states <- myfiles %>%  filter(state_name == location_name)
# states$location_name <- NULL
# 
# # Remove entries that apply to the whole state from main df
# myfiles <- myfiles %>%  filter(!(state_name == location_name))
# 
# # Clean up df corresponding to whole country
# country.years <- country.years[c(1,4:6)]
# country.years <-
#   country.years %>%
#   rename(country = state_name)
# 
# # Create a copy of df country.years
# og.country.years <- country.years
# 
# # Transform data frames
# all.state.years <-
#   all.state.years %>%
#   pivot_wider(names_from = "cause_name", values_from = "mx") %>%
#   as.data.frame
# 
# states <-
#   states %>%
#   pivot_wider(names_from = "cause_name", values_from = "mx") %>%
#   as.data.frame
# 
# myfiles <-
#   myfiles %>%
#   pivot_wider(names_from = "cause_name", values_from = "mx") %>%
#   as.data.frame
# 
# country.years <-
#   country.years %>%
#   pivot_wider(names_from = "cause_name", values_from = "mx") %>%
#   as.data.frame
# 
# # Order Causes
# # country.years <- cbind(country.years[,1:2],country.years[,3:27][,order(colnames(country.years[,3:27]))])
# # all.state.years <- cbind(all.state.years[,1:3],all.state.years[,4:28][,order(colnames(all.state.years[,4:28]))])
# # states <- cbind(states[,1:2],states[,3:27][,order(colnames(states[,3:27]))])
# myfiles <- cbind(myfiles[,1:2],myfiles[,3:28][,order(colnames(myfiles[,3:28]))])
# 
# ###############################################################################
# ### STEPS TO PREPARE MAP ###
# # Get the spatial data (tigris)
# all_counties <- counties(state = state.FIPS, cb = FALSE, year = 2014)
# 
# # Change GEOID column type to prepare for merge
# all_counties <- all_counties %>% transform(GEOID = as.numeric(GEOID))
# 
# # Exclude tracts with no land
# all_counties <- all_counties[all_counties$ALAND>0,]
# 
# # Merge spatial data with mortality data
# merged_df <- geo_join(all_counties, myfiles, "GEOID", "FIPS", how = "inner")
# 
# # Only keep geometry column from the data from the spatial dataframe
# merged_df <- merged_df %>% select(c(18:45))
# 
# # Create column with state and country
# merged_df <- merged_df %>% mutate(loc = paste(location_name, state_name, sep=', '))
# ###############################################################################
# Leaflet Example:
# popup <- paste0("State: ",
#                  merged_df$state_name,
#                  "<br>",
#                  "County: ",
#                  merged_df$location_name,
#                  "<br>",
#                  "All causes: ",
#                  merged_df$`All causes`)
#
# pal <- colorNumeric(
#   palette = "YlGnBu",
#   domain = merged_df$`All causes`
# )
#
# map2 <- leaflet() %>%
#   addProviderTiles("Esri.WorldStreetMap") %>%  # "CartoDB.Positron"
#   addPolygons(data = merged_df,
#               color = "#b2aeae", # you need to use hex colors
#               fillColor = ~pal(`All causes`),
#               fillOpacity = 0.7,
#               weight = 1,
#               smoothFactor = 0.2,
#               popup = popup) %>%
#   addLegend(pal = pal,
#             values = merged_df$`All causes`,
#             position = "bottomright",
#             title = "Mortality per 100,000 persons")
# ###############################################################################
# # START HERE; UNCOMMENT BELOW
# ###############################################################################
# SAVE AND RESTORE DATA
#saveRDS(merged_df, file = './data/merged_df.RDS')
#saveRDS(states, file = './data/states.RDS')
#saveRDS(all.state.years, file = './data/allstateyears.RDS')
#saveRDS(country.years, file = './data/countryyears.RDS')
#saveRDS(og.country.years, file = './data/ogcountryyears.RDS')

merged_df <- readRDS(file = './data/merged_df.RDS')
states <- readRDS(file = './data/states.RDS')
all.state.years <- readRDS(file = './data/allstateyears.RDS')
country.years <- readRDS(file = './data/countryyears.RDS')
og.country.years <- readRDS(file = './data/ogcountryyears.RDS')
###############################################################################
# Choices for sidebar menu (the causes of mortality)
choice <- colnames(merged_df)[3:27] %>% sort
################################################################################
## R functions
## add in methods from https://github.com/rstudio/leaflet/pull/598
setCircleMarkerRadius <- function(map, layerId, radius, data=getMapData(map)){
  options <- list(layerId = layerId, radius = radius)
  # evaluate all options
  options <- evalFormula(options, data = data)
  # make them the same length (by building a data.frame)
  options <- do.call(data.frame, c(options, list(stringsAsFactors=FALSE)))
  leaflet::invokeMethod(map, data, "setRadius", options$layerId, options$radius)
}

setCircleMarkerStyle <- function(map, layerId
                                 , radius = NULL
                                 , stroke = NULL
                                 , color = NULL
                                 , weight = NULL
                                 , opacity = NULL
                                 , fill = NULL
                                 , fillColor = NULL
                                 , fillOpacity = NULL
                                 , dashArray = NULL
                                 , options = NULL
                                 , data = getMapData(map)
){
  if (!is.null(radius)){
    setCircleMarkerRadius(map, layerId = layerId, radius = radius, data = data)
  }

  options <- c(list(layerId = layerId),
               options,
               filterNULL(list(stroke = stroke, color = color,
                               weight = weight, opacity = opacity,
                               fill = fill, fillColor = fillColor,
                               fillOpacity = fillOpacity, dashArray = dashArray
               )))

  if (length(options) < 2) { # no style options set
    return()
  }
  # evaluate all options
  options <- evalFormula(options, data = data)

  # make them the same length (by building a data.frame)
  options <- do.call(data.frame, c(options, list(stringsAsFactors=FALSE)))
  layerId <- options[[1]]
  style <- options[-1] # drop layer column

  #print(list(style=style))
  leaflet::invokeMethod(map, data, "setStyle", "marker", layerId, style);
}

setShapeStyle <- function( map, data = getMapData(map), layerId,
                           stroke = NULL, color = NULL,
                           weight = NULL, opacity = NULL,
                           fill = NULL, fillColor = NULL,
                           fillOpacity = NULL, dashArray = NULL,
                           smoothFactor = NULL, noClip = NULL,
                           options = NULL
){
  options <- c(list(layerId = layerId),
               options,
               filterNULL(list(stroke = stroke, color = color,
                               weight = weight, opacity = opacity,
                               fill = fill, fillColor = fillColor,
                               fillOpacity = fillOpacity, dashArray = dashArray,
                               smoothFactor = smoothFactor, noClip = noClip
               )))
  # evaluate all options
  options <- evalFormula(options, data = data)
  # make them the same length (by building a data.frame)
  options <- do.call(data.frame, c(options, list(stringsAsFactors=FALSE)))

  layerId <- options[[1]]
  style <- options[-1] # drop layer column

  #print(list(style=style))
  leaflet::invokeMethod(map, data, "setStyle", "shape", layerId, style);
}

### JS methods
leafletjs <-  tags$head(
  # add in methods from https://github.com/rstudio/leaflet/pull/598
  tags$script(HTML(
    '
window.LeafletWidget.methods.setStyle = function(category, layerId, style){
  var map = this;
  if (!layerId){
    return;
  } else if (!(typeof(layerId) === "object" && layerId.length)){ // in case a single layerid is given
    layerId = [layerId];
  }

  //convert columnstore to row store
  style = HTMLWidgets.dataframeToD3(style);
  //console.log(style);
  layerId.forEach(function(d,i){
    var layer = map.layerManager.getLayer(category, d);
    if (layer){ // or should this raise an error?
      layer.setStyle(style[i]);
    }
  });
};

window.LeafletWidget.methods.setRadius = function(layerId, radius){
  var map = this;
  if (!layerId){
    return;
  } else if (!(typeof(layerId) === "object" && layerId.length)){ // in case a single layerid is given
    layerId = [layerId];
    radius = [radius];
  }

  layerId.forEach(function(d,i){
    var layer = map.layerManager.getLayer("marker", d);
    if (layer){ // or should this raise an error?
      layer.setRadius(radius[i]);
    }
  });
};
'
  ))
)
