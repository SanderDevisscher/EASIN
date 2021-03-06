library(googlesheets)
####Import data####
today <- Sys.Date()
today <- format(today,"%d_%m_%y")
title <- gs_title(x="Iteration_NonListed", verbose = T)
iteration_NL <- gs_read(title)
iteration$date <- as.character(iteration$date)
import <- tail(iteration_NL$import,1)
export <- tail(iteration_NL$export,1)
NonListed_Ruw_Source <- paste("./Output/NonListed_", import, "_exported_", export, ".csv", sep = "")
NonListed_ruw <- read.csv(NonListed_Ruw_Source)
nrow(NonListed_ruw) #Expected: 146140 + 192 = 146332 Result: 146332 => OK!

####Subset 2nd Batch Species####
NonListed_ruw$gbifapi_acceptedScientificName <- factor(NonListed_ruw$gbifapi_acceptedScientificName)
table(NonListed_ruw$gbifapi_acceptedScientificName)
SpeciesBatch2 <- c("Alopochen aegyptiaca (Linnaeus, 1766)", "Alternanthera philoxeroides", "Asclepias syriaca L.",
              "Elodea nuttallii (Planch.) H.St.John", "Gunnera tinctoria", "Heracleum mantegazzianum Sommier & Levier",
              "Impatiens glandulifera Royle", "Microtegium vimineum", "Myriophyllum heterophyllum Michx.", 
              "Nyctereutes procyonoides (Gray, 1834)", "Ondatra zibethicus (Linnaeus, 1766)", 
              "Pennisetum setaceum")
temp_ok <- data.frame()
for (b in SpeciesBatch2){
  temp <- subset(NonListed_ruw, gbifapi_acceptedScientificName == b)
  temp_ok <- rbind(temp_ok, temp)
}
Batch2_ruw <- temp_ok
table(Batch2_ruw$gbifapi_acceptedScientificName)
#Cleanup
remove(temp)
remove(temp_ok)

####Clean-up 2nd Batch####
#Retain only records with at least Grid 10k square match, gbifapi_acceptedScientificName and year
#Which are not preserved specimens

Batch2 <- subset(Batch2_ruw, !is.na(gis_EUgrid_cellcode))
Batch2 <- subset(Batch2, gis_EUgrid_cellcode != "")
Batch2 <- subset(Batch2, !is.na(gbifapi_acceptedScientificName))
Batch2 <- subset(Batch2, !is.na(year))
Batch2 <- subset(Batch2, basisOfRecord != "PRESERVED_SPECIMEN")

table(Batch2$gbifapi_acceptedScientificName,Batch2$euConcernStatus)
nrow(Batch2)

####Date Limitations####
#Only observations between 01/01/2000 and 31/01/2016 are withheld

table(Batch2$year)
tempNA <- subset(Batch2, eventDate == "")
tempNA2 <- subset(Brondata, eventDate == "")

Batch2$eventDate2 <- as.Date(Batch2$eventDate)
Batch2$Month <- format(Batch2$eventDate2, "%m")
Batch2$Month <- as.numeric(Batch2$Month)
Batch2$Day <- format(Batch2$eventDate2, "%d")

temp_na <- subset(Batch2, year > 1999)
temp_voor2016 <- subset(temp_na, year < 2016)
temp_2016 <- subset(Batch2, year == 2016)
temp_voorfeb16 <- subset(temp_2016, Month < 2)

Batch2_2 <- rbind(temp_voor2016, temp_voorfeb16)

table(Batch2_2$gbifapi_acceptedScientificName,Batch2_2$euConcernStatus)
table(Batch2_2$gbifapi_acceptedScientificName, Batch2_2$identificationVerificationStatus)
####Import Batch 1####
Batch1 <- read.csv2("./Output/Data_08_03_17_Subsetted_08_03_17.csv")
Batch1$X <- NULL


####Merge With Batch 1####
Batch2_2$X.1 <- NULL
Batch2_2$X <- NULL
str(Batch1)
str(Batch2_2)
Batch1$source <- NA
Managebility <- rbind(Batch1, Batch2_2)

library(foreign)
filename8 <- paste("./Output/", import,"_Exp_", export ,"_Managebility_", today, ".csv", sep="")
filename9 <- paste("./Output/", import,"_Exp_", export ,"_Managebility_", today, ".dbf", sep="")
write.csv2(Managebility, filename8)
write.dbf(Managebility, filename9)
