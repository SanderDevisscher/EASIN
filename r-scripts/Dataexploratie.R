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
      temp4$Percentage observations <- (somjaar/somtotaal)*100
      temp5 <- temp4
      temp6 <- rbind(temp6, temp5)
      }
  }

for(t in Afkap){
temp <- subset(temp6, jaar >= t)

plot <- ggplot(temp, aes(year, Percentage observations))
plot <- plot + geom_bar( stat="identity")
plot <- plot + facet_wrap(~soort)
print(plot)

plotname <- paste("Percentagewnmn_na", t, ".jpeg", sep = "")

ggsave(plotname, plot = plot, width = 20/2.54, height = 20/2.54)
}
