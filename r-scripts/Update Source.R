rm(list = ls())

library(dplyr)
library(googlesheets)
library(RCurl)
library(curl)
library(foreign)
library(httr)

print("step 1/8: provide the path of the file containing the tokenfile")
t0 <- Sys.time()
#token everywhere 
title <- gs_title(x="token_invasive", verbose = TRUE)
Token <- gs_auth()
gs_auth(token = Token)
tokenfile <- gs_read(title)
PAToken <- tokenfile$PAToken
userpwd <- tokenfile$userpwd
t1 <- Sys.time()
print(t1-t0)

print("step 2/8: Download and unzip de .zip file")
t0 <- Sys.time()
url <- "https://github.com/inbo/invasive-t0-occurrences/raw/master/data/processed/invasive_EU_listed_and_considered_with_joins.csv.zip"
zip_storage <- "./Private/Source/invasive_EU_listed_and_considered_with_joins.csv.zip"


content <- RCurl::getBinaryURL(url, httpheader = paste0("Authorization", PAToken))
tmp <- tempfile() 
write(content, file = tmp) 
t0_data <- read.csv(gzfile(tmp))
unlink(tmp)


getURLContent(req)

t1 <- Sys.time()
print(t1-t0)

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
title <- gs_title(x="Iteration", verbose = T)
iteration <- gs_read(title)
#iteration <- read.csv("//inbogerfiles/gerdata/OG_Faunabeheer/Projecten/Lopende projecten/INBOPRJ-10217-monitoring exoten/EASIN/r-scripts/Private/iteration.csv")
temp <- data.frame(today)
temp$X1 <- tail(x = iteration$X1,n=1)+1
temp$obs <- obs
temp$date <- today
temp$today <- NULL
gs_add_row(ss = title, 1, input=temp)
iteration <- gs_read(title)
remove(iteration)
remove(temp)


print("step 8/8: Output SourceData")
t <- Sys.time()
print(t)
filepath <- paste("./Output/", filename, sep="")
write.csv(invasive_occ, filepath)
#title <- gs_title(x="T0_SourceData", verbose = T)
#gs_ws_new(ss = title, ws_title = filename, input=invasive_occ) #geeft error Bad Request (HTTP 400)
remove(filepath)

print("script complete")
t <- Sys.time()
print(t)
remove(t)
