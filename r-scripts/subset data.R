
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

####Validation####
#Certain more common and recognisable species are non-propotionally not treated, under treatment 
#or not treatable.
#Experts selected the following species to have all validation statuses included.

table(Brondata$gbifapi_acceptedScientificName)
temp_ok <- data.frame()
valid_soorten <- c("Threskiornis aethiopicus (Latham, 1790)", "Oxyura jamaicensis (Gmelin, 1789)"
             ,"Procyon lotor (Linnaeus, 1758)", "Cabomba caroliniana A. Gray"
             ,"Tamias sibiricus (Laxmann, 1769)", "Nasua nasua (Linnaeus, 1766)"
             ,"Lysichiton americanus HultÃ©n & H.St.John", "Orconectes limosus (Rafinesque, 1817)"
             ,"Pacifastacus leniusculus (Dana, 1852)", "Procambarus clarkii (Girard, 1852)"
             ,"Pseudorasbora parva (Temminck & Schlegel, 1846)")
for(v in valid_soorten){
  temp <- subset(Brondata, gbifapi_acceptedScientificName == v)
  temp_ok <- rbind(temp_ok, temp)
}
temp_ok$gbifapi_acceptedScientificName <- factor(temp_ok$gbifapi_acceptedScientificName)
table(temp_ok$gbifapi_acceptedScientificName)
table(temp_ok$identificationVerificationStatus)
nrow(temp_ok) #27196 
#Records with identificationVerificationStatus ="non validÃ©" remain incorrect 
#and should still be removed
Valid2 <- subset(temp_ok, identificationVerificationStatus != "non validÃ©")
nrow(Valid2) #Expected: 27196 - 1155 = 26041/ Result: 26041 => OK

#Remove non treated, under treatment, not treatable records from remaining species
temp_nok <- subset(Brondata, !(gbifapi_acceptedScientificName %in% valid_soorten))
nrow(temp_nok)#Expected: 206824 - 27196 = 179628/ Result: 179628 => OK
table(temp_nok$identificationVerificationStatus)
Valid1 <- subset(temp_nok,identificationVerificationStatus != "Onbehandeld")
nrow(Valid1) #Expected: 179628 - 88512 = 91116/ Result: 91116 => OK
Valid1 <- subset(Valid1,identificationVerificationStatus != "In behandeling")
nrow(Valid1)#Expected: 91116 - 13 = 91103/ Result: 91103 => OK
Valid1 <- subset(Valid1,identificationVerificationStatus != "Niet te beoordelen")
nrow(Valid1)#Expected: 91103 - 31 = 91072/ Result: 91072 => OK
Valid1 <- subset(Valid1,identificationVerificationStatus != "non validÃ©")
nrow(Valid1)#Expected: 91072 - 24257 = 66815/ Result: 81255 => OK

Valid <- data.frame() #Empty first
Valid <- rbind(Valid1,Valid2)
#Expected: 66815 + 26041 = 92856/ Result: 92856 => OK
table(Valid$identificationVerificationStatus, Valid$gbifapi_acceptedScientificName)
table(Valid$basisOfRecord)
table(Valid$euConcernStatus)

####Subset according to euconcernstatus####

EuConc_ruw <- subset(Valid, euConcernStatus == "listed")
nrow(EuConc_ruw) #Xpected 43312/ Result: 43312 => OK
EuPrep_ruw <- subset(Valid, euConcernStatus == "under preparation")
EuCons_ruw <- subset(Valid, euConcernStatus == "under consideration")

table(EuConc_ruw$gbifapi_acceptedScientificName,EuConc_ruw$euConcernStatus)
table(EuConc_ruw$basisOfRecord)

####Only EU - Listed species#### 
####Clean-up EUConcern####

EuConc <- subset(EuConc_ruw, !is.na(gis_utm1_code))
EuConc <- subset(EuConc, !is.na(gbifapi_acceptedScientificName))
EuConc <- subset(EuConc, !is.na(year))
EuConc <- subset(EuConc, basisOfRecord != "PRESERVED_SPECIMEN")

table(EuConc$gbifapi_acceptedScientificName,EuConc$euConcernStatus)

####Date Limitations####
#Only observations between 01/01/2000 and 31/01/2016 are withheld

table(EuConc$year)
tempNA <- subset(EuConc, eventDate == "")
tempNA2 <- subset(Brondata, eventDate == "")

EuConc$eventDate2 <- as.Date(EuConc$eventDate)
EuConc$Month <- format(EuConc$eventDate2, "%m")
EuConc$Month <- as.numeric(EuConc$Month)
EuConc$Day <- format(EuConc$eventDate2, "%d")

temp_na <- subset(EuConc, year > 1999)
temp_voor2016 <- subset(temp_na, year < 2016)
temp_2016 <- subset(EuConc, year == 2016)
temp_voorfeb16 <- subset(temp_2016, Month < 2)

EuConc2 <- rbind(temp_voor2016, temp_voorfeb16)

table(EuConc2$gbifapi_acceptedScientificName,EuConc2$euConcernStatus)

####Determine presence####
#For each individual UTM 1x1 square the presence of species s is determined

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

#Duplicate Check####

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

####Export Data####
#This data is used as input into GIS - Models
library(foreign)
write.csv2(presence, filename2)
write.dbf(presence, filename3)

