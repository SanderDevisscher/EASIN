
# provide the path of the file containing the tokenfile
tokenfile <- "~/Documents/temp/token_invasive.txt"
token <- readChar(tokenfile, file.info(tokenfile)$size) # read token

# read the datafile, taking into account the token in the URL
dataset_url <- paste("https://raw.githubusercontent.com/inbo/invasive-t0-occurrences/master/data/processed/invasive_EU_listed_and_considered_with_joins.csv?token=",
                     token, sep = "" )
invasive_occ <- read.csv(dataset_url)

# check the head of the data file
head(invasive_occ)
