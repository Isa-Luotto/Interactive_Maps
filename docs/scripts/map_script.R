#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

rm(list = ls())

library(shiny)
library(leaflet)
library(raster)
library(rgdal)
#library(sp)
library(googlesheets4)
library(shinyWidgets)
library(tidyverse)
library(DT)
library(countrycode)

#Data to import and set the conditions
sheet_url <- "https://docs.google.com/spreadsheets/d/1YZ5FSXnz6g7Oy-jx_vN_81odxy6i1710DPKI08bnwSI/edit#gid=0"
SIS <- read_sheet(sheet_url)

SIS$isocode <- countrycode(SIS$ISO, origin = 'iso3c', destination = 'iso2c')

map <- readOGR("data/gaul0_asap.shp")
map <- merge(map, SIS, by= "isocode", all.x= TRUE)


#Create color palette
factpal <- colorFactor(topo.colors(4), map$Stauts_SIS)
#Add Label
label <- paste("Country: ", map$`Country Name`,"<br/>", 
               "Status: ", map$Stauts_SIS, "<br/>",
               " ", map$Name_SIS)  %>%
  lapply(htmltools::HTML)

    m <-leaflet(map)%>%
                                  
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
  

  

