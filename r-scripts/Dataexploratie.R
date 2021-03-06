library(plyr)
library(dplyr)
library(ggplot2)

iteration <- read.csv("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/iteration.csv", sep=",")
iteration$date <- as.character(iteration$date)
nieuw <- tail(iteration$date,1)
filename <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/T0_SourceData_", nieuw, ".csv", sep="")

Brondata <- read.csv(filename)

table(Brondata$gbifapi_acceptedScientificName,Brondata$euConcernStatus)
table(Brondata$identificationVerificationStatus)

####Opsplitsen Volgens eulist status####

EuConc_ruw <- subset(Brondata, euConcernStatus == "listed")
EuConc_ruw$gbifapi_acceptedScientificName <- factor(EuConc_ruw$gbifapi_acceptedScientificName)

table(EuConc_ruw$gbifapi_acceptedScientificName,EuConc_ruw$euConcernStatus)
table(EuConc_ruw$basisOfRecord)
####Vereenvoudiging EUConcern####
EuConc <- subset(EuConc_ruw, !is.na(gis_utm1_code))
EuConc <- subset(EuConc, !is.na(gbifapi_acceptedScientificName))
EuConc <- subset(EuConc, !is.na(year))
EuConc <- subset(EuConc, basisOfRecord != "PRESERVED_SPECIMEN")

table(EuConc$gbifapi_acceptedScientificName,EuConc$euConcernStatus)

####Percentage waarnemingen per jaar####

Afkap <- c(1980,1990,2000,2005)

temp6 <- data.frame()
temp4 <- data.frame("x")
soorten <- unique(EuConc$gbifapi_acceptedScientificName)
  for(s in soorten){
    temp2 <- subset(EuConc, gbifapi_acceptedScientificName == s)
    somtotaal <- nrow(temp2)
    #total number of observations per species
    Jaren <- unique(temp2$year)
    for(j in Jaren){
      temp3 <- subset(temp2, year == j)
      somjaar <- nrow(temp3)
      temp4$year <- j
      temp4$soort <- s
      temp4$somjaar <- somjaar
      #number of observations of species s per year
      temp4$somtotaal <- somtotaal
      temp4$Percentage_observations <- (somjaar/somtotaal)*100
      #Percentage of observations, number of observations of species s per year divided by 
      #total number of observations per species
      temp5 <- temp4
      temp6 <- rbind(temp6, temp5)
      }
  }

for(t in Afkap){
temp <- subset(temp6, year >= t)

plot <- ggplot(temp, aes(year, Percentage_observations))
plot <- plot + geom_bar( stat="identity")
plot <- plot + facet_wrap(~soort, ncol = 2, scales = "fixed")
plot <- plot + theme_bw()
print(plot)

plotname <- paste("Percentagewnmn_na", t, ".jpeg", sep = "")

ggsave(plotname, plot = plot, width = 20/2.54, height = 40/2.54)
}

remove(temp)
remove(temp2)
remove(temp3)
remove(temp4)
remove(temp5)
remove(temp6)

####Percentage utm1-hokken per jaar####
temp3 <- data.frame("x")
temp4 <- data.frame()
soorten <- unique(EuConc$gbifapi_acceptedScientificName)
for(s in soorten){
  temp <- subset(EuConc, gbifapi_acceptedScientificName == s)
  jaren <- unique(temp$year)
  for(j in jaren){
    temp2 <- subset(temp, year == j)
    hokken <- unique(temp2$gis_utm1_code)
    for(h in hokken){
      temp3$soort <- s
      temp3$jaar <- j
      temp3$utm1 <- h
      temp3$uniekeutm <- 1
      #uniekeutm = Unique location for species s in year j
      temp4 <- rbind(temp4, temp3)
    }
    
  }
}

temp5 <- temp4[order(temp4$soort, temp4$jaar),]

temp5 <- mutate(group_by(temp5, soort, jaar), cumsum = cumsum(uniekeutm))
#Cumsum = Cumulative sum of unique locations for species s in year j

temp7 <- data.frame()
soorten <- unique(temp5$soort)
for (s in soorten){
  temp6 <- subset(temp5, soort == s)
  maxhokken <- length(unique(temp6$utm1))
  #maxhokken = Maximum number of unique locations for species s = Maximum extent of species s
  temp6$maxhokken <- maxhokken
  temp7 <- rbind(temp7, temp6)
}

temp7$Percentage_Locations <- (temp7$cumsum/temp7$maxhokken)*100
#Percentage_Locations = Cumulative share of maximum extent reached

