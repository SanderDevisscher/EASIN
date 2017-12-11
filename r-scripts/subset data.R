
library(googlesheets)

####Data Importeren####
update <- "N"
TempLog <- data.frame(1)
#setwd("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/")
#iteration <- read.csv("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/iteration.csv", sep=",")
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
#Import filename
#filename <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/T0_SourceData_", nieuw, ".csv", sep="")
filename <- paste("./Output/T0_SourceData_", nieuw, ".csv", sep="")
#Export filename
#filename2 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/UTM1Data_Source_", nieuw,"_Export_", today, ".csv", sep="")
#filename3 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/UTM1Data_Source_", nieuw,"_Export_", today, ".dbf", sep="")


if(update == "J"){
  print("updating source data")
  print("started")
  t <- Sys.time()
  print(t)
  source("Update Source.R")
  Brondata <- invasive_occ
  print("update filenames")
  #iteration <- read.csv("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/iteration.csv", sep=",")
  #title <- gs_title(x="Iteration", verbose = T)
  #iteration <- gs_read(title)
  #iteration$date <- as.character(iteration$date)
  #nieuw <- tail(iteration$date,1)
  #filename <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/T0_SourceData_", nieuw, ".csv", sep="")
  #filename2 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/UTM1Data_Source_", nieuw,"_Export_", today, ".csv", sep="")
  #filename3 <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/UTM1Data_Source_", nieuw,"_Export_", today, ".dbf", sep="")
}else{
  Brondata <- read.csv(filename)
  if(today!=nieuw){
    print("Data is not up to date! Last update from:")
    print(nieuw)
  }
}

TempLog$Import <- nrow(Brondata)

####Remove data from the netherlands####
Brondata <- subset(Brondata, gis_utm1_code != "FS7090" )
Brondata <- subset(Brondata, gis_utm1_code != "GS0588" )
TempLog$Netherlands <- TempLog$Import-nrow(Brondata)
 
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
             ,"Pseudorasbora parva (Temminck & Schlegel, 1846)","Trachemys Agassiz, 1857"
             ,"Alopochen aegyptiaca (Linnaeus, 1766)","Impatiens glandulifera Royle"
             ,"Heracleum mantegazzianum Sommier & Levier", "Ondatra zibethicus (Linnaeus, 1766)")
for(v in valid_soorten){
  temp <- subset(Brondata, gbifapi_acceptedScientificName == v)
  temp_ok <- rbind(temp_ok, temp)
}
temp_ok$gbifapi_acceptedScientificName <- factor(temp_ok$gbifapi_acceptedScientificName)
table(temp_ok$gbifapi_acceptedScientificName)
table(temp_ok$identificationVerificationStatus)
TempLog$temp_ok <- nrow(temp_ok) #242383
Valid2 <- temp_ok

###Remove non treated, under treatment, not treatable records from remaining species
#Select harder to recognise and more rare species
temp_nok <- subset(Brondata, !(gbifapi_acceptedScientificName %in% valid_soorten))
TempLog$NOK_1_0 <- nrow(temp_nok)#Expected: 269728 - 242383 = 27345/ Result: 27345 => OK
table(temp_nok$identificationVerificationStatus)
#Remove "untreated" records
Valid1 <- subset(temp_nok,identificationVerificationStatus != "Onbehandeld")
TempLog$NOK_1_1 <- nrow(Valid1) #Expected: 27345 - 1312 = 26033/ Result: 26033 => OK
#Remove records "under treatement"
Valid1 <- subset(Valid1,identificationVerificationStatus != "In behandeling")
TempLog$NOK_1_2 <- nrow(Valid1)#Expected: 26033 - 13 = 26020/ Result: 26020 => OK
#Remove "unable to confirm" records 
Valid1 <- subset(Valid1,identificationVerificationStatus != "Niet te beoordelen")
TempLog$NOK_1_3 <- nrow(Valid1)#Expected: 26020 - 16 = 26004/ Result: 26004 => OK
Valid1 <- subset(Valid1,identificationVerificationStatus != 0)
TempLog$NOK_1_4 <- nrow(Valid1)#Expected: 26004 - 343 = 25661/ Result: 25661 => OK

