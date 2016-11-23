

library(dplyr)

setwd("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/")

print("step 1/7: provide the path of the file containing the tokenfile")
t <- Sys.time()
print(t)
tokenfile <- "//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/token_invasive.txt"
token <- readChar(tokenfile, file.info(tokenfile)$size) # read token
remove(tokenfile)

print("step 2/7: read the datafile, taking into account the token in the URL")
t <- Sys.time()
print(t)
dataset_url <- paste("https://raw.githubusercontent.com/inbo/invasive-t0-occurrences/master/data/processed/invasive_EU_listed_and_considered_with_joins.csv?token=",
                     token, sep = "" )
invasive_occ <- read.csv(dataset_url)
remove(token) #Remove token
remove(dataset_url)

print("step 3/7: check the head of the data file")
t <- Sys.time()
print(t)
head(invasive_occ)

print("step 4/7: check date of today")
t <- Sys.time()
print(t)
today <- Sys.Date()
today <- format(today,"%d_%m_%y")
filename <- paste("T0_SourceData_",today, ".", sep="")
print(filename)

print("step 5/7: check number of records")
t <- Sys.time()
print(t)
obs <- nrow(invasive_occ)
print(obs)

print("step 6/7: log outputs")
t <- Sys.time()
print(t)
iteration <- read.csv("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/iteration.csv")
temp <- data.frame(today)
temp$date <- today
temp$obs <- obs
iteration$X <- NULL
temp$today <- NULL
iteration <- rbind(iteration, temp)
write.csv(iteration, file = "//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/iteration.csv")
remove(iteration)
remove(temp)


print("step 7/7: Output SourceData")
t <- Sys.time()
print(t)
filepath <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/", filename)
write.csv(invasive_occ, filepath)
remove(filepath)

print("script complete")
t <- Sys.time()
print(t)
remove(t)
