

library(dplyr)

print("step 1/8: provide the path of the file containing the tokenfile")
t <- Sys.time()
print(t)
#Private at Work
#tokenfile <- "//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/token_invasive.txt"
#Private at Home
tokenfile <- "C://Users/blauw/Documents/GitHub/EASIN/r-scripts/Private"
token <- readChar(tokenfile, file.info(tokenfile)$size) # read token
remove(tokenfile)

print("step 2/8: read the datafile, taking into account the token in the URL")
t <- Sys.time()
print(t)
dataset_url <- paste("https://raw.githubusercontent.com/inbo/invasive-t0-occurrences/master/data/processed/invasive_EU_listed_and_considered_with_joins.csv?token=",
                     token, sep = "" )
invasive_occ <- read.csv(dataset_url)
remove(token) #Remove token
remove(dataset_url)
table(invasive_occ$gbifapi_acceptedScientificName,invasive_occ$euConcernStatus)

print("step 3/8: Check success of import")
if(exists("invasive_occ")){
  print("import succesfull")
}else{
  print("import failed")
  print("check for stale token")
  stop("goto https://github.com/inbo/invasive-t0-occurrences/blob/master/data/processed/")
}


print("step 4/8: check the head of the data file")
t <- Sys.time()
print(t)
head(invasive_occ)

print("step 5/8: check date of today")
t <- Sys.time()
print(t)
today <- Sys.Date()
today <- format(today,"%d_%m_%y")
filename <- paste("T0_SourceData_",today, ".csv", sep="")
print(filename)

print("step 6/8: check number of records")
t <- Sys.time()
print(t)
obs <- nrow(invasive_occ)
print(obs)

print("step 7/8: log outputs")
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


print("step 8/8: Output SourceData")
t <- Sys.time()
print(t)
filepath <- paste("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/Data/", filename, sep="")
write.csv(invasive_occ, filepath)
remove(filepath)

print("script complete")
t <- Sys.time()
print(t)
remove(t)
