
library(googlesheets)
library(tidyverse)

####Data Importeren####
update <- "N"
Driveletter <- "D"
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
  Brondata <- read_csv(filename)
  if(today!=nieuw){
    print("Data is not up to date! Last update from:")
    print(nieuw)
  }
}

TempLog$Import <- nrow(Brondata)

####Remove data from the netherlands####
Brondata_backup <- Brondata
Brondata <- subset(Brondata, gis_utm1_code != "FS7090" | is.na(gis_utm1_code))
Brondata <- subset(Brondata, gis_utm1_code != "GS0588" | is.na(gis_utm1_code))
TempLog$Netherlands <- TempLog$Import-nrow(Brondata)
 
#--------
table(Brondata$gbifapi_acceptedScientificName,Brondata$euConcernStatus)
Brondata$euConcernStatus <- ifelse(Brondata$euConcernStatus == "Listed", "listed", Brondata$euConcernStatus)
table(Brondata$gbifapi_acceptedScientificName,Brondata$euConcernStatus)
table(Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "0.0", "0"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "1.0", "1"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "4.0", "4"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "5.0", "5"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "approved", "Goedgekeurd"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "approved based on expert opinion"
                                                        , "Goedgekeurd op basis van expertoordeel"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "approved based on knowledge rules"
                                                        , "Goedgekeurd op basis van kennisregels"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "approved based on proof"
                                                        , "Goedgekeurd op basis van bewijsmateriaal"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "untreated"
                                                        , "Onbehandeld"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "BIM-rejected"
                                                        , "Afgekeurd"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "BIM-rejected"
                                                        , "Afgekeurd"
                                                        ,Brondata$identificationVerificationStatus)
Brondata$identificationVerificationStatus <- ifelse(Brondata$identificationVerificationStatus == "j"
                                                        , "Goedgekeurd"
                                                        ,Brondata$identificationVerificationStatus)
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
#temp_ok$gbifapi_acceptedScientificName <- factor(temp_ok$gbifapi_acceptedScientificName)
table(temp_ok$gbifapi_acceptedScientificName)
table(temp_ok$identificationVerificationStatus)
TempLog$temp_ok <- nrow(temp_ok) #435463
Valid2 <- temp_ok

###Remove non treated, under treatment, not treatable records from remaining species
#Select harder to recognise and more rare species
paste("expected: ", nrow(Brondata)-nrow(temp_ok), sep="")
temp_nok <- subset(Brondata, !(gbifapi_acceptedScientificName %in% valid_soorten))
TempLog$NOK_1_0 <- nrow(temp_nok) #Expected: 465992 - 435463 = 27345/ Result: 27345 => OK
table(temp_nok$identificationVerificationStatus)
#Select NA's
Valid3 <- subset(temp_nok,is.na(identificationVerificationStatus))
TempLog$NOK_2_1 <- nrow(Valid3)
#Remove "untreated" records
Valid1 <- subset(temp_nok,identificationVerificationStatus != "Onbehandeld")
TempLog$NOK_1_1 <- nrow(Valid1) #Expected: 30529 - 1544 - 22319 = 6666/ Result: 6666 => OK
table(Valid1$identificationVerificationStatus)
#Remove records "under treatement"
Valid1 <- subset(Valid1,identificationVerificationStatus != "In behandeling")
TempLog$NOK_1_2 <- nrow(Valid1)#Expected: 6666 - 13 = 6653/ Result: 6653 => OK
#Remove "unable to confirm" records 
Valid1 <- subset(Valid1,identificationVerificationStatus != "Niet te beoordelen" )
TempLog$NOK_1_3 <- nrow(Valid1)#Expected: 6653 - 16 = 6637/ Result: 6637 => OK
Valid1 <- subset(Valid1,identificationVerificationStatus != 0)
TempLog$NOK_1_4 <- nrow(Valid1)#Expected: 6637 - 1076 = 5561/ Result: 5561 => OK
#Remove "Rejected" records
Valid1 <- subset(Valid1,identificationVerificationStatus != "Afgekeurd")
TempLog$NOK_1_5 <- nrow(Valid1)#Expected: 5560 - 1 = 5560/ Result: 5560 => OK

Valid <- data.frame() #Empty first
Valid <- rbind(Valid1,Valid2)
TempLog$OK_NOK <- nrow(Valid)#Expected: 435463 + 5560 =  441023/ Result:  441023 => OK
Valid <- rbind(Valid,Valid3)#Expected: 441023 + 22319 = 463342/ Result:  463342 => OK
table(Valid$identificationVerificationStatus, Valid$gbifapi_acceptedScientificName)
table(Valid$basisOfRecord)
table(Valid$gbifapi_acceptedScientificName, Valid$euConcernStatus)

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
EuConc <- EuConc_ruw
table(EuConc_ruw$basisOfRecord)
#EuConc <- subset(EuConc_ruw, !is.na(gis_EUgrid_cellcode))
#EuConc <- subset(EuConc, gis_EUgrid_cellcode != "")
EuConc <- subset(EuConc, !is.na(gbifapi_acceptedScientificName))
EuConc <- subset(EuConc, !is.na(year))
temp <- subset(EuConc, is.na(basisOfRecord))
EuConc <- subset(EuConc, basisOfRecord != "PRESERVED_SPECIMEN")
EuConc <- rbind(temp, EuConc)

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
temp_voor2017 <- subset(temp_na, year < 2017)
temp_2016 <- subset(EuConc, year == 2016)
temp_2017 <- subset(EuConc, year == 2017)
temp_voorfeb16 <- subset(temp_2016, Month < 2)
temp_voorsep17 <- subset(temp_2017, Month < 9)

EuConc2 <- rbind(temp_voor2017, temp_voorsep17)

table(EuConc2$year, EuConc2$Month)
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
write_csv(doc_Listed, "./Private/Checkup/Overview_Species_Verificationstatus.csv")

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
readr::write_csv(EuConc2, filename6)
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
#For each individual 10km square the presence of species s is determined

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
filename4 <- paste("./Output/GRID10kData_Source_", nieuw,"_Export_", today, ".csv", sep="")
filename5 <- paste("./Output/GRID10kData_Source_", nieuw,"_Export_", today, ".dbf", sep="")
filename6 <- paste(Driveletter,
                   "://Projects/PRJ_Faunabeheer/INBOPRJ-10217 - Monitoring exoten ikv EU- verordening IAS  Coördinatie, voorbereiding, implementatie en opvolging/EASIN_GIS/Input/GRID10kData_Source_"
                   , nieuw,"_Export_", today, ".csv", sep="")
filename7 <- paste(Driveletter,
                   "://Projects/PRJ_Faunabeheer/INBOPRJ-10217 - Monitoring exoten ikv EU- verordening IAS  Coördinatie, voorbereiding, implementatie en opvolging/EASIN_GIS/Input/GRID10kData_Source_"
                   , nieuw,"_Export_", today, ".dbf", sep="")

write.csv2(presence2, filename4)
write.dbf(presence2, filename5)
write.csv2(presence2, filename6)
write.dbf(presence2, filename7)