temp11 <- data.frame()
temp10 <- data.frame("x")
soorten <- unique(temp7$soort)
for(s in soorten){
  temp8 <- subset(temp7, soort == s)
  jaren <- unique(temp8$jaar)
  for(j in jaren){
    temp9 <- subset(temp8, jaar == j)
    Percentage_Locations2 <- max(temp9$Percentage_Locations)
    #Percentage_Locations2 = Maximum achieved percentage of maximum extent for species s in year j
    temp10$soort <- s
    temp10$jaar <- j
    temp10$Percentage_Locations <- Percentage_Locations2
    temp11 <- rbind(temp11, temp10)
  }
}


for(t in Afkap){
  temp <- subset(temp11, jaar >= t)
  
  plot <- ggplot(temp, aes(jaar, Percentage_Locations))
  plot <- plot + geom_bar(stat="identity")
  plot <- plot + facet_wrap(~soort, ncol = 2, scales = "fixed")
  plot <- plot + theme_bw()
  print(plot)
  
  plotname <- paste("Percentagelocs_na", t, ".jpeg", sep = "")
  
  ggsave(plotname, plot = plot, width = 20/2.54, height = 40/2.54)
}

for(t in Afkap){
  temp <- subset(temp4, jaar >= t)
  
  plot <- ggplot(temp, aes(jaar, uniekeutm))
  plot <- plot + geom_bar(stat="identity")
  plot <- plot + facet_wrap(~soort, ncol = 2, scales = "fixed")
  plot <- plot + theme_bw()
  print(plot)
  
  plotname <- paste("locs_na", t, ".jpeg", sep = "")
  
  ggsave(plotname, plot = plot, width = 20/2.54, height = 40/2.54)
}

remove(temp)
remove(temp2)
remove(temp3)
remove(temp4)
remove(temp5)
remove(temp6)
remove(temp7)
remove(temp8)
remove(temp9)
remove(temp10)
remove(temp11)

####Validatiestatus per soort####

temp <- EuConc

####Overview sources used####
temp <- EuConc2

temp2 <- temp[c("gbifapi_acceptedScientificName", "verbatimDatasetName", "datasetName", "ownerOrganization", "institutionCode", "ownerInstitutionCode")]
temp2$ownerOrganization <- as.character(temp2$ownerOrganization)
temp2$institutionCode <- as.character(temp2$institutionCode)
temp2$ownerInstitutionCode <- as.character(temp2$ownerInstitutionCode)
temp2$verbatimDatasetName <- as.character(temp2$verbatimDatasetName)
temp2$datasetName <- as.character(temp2$datasetName)

temp2$Source <- ifelse(temp2$ownerOrganization != "", temp2$ownerOrganization,
                       ifelse(temp2$institutionCode != "", temp2$institutionCode, 
                              ifelse(temp2$ownerInstitutionCode != "", temp2$ownerInstitutionCode, "Unknown")))
temp2$Dataset <- ifelse(temp2$datasetName != "", temp2$datasetName, 
                        ifelse(temp2$verbatimDatasetName != "", temp2$verbatimDatasetName, 
                               "Unknown"))
temp2$Source <- ifelse(temp2$Dataset == "Ecologische inventarisatie en -visievorming van de Begijnenbeek", "INBO", temp2$Source)
temp2$Source <- ifelse(temp2$Dataset == "opnames voor habitat 3260-kartering", "INBO", temp2$Source)
temp2$Source <- ifelse(temp2$Dataset == "opnames voor monitoring habitat 3260", "INBO", temp2$Source)
temp2$Source <- ifelse(temp2$Dataset == "opnames voor rapportage KRW", "INBO", temp2$Source)
temp2$Source <- ifelse(temp2$Dataset == "INBODATAVR119_divers_HYLA_NieuweEU-RegulatieExoten_GIS_font_point", "HYLA", temp2$Source)

temp3 <- subset(temp2, is.na(Source))
temp3$datasetName <- as.character(temp3$Dataset)
table(temp3$Dataset)
remove(temp3)
temp4 <- temp2[c("gbifapi_acceptedScientificName", "Source", "Dataset")]
temp8 <- data.frame("X")
temp9 <- data.frame()
Species <- unique(temp4$gbifapi_acceptedScientificName)
for (s in Species){
  temp5 <- subset(temp4, gbifapi_acceptedScientificName == s)
  Sources <- unique(temp5$Source)
  for (t in Sources){
    temp6 <- subset(temp5, Source == t)
    Datasets <- unique(temp6$Dataset)
    for (d in Datasets){
      temp7 <- subset(temp6, Dataset == d)
      temp8$Species <- s
      temp8$Source <- t
      temp8$Dataset <- d
      temp8$Frequency <- nrow(temp7) 
      temp9 <- rbind(temp9, temp8)
    }
  }
}
sum(temp9$Frequency)
temp9$X.X. <- NULL

write.csv2(temp9, "./Outputs/NRecordsSpeciesSource.csv")