Valid <- data.frame() #Empty first
Valid <- rbind(Valid1,Valid2)
TempLog$OK_NOK <- nrow(Valid)#Expected: 242383 + 25661 =  268044/ Result:  268044 => OK
table(Valid$identificationVerificationStatus, Valid$gbifapi_acceptedScientificName)
table(Valid$basisOfRecord)
table(Valid$euConcernStatus)

####Subset according to euconcernstatus####

EuConc_ruw <- subset(Valid, euConcernStatus == "listed")
TempLog$EuConc <- nrow(EuConc_ruw) #Xpected 40184/ Result: 40184 => OK
EuPrep_ruw <- subset(Valid, euConcernStatus == "under preparation")
TempLog$EuPrep <- nrow(EuPrep_ruw)
EuCons_ruw <- subset(Valid, euConcernStatus == "under consideration")
TempLog$EuCons<- nrow(EuCons_ruw)
table(EuConc_ruw$gbifapi_acceptedScientificName,EuConc_ruw$euConcernStatus)
table(EuConc_ruw$basisOfRecord)

####Export Non-Listed####
NonListed <- rbind(EuPrep_ruw, EuCons_ruw)
filename_NotListed <- paste("./Output/NonListed_", nieuw, "_exported_", today, ".csv", sep = "")
title_NL <- gs_title(x="Iteration_NonListed", verbose = T)
iteration_NL <- gs_read(title)
temp <- data.frame(today)
temp$X1 <- tail(x = iteration_NL$X1,n=1)+1
temp$obs <- nrow(EuPrep_ruw) + nrow(EuCons_ruw)
temp$export <- nieuw
temp$import <- today
temp$today <- NULL
gs_add_row(ss = title_NL, 1, input=temp)
write.csv(NonListed, filename_NotListed)


####Only EU - Listed species#### 
####Clean-up EUConcern####
#Retain only records with at least Grid 10k square match, gbifapi_acceptedScientificName and year
#Which are not preserved specimens

EuConc <- subset(EuConc_ruw, !is.na(gis_EUgrid_cellcode))
EuConc <- subset(EuConc, gis_EUgrid_cellcode != "")
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
nrow(EuConc2) #expected: 35681 - 1 = 35680/ result:35680 
table(EuConc2$gbifapi_acceptedScientificName,EuConc2$euConcernStatus)

doc_Listed <- data.frame(table(EuConc2$gbifapi_acceptedScientificName, EuConc2$identificationVerificationStatus))
doc_Listed <- subset(doc_Listed, Freq != 0)
write.csv2(doc_Listed, "//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/Overview_Species_Verificationstatus.csv")

####Remove incorrect squares####
#During review of the maps produced some squares showed a presence for the species below while they shouldn't
#The decision was made by experts to remove these squares from the dataset.

#Tamias sibiricus
temp <- subset(EuConc2, gbifapi_acceptedScientificName == "Tamias sibiricus (Laxmann, 1769)")
temp <- subset(temp, gis_EUgrid_cellcode != "10kmE387N307")
temp2 <- subset(EuConc2, gbifapi_acceptedScientificName != "Tamias sibiricus (Laxmann, 1769)")
EuConc2 <- rbind(temp, temp2)

remove(temp)
remove(temp2)

####Export subsetted data####
library(foreign)
filename6 <- paste("./Output/Data_", nieuw,"_Subsetted_", today, ".csv", sep="")
filename7 <- paste("./Output/Data_", nieuw,"_Subsetted_", today, ".dbf", sep="")
write.csv2(EuConc2, filename6)
write.dbf(EuConc2, filename7)

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
