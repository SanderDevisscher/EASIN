
####Data Importeren####
update <- "N"
#setwd("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/")
iteration <- read.csv("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/iteration.csv", sep=",")
iteration$date <- as.character(iteration$date)
nieuw <- tail(iteration$date,1)
today <- Sys.Date()
today <- format(today,"%d_%m_%y")
#Import filename
filename <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/T0_SourceData_", nieuw, ".csv", sep="")
#Export filename
filename2 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/UTM1Data_Source_", nieuw,"_Export_", today, ".csv", sep="")
filename3 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/UTM1Data_Source_", nieuw,"_Export_", today, ".dbf", sep="")


if(update == "J"){
  print("updating source data")
  print("started")
  t <- Sys.time()
  print(t)
  source("Update Source.R")
  Brondata <- invasive_occ
  print("update filenames")
  iteration <- read.csv("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/iteration.csv", sep=",")
  iteration$date <- as.character(iteration$date)
  nieuw <- tail(iteration$date,1)
  filename <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/T0_SourceData_", nieuw, ".csv", sep="")
  filename2 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/UTM1Data_Source_", nieuw,"_Export_", today, ".csv", sep="")
  filename3 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/UTM1Data_Source_", nieuw,"_Export_", today, ".dbf", sep="")
}else{
  Brondata <- read.csv(filename)
  if(today!=nieuw){
    print("Data is not up to date! Laatste update van:")
    print(nieuw)
  }
}

table(Brondata$gbifapi_acceptedScientificName,Brondata$euConcernStatus)
table(Brondata$identificationVerificationStatus)

####Enkel gevalideerde####
#Remove non treated, under treatment, not treatable records 
Valid <- subset(Brondata,identificationVerificationStatus != "Onbehandeld")
Valid <- subset(Valid,identificationVerificationStatus != "In behandeling")
Valid <- subset(Valid,identificationVerificationStatus != "Niet te beoordelen")
Valid <- subset(Valid,identificationVerificationStatus != "non validÃ©")

table(Valid$identificationVerificationStatus)
####Opsplitsen Volgens eulist status####

EuConc_ruw <- subset(Valid, euConcernStatus == "listed")
EuPrep_ruw <- subset(Valid, euConcernStatus == "under preparation")
EuCons_ruw <- subset(Valid, euConcernStatus == "under consideration")

table(EuConc_ruw$gbifapi_acceptedScientificName,EuConc_ruw$euConcernStatus)

####Vereenvoudiging EUConcern####
EuConc <- subset(EuConc_ruw, !is.na(gis_utm1_code))
EuConc <- subset(EuConc, !is.na(gbifapi_acceptedScientificName))
EuConc <- subset(EuConc, !is.na(year))

table(EuConc$gbifapi_acceptedScientificName,EuConc$euConcernStatus)


####Datum afkap####
#t.e.m. 31/01/2016

EuConc$eventDate2 <- as.Date(EuConc$eventDate)
EuConc$Month <- format(EuConc$eventDate2, "%m")
EuConc$Month <- as.numeric(EuConc$Month)
EuConc$Day <- format(EuConc$eventDate2, "%d")

temp_voor2016 <- subset(EuConc, year < 2016)
temp_2016 <- subset(EuConc, year == 2016)
temp_voorfeb16 <- subset(temp_2016, Month < 2)

EuConc2 <- rbind(temp_voor2016, temp_voorfeb16)

table(EuConc2$gbifapi_acceptedScientificName,EuConc2$euConcernStatus)

####aanwezigheid bepalen####
soorten <- unique(EuConc2$gbifapi_acceptedScientificName)
print(soorten)
presence <- data.frame()
temp3 <- data.frame("x")

for(s in soorten){
  temp <- subset(EuConc2, gbifapi_acceptedScientificName == s)
  utmhokken <- unique(temp$gis_utm1_code)
  for(u in utmhokken){
    temp2 <- subset(temp, gis_utm1_code == u) #Temporary 
    temp3$utm1 <- u
    temp3$species <- s
    temp3$wnmn <- nrow(temp2)
    presence <- rbind(presence, temp3)
  }
}

presence$X.utm1.....u <- NULL
presence$X.species.....s <- NULL
presence$X.x <- NULL

sum(presence$wnmn)

remove(temp)
remove(temp2)
remove(temp3)

#Duplicaten controle####
anyDuplicated(presence$utm1)
utmhokken2 <- unique(presence$utm1)
temp3 <- data.frame("x")

for(v in utmhokken2){
  temp <- subset(presence, utm1 == v)
  soorten2 <- unique(temp$species)
  for(r in soorten2){
    temp2 <- subset(temp, species == r)
    if(nrow(temp2)>1){
      temp3 <- rbind(temp3,temp2)
    }
  }
} 

####Data Exporteren####
library(foreign)
write.csv2(presence, filename2)
write.dbf(presence, filename3)

