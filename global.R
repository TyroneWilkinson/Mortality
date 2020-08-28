library(dplyr)
library(tidyr)
library(tigris)
options(tigris_use_cache = TRUE)
library(leaflet)
library(DT)
library(shiny)
library(shinydashboard)
library(sf)
# 
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
# # Reorder and get rid of excess columns
# # Remove: location_id, FIPS, cause_id, and sex_id (for now)
# # > names(myfiles)
# # [1] "location_id"   "location_name" "FIPS"          "cause_id"
# # [5] "cause_name"    "sex_id"        "sex"           "year"
# # [9] "mx"            "lower"         "upper"         "state_name"
# # Only keep: "state_name, "location_name", "FIPS", "cause_name", "sex", "year",
# # and "mx"
# myfiles <- myfiles[c(12, 2:3, 5, 7:9)]
# 
# # Only keep entries that apply to both genders then remove sex column
# myfiles <- myfiles %>%  filter(sex == "Both")
# myfiles$sex <- NULL
# 
# # Only keep entries in the year 2014 then remove that column
# myfiles <- myfiles %>% filter(year == 2014)
# myfiles$year <- NULL
# 
# # Remove entries that apply to the whole state
# myfiles <- myfiles %>%  filter(!(state_name == location_name))
# 
# # Transform data frame
# myfiles <-
#   myfiles %>%
#   pivot_wider(names_from = "cause_name", values_from = "mx") %>%
#   as.data.frame
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
# ###############################################################################
# # Leaflet Example:
# # popup <- paste0("State: ",
# #                  merged_df$state_name,
# #                  "<br>",
# #                  "County: ",
# #                  merged_df$location_name,
# #                  "<br>",
# #                  "All causes: ",
# #                  merged_df$`All causes`)
# #
# # pal <- colorNumeric(
# #   palette = "YlGnBu",
# #   domain = merged_df$`All causes`
# # )
# #
# # map2 <- leaflet() %>%
# #   addProviderTiles("Esri.WorldStreetMap") %>%  # "CartoDB.Positron"
# #   addPolygons(data = merged_df,
# #               color = "#b2aeae", # you need to use hex colors
# #               fillColor = ~pal(`All causes`),
# #               fillOpacity = 0.7,
# #               weight = 1,
# #               smoothFactor = 0.2,
# #               popup = popup) %>%
# #   addLegend(pal = pal,
# #             values = merged_df$`All causes`,
# #             position = "bottomright",
# #             title = "Mortality per 100,000 persons")
# 
# # Choices for sidebar menu (the causes of mortality)
merged_df <- readRDS(file = './data/merged_df.RDS')
choice <- colnames(merged_df)[3:27] %>% sort
