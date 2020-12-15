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
sheet_url <- "https://docs.google.com/spreadsheets/d/1YZ5FSXnz6g7Oy-jx_vN_81odxy6i1710DPKI08bnwSI/edit#gid=0"


#+++++++ Create the points +++++++++++++++++++#
SIS <- read_sheet(sheet_url)

SIS$isocode <- countrycode(SIS$ISO, origin = 'iso3c', destination = 'iso2c')


points <- readOGR("data/point_locations_world.shp", verbose = FALSE)

points@data[184,11] <- "SISLAC"
SIS[199,6]<- "SISLAC"
points <- merge(points, SIS, by= "isocode", all.x= TRUE)
#Relevel NAs
points$Stauts_SIS <- ifelse(is.na(points$Stauts_SIS), "Not_available", points$Stauts_SIS)
#colors

#Icons
Icons <- iconList(ongoing = makeIcon("data/gear.svg", iconWidth = 28, iconHeight =32),
                  completed = makeIcon("data/checked.svg", iconWidth = 28, iconHeight =32),
                  updating = makeIcon("data/updating.svg", iconWidth = 28, iconHeight =32)
                  ,No = makeIcon("data/ic_invisible.svg", iconWidth = 28, iconHeight =32)
                  ,Not_available =makeIcon("data/ic_invisible.svg", iconWidth = 28, iconHeight =32)
                 )



#Label
label <- paste("Country: ", points$`Country Name`,"<br/>", 
               "Status: ", points$Stauts_SIS, "<br/>",
               " ", points$SIS,"<br/>",
               "Link: ","<a href='",points$Link,"'>", points$Link ,"</a>"
               )  %>%
  lapply(htmltools::HTML)
data <- as.data.frame(points@data)


m <-leaflet(points)%>%
  addTiles() %>% 
  setView( lng = 2.34, lat = 48.85, zoom = 2 ) %>% 
  addProviderTiles("Esri.WorldPhysical")%>% 
  addMarkers(icon = ~Icons[as.factor(points$Stauts_SIS)]
             ,popup = label 
             );m
  

