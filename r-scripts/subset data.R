
####Data Importeren####
update <- "J"
setwd("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/")
iteration <- read.csv("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/iteration.csv", sep=",")
iteration$date <- as.character(iteration$date)
nieuw <- head(iteration$date,1)
filename <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Data/T0_Source_", nieuw, ".csv")

if(update == "J"){
  print("updating source data")
  print("started")
  t <- Sys.time()
  print(t)
  source("Update Source.R")
  Brondata <- invasive_occ
}else{
  today <- Sys.Date()
  today <- format(today,"%d_%m_%y")
  Brondata <- read.csv(filename)
  if(today!=nieuw){
    print("Data is not up to date! Laatste update van:")
    print(today)
  }
}

####Opsplitsen Volgens eulist status####
EuConc_ruw <- subset(Brondata, euConcernStatus == "listed")
EuPrep_ruw <- subset(Brondata, euConcernStatus == "under preparation")
EuCons_ruw <- subset(Brondata, euConcernStatus == "under consideration")

####Vereenvoudiging EUConcern####
EuConc <- subset(EuConc_ruw, !is.na(gis_utm1_code))
EuConc <- subset(EuConc, !is.na(gbifapi_acceptedScientificName))
EuConc <- subset(EuConc, !is.na(year))

####aanwezigheid bepalen####
soorten <- unique(EuConc$gbifapi_acceptedScientificName)
presence <- data.frame()

for(s in soorten){
  temp <- subset(EuConc, gbifapi_acceptedScientificName == s)
  utmhokken <- unique(temp$gis_utm1_code)
  for(u in utmhokken){
    temp2 <- subset(temp, gis_utm1_code == u) #Temporary 
    temp3$utm1 <- u
    temp3$species <- s
    presence <- rbind(presence, temp3)
  }
}

presence$X.utm1.....u <- NULL
presence$X.species.....s <- NULL