library(tidyverse)

temp <- read_delim("Private/INBODATAVR-209_divers_wbe_Belgie_Dump20190206.csv", 
                                                            ";", escape_double = FALSE, col_types = cols(aanleverdatum = col_date(format = "%Y-%m-%d"), 
                                                                                                         datum = col_date(format = "%Y-%m-%d"), 
                                                                                                         invoerdatum = col_date(format = "%Y-%m-%d")), 
                                                            locale = locale(decimal_mark = ",", grouping_mark = "."), 
                                                            trim_ws = TRUE)
temp1 <- read_delim("Private/INBODATAVR-209_divers_wbe_Belgie_Dump20190206_Bijkomend.csv", 
                                                            ";", escape_double = FALSE, col_types = cols(aanleverdatum = col_date(format = "%Y-%m-%d"), 
                                                                                                         datum = col_date(format = "%Y-%m-%d"), 
                                                                                                         invoerdatum = col_date(format = "%Y-%m-%d")), 
                                                            locale = locale(decimal_mark = ",", grouping_mark = "."), 
                                                            trim_ws = TRUE)
data_merged <- rbind(temp, temp1)
nrow(data_merged) == nrow(temp) + nrow(temp1)

table(data_merged$provincie, useNA = "ifany")

waalse_provs <- c("Brabant wallon (le)", "Hainaut (le)", "Liège", "Luxembourg (le)", "Namur")

waalse_data <- data_merged %>% 
  filter(provincie %in% waalse_provs)
vlaamse_data <- data_merged %>% 
  filter(!provincie %in% waalse_provs)

nrow(data_merged) == nrow(waalse_data) + nrow(vlaamse_data)

table(waalse_data$provincie, useNA = "ifany")
table(vlaamse_data$provincie, useNA = "ifany")

write_delim(waalse_data, "./Private/INBODATAVR-209_divers_wbe_Belgie_Dump20190206_Wallonia.csv", delim = ";")
write_delim(vlaamse_data, "./Private/INBODATAVR-209_divers_wbe_Belgie_Dump20190206_Flanders.csv", delim = ";")
