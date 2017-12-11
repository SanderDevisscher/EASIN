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
#filename <- paste("./Output/T0_SourceData_", nieuw, ".csv", sep="")


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

####fix dates####
Brondata$eventDate <- as.Date.factor(Brondata$eventDate)
Brondata$year <- as.numeric(Brondata$year)

####Subset species data####
table(Brondata$gbifapi_acceptedScientificName)
specieslist <- c("Cabomba caroliniana A. Gray", "Elodea nuttallii (Planch.) H.St.John", 
                 "Hydrocotyle ranunculoides L. fil.", "Heracleum mantegazzianum Sommier & Levier",
                 "Impatiens glandulifera Royle", "Lagarosiphon major (Ridl.) Moss",
                 "Ludwigia grandiflora (Michaux) Greuter & Burdet", "Ludwigia peploides (Kunth) P. H. Raven",
                 "Lysichiton americanus HultÃ©n & H.St.John", "Myriophyllum aquaticum (Vellozo) Verdcourt",
                 "Myriophyllum heterophyllum Michx.") 
temp_merge <- data.frame()
specinit3 <- ""
i <- 0
for(s in specieslist){
  species_temp <- subset(Brondata, gbifapi_acceptedScientificName == s)
  speckey <- unique(species_temp$gbifapi_acceptedKey)
  speclet <- unique(substr(species_temp$gbifapi_acceptedScientificName, 1,6))
  specinit1 <- unique(substr(species_temp$gbifapi_acceptedScientificName, 1,1))
  specinit2 <- specinit3
  specinit3 <- paste(specinit2, specinit1, sep="")
  filename_csv <- paste("./Output/", speckey, "_", speclet, "_", today, ".csv", sep="")
  filename_dbf <- paste("./Output/", speckey, "_", speclet, "_", today, ".dbf", sep="")
  species_temp$bron <- ifelse(species_temp$rightsHolder== "INBO", "INBO", 
                              ifelse(species_temp$rightsHolder == "Natuurpunt Studie", "Natuurpunt Studie", "Andere"))
  write.csv(species_temp, filename_csv)
  write.csv(species_temp, filename_dbf)
  i <- i + 1
  if(length(specieslist)>1){
    temp_merge <- rbind(temp_merge, species_temp)
    if(i == 1){
      FN1 <- speclet
    }
    if(i == 2){
      FN2 <- speclet
      FN <- paste("./Output/Merged", FN1, FN2, today, sep="_")
    }
    if(i == 3){
      FN3 <- speclet
      FN <- paste("./Output/Merged", FN1, FN2, FN3, today, sep="_")
    }
    if(i == 4){
      FN4 <- speclet
      FN <- paste("./Output/Merged", FN1, FN2, FN3, FN4, today, sep="_")
    }
    if(i >= 5){
      FN <- paste("./Output/Merged", "Five_or_More_Species",specinit3, today, sep="_")
    }
  }
}
Filename_csv_multi <- paste(FN, ".csv")
write.csv(temp_merge, Filename_csv_multi)

####Remove non - validated following T0 method (with easy to recognise species)
temp_merge_ok <- data.frame()
for(v in valid_soorten){
  temp <- subset(temp_merge, gbifapi_acceptedScientificName == v)
  temp_merge_ok <- rbind(temp_merge_ok, temp)
}

#Select harder to recognise and more rare species
temp_merge_nok <- subset(temp_merge, !(gbifapi_acceptedScientificName %in% valid_soorten))
table(temp_nok$identificationVerificationStatus)
#Remove "untreated" records
Valid3 <- subset(temp_merge_nok,identificationVerificationStatus != "Onbehandeld")
#Remove records "under treatement"
Valid3 <- subset(Valid3,identificationVerificationStatus != "In behandeling")
#Remove "unable to confirm" records 
Valid3 <- subset(Valid3,identificationVerificationStatus != "Niet te beoordelen")
Valid3 <- subset(Valid3,identificationVerificationStatus != 0)


Valid4 <- temp_merge_ok
Valid5 <- data.frame() #Empty first
Valid5 <- rbind(Valid3,Valid4)

Filename_csv_multi_valid <- paste(FN, "_Validated", ".csv")
write.csv(Valid5, Filename_csv_multi_valid)

