#################################
# poverty turnover map
#################################

library(dplyr)
library(leaflet)

# read data with area codes
povData <- read.csv("turnoverrateByLSOA.csv")

# collect boundary data
areaCodes <- povData$LSOA
for (i in 1:length(areaCodes)) {
  boundary <- geojsonio::geojson_read(paste0("http://statistics.data.gov.uk/boundaries/", areaCodes[i], ".json"), what = "sp")
  if (i==1) assign("boundaries", boundary) else assign("boundaries", maptools::spRbind(boundaries, sp::spChFIDs(boundary, as.character(i))))
}

# link boundary data to attribute data
mapdata <- boundaries 
mapdata@data <- left_join(mapdata@data, povData, by=c("LSOA11CD"="LSOA"))

# labels
labels <- sprintf("%g%% turnover rate<br />%d poor families in 2010", mapdata$turnoverRate, mapdata$total) %>% 
  lapply(htmltools::HTML)

# present on a map
pal <- colorFactor(c("grey", "blue", "orange"), domain = mapdata$sigtext)
leaflet(mapdata) %>%
  addTiles() %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addPolygons(fillColor = ~pal(sigtext),
              weight = 1,
              opacity = 1,
              color = "grey", 
              fillOpacity = 0.3,
              label = labels, 
              highlight = highlightOptions(
                weight = 2,
                color = "#666",
                fillOpacity = 0.7,
                bringToFront = TRUE)) %>% 
  addLegend(pal = pal, values = ~sigtext, title = "Poverty turnover rate (cf 53% city mean)",
            position = "bottomleft", opacity = 0.7)
