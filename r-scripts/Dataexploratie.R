library(dplyr)
library(ggplot2)


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
    Jaren <- unique(temp2$year)
    for(j in Jaren){
      temp3 <- subset(temp2, year == j)
      somjaar <- nrow(temp3)
      temp4$year <- j
      temp4$soort <- s
      temp4$somjaar <- somjaar
      temp4$somtotaal <- somtotaal
      temp4$Percentage_observations <- (somjaar/somtotaal)*100
      temp5 <- temp4
      temp6 <- rbind(temp6, temp5)
      }
  }

for(t in Afkap){
temp <- subset(temp6, year >= t)

plot <- ggplot(temp, aes(year, Percentage_observations))
plot <- plot + geom_bar( stat="identity")
plot <- plot + facet_wrap(~soort)
print(plot)

plotname <- paste("Percentagewnmn_na", t, ".jpeg", sep = "")

ggsave(plotname, plot = plot, width = 20/2.54, height = 20/2.54)
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
      temp4 <- rbind(temp4, temp3)
    }
    
  }
}

temp5 <- temp4[order(temp4$soort, temp4$jaar),]

temp5 <- mutate(group_by(temp5, soort, jaar), cumsum = cumsum(uniekeutm))

temp7 <- data.frame()
soorten <- unique(temp5$soort)
for (s in soorten){
  temp6 <- subset(temp5, soort == s)
  maxhokken <- length(unique(temp6$utm1))
  temp6$maxhokken <- maxhokken
  temp7 <- rbind(temp7, temp6)
}

temp7$Percentage_Locations <- (temp7$cumsum/temp7$maxhokken)*100

temp11 <- data.frame()
temp10 <- data.frame("x")
soorten <- unique(temp7$soort)
for(s in soorten){
  temp8 <- subset(temp7, soort == s)
  jaren <- unique(temp8$jaar)
  for(j in jaren){
    temp9 <- subset(temp8, jaar == j)
    Percentage_Locations <- max(temp9$Percentage_Locations)
    temp10$soort <- s
    temp10$jaar <- j
    temp10$Percentage_Locations <- Percentage_Locations
    temp11 <- rbind(temp11, temp10)
  }
}


for(t in Afkap){
  temp <- subset(temp11, jaar >= t)
  
  plot <- ggplot(temp, aes(jaar, Percentage_Locations))
  plot <- plot + geom_bar(stat="identity")
  plot <- plot + facet_wrap(~soort, ncol = 2, scales = "fixed")
  print(plot)
  
  plotname <- paste("Percentagelocs_na", t, ".jpeg", sep = "")
  
  ggsave(plotname, plot = plot, width = 20/2.54, height = 40/2.54)
}

for(t in Afkap){
  temp <- subset(temp4, jaar >= t)
  
  plot <- ggplot(temp, aes(jaar, uniekeutm))
  plot <- plot + geom_bar(stat="identity")
  plot <- plot + facet_wrap(~soort)
  print(plot)
  
  plotname <- paste("locs_na", t, ".jpeg", sep = "")
  
  ggsave(plotname, plot = plot, width = 20/2.54, height = 20/2.54)
}
