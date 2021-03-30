#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

rm(list = ls())

#library(shiny)
library(leaflet)
library(raster)
library(rgdal)
library(googlesheets4)
library(countrycode)


#+++++++++++User defined variables++++++++++++#
#Data to be imported from google sheet
sheet_url <- "https://docs.google.com/spreadsheets/d/1QZj0VhWQtYyAl39E5xIRePR7eCBjWxo1rErF5S3vuu0/edit#gid=1572931594"


#+++++++ Create the points +++++++++++++++++++#
data <- read_sheet(sheet_url, sheet ="Pillar 4 Contact Network")




points <- readOGR("data/country_points.shp", verbose = FALSE)
colnames(data)[1] <- "ISO3CD"

#points@data[184,11] <- "SISLAC"
#SIS[199,6]<- "SISLAC"
points <- merge(points, data, by= "ISO3CD", all.x= TRUE)
#Relevel NAs
points$INSII <- ifelse(is.na(points$INSII), "Not_available", points$INSII)


#Icons
Icons <- iconList(Yes = makeIcon("data/checked.svg", iconWidth = 20, iconHeight =24),
                    NO = makeIcon("data/ic_invisible.svg", iconWidth = 20, iconHeight =24),
                  Not_available = makeIcon("data/ic_invisible.svg", iconWidth = 20, iconHeight =24))



#Label
label <- paste("Country: ", points$ROMNAM,"<br/>", 
               "Institute: ", points$`INSII (Institution)`,"<br/>", 
               "Contact: ", points$`INSII Contact`, "</a>"
               )  %>%
  lapply(htmltools::HTML)
data <- as.data.frame(points@data)

map_url <- "https://api.mapbox.com/styles/v1/iluotto/ckkh12bbl0wgu17qq5kqtioqc/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiaWx1b3R0byIsImEiOiJja2tneXZxd2kwOG9oMm9yanVxcWNyM3Y4In0.e0wAm5SiLRvPyIMMRNszjw"
map_att <- "© <a href='https://www.mapbox.com/map-feedback/'>Mapbox</a> Basemap © </a>"


m <-leaflet(points)%>%
  addTiles(urlTemplate=map_url, attribution = map_att) %>% 
  setView( lng = 2.34, lat = 48.85, zoom = 2 ) %>% 
  addMarkers(icon = ~Icons[as.factor(points$INSII)]
             ,popup = label 
             );m
  

