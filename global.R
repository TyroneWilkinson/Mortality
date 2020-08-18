library(dplyr)

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
  usa.state <- strsplit(paths, "_")[[1]][8]
  usa.state <- ToTitle(usa.state)
  temp.df <- read.csv(paths, header = TRUE)
  temp.df$state_name <- usa.state
  return(temp.df)
}

setwd('./NYCDSA/R/ShinyProject')
files = list.files(path = "./data/", pattern = "*.CSV")
filepaths <- paste0( './data/', files, sep = '' )
myfiles = do.call(rbind, lapply(filepaths, FilesReader))

# Save data frame
saveRDS(myfiles, file = './myfiles/myfiles.RDS')


### CLEAN DATA ###
# Rename year_id to year
myfiles <- myfiles %>% rename(year = year_id)

# Reorder and get rid of excess columns
# Remove: location_id, FIPS, cause_id, and sex_id (for now)
myfiles <- myfiles[c(12, 2, 5, 7:11)]

# test <- myfiles %>% filter(state_name == location_name) %>% transmute(state_name, location_name) #

# Remove entries that apply to the whole state
myfiles <- myfiles %>%  filter(!(state_name == location_name))

# Remove entries that apply to both genders
myfiles <- myfiles %>%  filter(!(sex == "Both"))