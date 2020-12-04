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

#Create color palette
colors <- c("chartreuse4", "chocolate1", "coral1", "chocolate4")





#+++++++ Create the map +++++++++++++++++++#
SIS <- read_sheet(sheet_url)

SIS$isocode <- countrycode(SIS$ISO, origin = 'iso3c', destination = 'iso2c')

map <- readOGR("data/gaul_simp_s.shp", verbose = FALSE)
map <- merge(map, SIS, by= "isocode", all.x= TRUE)
factpal <- colorFactor(colors, map$Stauts_SIS)
#Label
label <- paste("Country: ", map$`Country Name`,"<br/>", 
               "Status: ", map$Stauts_SIS, "<br/>",
               " ", map$Name_SIS)  %>%
  lapply(htmltools::HTML)




m <-leaflet(map)%>%
  addTiles() %>% 
  setView( lng = 2.34, lat = 48.85, zoom = 2 ) %>% 
  addProviderTiles("Esri.WorldImagery")%>% 
  
  addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = 1,
              fillColor = ~factpal(map@data$Stauts_SIS),
              weight = 10,
              opacity = 1,
              color = "white") %>% 
  addPolygons(
    fillColor = ~factpal(map@data$Stauts_SIS),
    weight = 2,
    opacity = 1,
    color = "white",
    dashArray = "3",
    fillOpacity = 0.7,
    highlight = highlightOptions(
      weight = 5,
      color = "#666",
      dashArray = "",
      fillOpacity = 0.7,
      bringToFront = TRUE),
    label = label,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "15px",
      direction = "auto"))%>%
  
  #Add legend to map
  
  addLegend(pal = factpal, values = map@data$Stauts_SIS, opacity = 0.7, title = NULL,
            position = "bottomright")
m
