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
boundaries@data <- left_join(boundaries@data, povData, by=c("LSOA11CD"="LSOA"))

# labels
labels <- sprintf("%g%% turnover rate", boundaries$turnoverRate) %>% 
  lapply(htmltools::HTML)

# present on a map
pal <- colorFactor(c("grey", "green", "red"), domain = boundaries$sigtext)
leaflet(boundaries) %>%
  addTiles() %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addPolygons(fillColor = ~pal(sigtext),
              weight = 1,
              opacity = 1,
              color = "grey", 
              popup = labels)

