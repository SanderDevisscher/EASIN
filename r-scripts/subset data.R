
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
    print("Data is not up to date! Last update from:")
    print(nieuw)
  }
}

####Remove data from the netherlands####
Brondata <- subset(Brondata, gis_utm1_code != "FS7090" )
Brondata <- subset(Brondata, gis_utm1_code != "GS0588" )
 
#--------

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
             , "Eriocheir sinensis H. Milne Edwards, 1853"
             ,"Pseudorasbora parva (Temminck & Schlegel, 1846)","Trachemys scripta Schoepff, 1792")
for(v in valid_soorten){
  temp <- subset(Brondata, gbifapi_acceptedScientificName == v)
  temp_ok <- rbind(temp_ok, temp)
}
temp_ok$gbifapi_acceptedScientificName <- factor(temp_ok$gbifapi_acceptedScientificName)
table(temp_ok$gbifapi_acceptedScientificName)
table(temp_ok$identificationVerificationStatus)
nrow(temp_ok) #31813 
Valid2 <- temp_ok

#Remove non treated, under treatment, not treatable records from remaining species
temp_nok <- subset(Brondata, !(gbifapi_acceptedScientificName %in% valid_soorten))
nrow(temp_nok)#Expected: 162953 - 31813 = 131140/ Result: 131140 => OK
table(temp_nok$identificationVerificationStatus)
Valid1 <- subset(temp_nok,identificationVerificationStatus != "Onbehandeld")
nrow(Valid1) #Expected: 131140 - 79847 = 51293/ Result: 51293 => OK
Valid1 <- subset(Valid1,identificationVerificationStatus != "In behandeling")
nrow(Valid1)#Expected: 51293 - 13 = 51280/ Result: 51280 => OK
Valid1 <- subset(Valid1,identificationVerificationStatus != "Niet te beoordelen")
nrow(Valid1)#Expected: 51280 - 31 = 51249/ Result: 51249 => OK
Valid1 <- subset(Valid1,identificationVerificationStatus != 0)
nrow(Valid1)#Expected: 51249 - 343 = 50906/ Result: 50906 => OK

Valid <- data.frame() #Empty first
Valid <- rbind(Valid1,Valid2)
nrow(Valid)#Expected: 50906 + 31813 =  82719/ Result:  82719 => OK
table(Valid$identificationVerificationStatus, Valid$gbifapi_acceptedScientificName)
table(Valid$basisOfRecord)
table(Valid$euConcernStatus)

####Subset according to euconcernstatus####

EuConc_ruw <- subset(Valid, euConcernStatus == "listed")
nrow(EuConc_ruw) #Xpected 39747/ Result: 39747 => OK
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
table(EuConc2$gbifapi_acceptedScientificName, EuConc2$identificationVerificationStatus)

#Subset faulty data####
#Experts determined that all observations of "Orconectes virilis" are incorrect 
#and thus should be removed manually untill the faulty record has been discovered and fixed

EuConc2 <- subset(EuConc2, gbifapi_acceptedScientificName != "Orconectes virilis (Hagen, 1870)")
nrow(EuConc2) #expected: 35382 - 1 = 35381/ result:35381 
table(EuConc2$gbifapi_acceptedScientificName,EuConc2$euConcernStatus)

doc_Listed <- data.frame(table(EuConc2$gbifapi_acceptedScientificName, EuConc2$identificationVerificationStatus))
doc_Listed <- subset(doc_Listed, Freq != 0)
write.csv2(doc_Listed, "//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/Overview_Species_Verificationstatus.csv")

####Export subsetted data####
filename6 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/Data_", nieuw,"_Subsetted_", today, ".csv", sep="")
write.csv2(EuConc2, filename6)

####Determine presence UTM1x1####
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
#Should be equal to the number of observations of EuConc2
#Expected: 36310/ Result: 36310 => OK 

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

####Export Data UTM1####
#This data is used as input into GIS - Models
library(foreign)
write.csv2(presence, filename2)
write.dbf(presence, filename3)

####Determine presence 10kGrid####
#For each individual 1km square the presence of species s is determined

soorten <- unique(EuConc2$gbifapi_acceptedScientificName)
print(soorten)
presence2 <- data.frame()
temp3 <- data.frame("x")

for(s in soorten){
  temp <- subset(EuConc2, gbifapi_acceptedScientificName == s)
  GRID <- unique(temp$gis_EUgrid_cellcode)
  for(g in GRID){
    temp2 <- subset(temp, gis_EUgrid_cellcode == g) #Temporary 
    temp3$EUgrid_cellcode <- g
    temp3$species <- s
    temp3$wnmn <- nrow(temp2)
    presence2 <- rbind(presence2, temp3)
  }
}

sum(presence2$wnmn)
presence2$X.x. <- NULL
#Should be equal to the number of observations of EuConc2
#Expected: 36310/ Result: 36310 => OK 

remove(temp)
remove(temp2)
remove(temp3)

####Export Data 10k GRID####
#This data is used as input into GIS - Models
library(foreign)
filename4 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/GRID10kData_Source_", nieuw,"_Export_", today, ".csv", sep="")
filename5 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/GRID10kData_Source_", nieuw,"_Export_", today, ".dbf", sep="")
write.csv2(presence2, filename4)
write.dbf(presence2, filename5)
