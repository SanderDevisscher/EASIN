
####Data Importeren####
update <- "N"

iteration <- read.csv("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/iteration.csv")
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
EuConc <- subset(Brondata, euConcernStatus == "listed")
EuPrep <- subset(Brondata, euConcernStatus == "under preparation")
EuCons <- subset(Brondata, euConcernStatus == "under consideration")


