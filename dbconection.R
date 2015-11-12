library("RMySQL")

credenciales <- read.csv("~/Documents/pvdo_info_conexion.txt", sep="", stringsAsFactors = FALSE)
credenciales <- credenciales[credenciales$dbname=='forecast-playground', ]

forecastdb <- dbConnect(RMySQL::MySQL(),
                        user=credenciales$dbuser[1],
                        password=credenciales$dbpassword[1],
                        host=credenciales$dbhost[1],
                        dbname=credenciales$dbname[1])
rm(credenciales)
readQuery<-function(file) paste(readLines(file), collapse="\n")
