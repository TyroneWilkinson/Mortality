library(dplyr)
library(tigris)
options(tigris_use_cache = TRUE)
library(leaflet)


ToTitle <- function(cvect) {
  # Translates characters in character vectors from upper or lower case to 
  # title case.
  #
  # Args:
  #   cvect: A character in a character vector whose case is to be changed.
  #
  # Returns:
  #   The character vector in title case.
  trans <- strsplit(cvect, " ")[[1]]
  trans <- paste(toupper(substring(trans, 1,1)), tolower(substring(trans, 2)),
        sep="", collapse=" ")
  return(trans)
}

FilesReader <- function(paths) {
  # Reads in a .csv file given its file path and adds a column containing its
  # corresponding state.
  #
  # Args:
  #   paths: A character vector containing the file paths of the data I need.
  #
  # Returns:
  #   The altered data frame that corresponds to the .csv file.
  usa.state <- strsplit(paths, "_")
  usa.state <- paste(usa.state[[1]][8], 
                     ifelse(grepl("Y2017", usa.state[[1]][9]), "", 
                            usa.state[[1]][9]), 
                     sep = " ")
  usa.state <- ToTitle(usa.state)
  temp.df <- read.csv(paths, header = TRUE)
  temp.df$state_name <- usa.state
  return(temp.df)
}
#getwd()
setwd('./NYCDSA/R/ShinyProject/Mortality')
# files = list.files(path = "./data/", pattern = "*.CSV")
# filepaths <- paste0( './data/', files)
# myfiles = do.call(rbind, lapply(filepaths, FilesReader))

# Save/Export data frame
# saveRDS(myfiles, file = './myfiles/myfiles.RDS')
# write.csv(myfiles, file = './myfiles/myfiles.CSV', row.names = FALSE, col.names = TRUE)
###################################################################################################

# Import Data Frame
# myfiles <- readRDS(file = './myfiles/myfiles.RDS')
# myfiles <- read.csv(file = './myfiles/myfiles.CSV', header = TRUE)

###################################################################################################
### CLEAN DATA ###
# Isolate States
myfiles2 <- myfiles %>% 
  filter(!(state_name == "United States" | state_name == "District Of"))

# State and County FIPS
state.FIPS <- myfiles2 %>% filter(state_name == location_name) %>% distinct(FIPS) %>% arrange(FIPS)
county.FIPS <- myfiles2 %>% distinct(FIPS) %>% arrange(FIPS)

# Rename year_id to year
myfiles2 <- myfiles2 %>% rename(year = year_id)

# # Reorder and get rid of excess columns
# # Remove: location_id, FIPS, cause_id, and sex_id (for now)
#
# > names(myfiles2)
# [1] "location_id"   "location_name" "FIPS"          "cause_id"      "cause_name"    "sex_id"        "sex"           "year"         
# [9] "mx"            "lower"         "upper"         "state_name"   
#
# Only keep: "state_name, "location_name", "FIPS", "cause_id" , "cause_name", "sex", "year", and "mx"
myfiles2 <- myfiles2[c(12, 2:5, 7:9)]

# Remove entries that apply to both genders
myfiles2 <- myfiles2 %>%  filter(!(sex == "Both"))




saveRDS(myfiles2, file = './myfiles/myfiles2.RDS')


setwd('./NYCDSA/R/ShinyProject/Mortality')
myfiles2 <- readRDS(file = './myfiles/myfiles2.RDS')
# # test <- myfiles %>% filter(state_name == location_name) %>% transmute(state_name, location_name) #
# 
# # Remove entries that apply to the whole state
# myfiles <- myfiles %>%  filter(!(state_name == location_name))
# 

# 
# write.csv(myfiles2, file = './myfiles/myfiles2.CSV', row.names = F, col.names = T)



#TEST
myfiles3 <- myfiles2 %>% filter(year == 2014)
choice <- myfiles3 %>% distinct(cause_name)


myfiles3
