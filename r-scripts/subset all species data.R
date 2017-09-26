#This script is used to subset T0 data for a certain species.

library(googlesheets)
library(foreign)

####Data Importeren####
update <- "N"
TempLog <- data.frame(1)
title <- gs_title(x="Iteration", verbose = T)
Token <- gs_auth()
gs_auth(token = Token)
iteration <- gs_read(title)
iteration$date <- as.character(iteration$date)
nieuw <- tail(iteration$date,1)
today <- Sys.Date()
today <- format(today,"%d_%m_%y")
TempLog$Date <- today
TempLog$Iteration <- nieuw
filename <- paste("./Output/T0_SourceData_", nieuw, ".csv", sep="")


if(update == "J"){
  print("updating source data")
  print("started")
  t <- Sys.time()
  print(t)
  source("Update Source.R")
  Brondata <- invasive_occ
  print("update filenames")
}else{
  Brondata <- read.csv(filename)
  if(today!=nieuw){
    print("Data is not up to date! Last update from:")
    print(nieuw)
  }
}

####Remove data from the netherlands####
Brondata <- subset(Brondata, gis_utm1_code != "FS7090" )
Brondata <- subset(Brondata, gis_utm1_code != "GS0588" )
TempLog$Netherlands <- TempLog$Import-nrow(Brondata)

####Subset species data####
table(Brondata$gbifapi_acceptedScientificName)
specieslist <- c("Lithobates catesbeianus (Shaw, 1802)")
for(s in specieslist){
  species_temp <- subset(Brondata, gbifapi_acceptedScientificName == s)
  speckey <- unique(species_temp$gbifapi_acceptedKey)
  speclet <- unique(substr(species_temp$gbifapi_acceptedScientificName, 1,6))
  filename_csv <- paste("./Output/", speckey, "_", speclet, "_", today, ".csv", sep="")
  filename_dbf <- paste("./Output/", speckey, "_", speclet, "_", today, ".dbf", sep="")
  write.csv(species_temp, filename_csv)
  write.csv(species_temp, filename_dbf)
}

