

rm(list = ls())

#library(shiny)
library(leaflet)
library(googlesheets4)
library(countrycode)
library(htmlwidgets)

#+++++++++++User defined variables++++++++++++#
#Data to be imported from google sheet
sheet_url <- "https://docs.google.com/spreadsheets/d/1YZ5FSXnz6g7Oy-jx_vN_81odxy6i1710DPKI08bnwSI/edit#gid=0"
##sheet of interest for the map
sheet <- "NSIS"






#+++++++ Create the map +++++++++++++++++++#
SIS <- read_sheet(sheet_url, sheet =sheet)

SIS$isocode <- countrycode(SIS$ISO, origin = 'iso3c', destination = 'iso2c')


points <- readOGR("data/point_locations_world.shp", verbose = FALSE)

points@data[184,11] <- "SISLAC"
SIS[199,6]<- "SISLAC"
points <- merge(points, SIS, by= "isocode", all.x= TRUE)
#Relevel NAs
points$Stauts_SIS <- ifelse(is.na(points$Stauts_SIS), "Not_available", points$Stauts_SIS)

#Select only points with information
points <- subset(points, points$Stauts_SIS == "ongoing"|
                   points$Stauts_SIS == "completed"|
                   points$Stauts_SIS == "updating")

#Icons
Icons <- iconList(ongoing = makeIcon("data/gear.svg", iconWidth = 28, iconHeight =32),
                  completed = makeIcon("data/checked.svg", iconWidth = 28, iconHeight =32),
                  updating = makeIcon("data/updating.svg", iconWidth = 28, iconHeight =32
                  ))



#Label
label <- paste("Country: ", points$`Country Name`,"<br/>", 
               "Status: ", points$Stauts_SIS, "<br/>",
               " ", points$SIS,"<br/>",
               "Link: ","<a href='",points$Link,"'>", points$Link ,"</a>"
)  %>%
  lapply(htmltools::HTML)
data <- as.data.frame(points@data)

#map_url <- "https://api.mapbox.com/styles/v1/iluotto/ckkh12bbl0wgu17qq5kqtioqc/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiaWx1b3R0byIsImEiOiJja2tneXZxd2kwOG9oMm9yanVxcWNyM3Y4In0.e0wAm5SiLRvPyIMMRNszjw"
map_att <- "© <a href='https://www.mapbox.com/map-feedback/'>Mapbox</a> Basemap © </a>"
map_url <- "https://api.mapbox.com/styles/v1/iluotto/ckki00fpz0emt17pb31vfwpvb/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiaWx1b3R0byIsImEiOiJja2tneXZxd2kwOG9oMm9yanVxcWNyM3Y4In0.e0wAm5SiLRvPyIMMRNszjw"

m <-leaflet(points)%>%
  addTiles(urlTemplate=map_url, attribution = map_att) %>% 
  setView( lng = 2.34, lat = 48.85, zoom = 2 ) %>% 
  
  #addProviderTiles("Esri.WorldPhysical")%>% 
  addMarkers(icon = ~Icons[as.factor(points$Stauts_SIS)]
             ,popup = label 
  )
m

saveWidget(m, file="custom_maptile_RS.html")
