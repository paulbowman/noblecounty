library(dplyr); library(glue); library(scales); 
library(htmltools); library(sf); library(leaflet)
nc_data <-rio::import("county.csv")

election_title <- (nc_data[1,8])

nc_geo <- sf::st_read("map.geojson", stringsAsFactors = FALSE)

names(nc_geo)[2] <- "Precinct"

nc_map_data <- merge(nc_geo, nc_data, by.x = "id", by.y = "Precinct")

nc_map_data <- st_transform(nc_map_data, "+proj=longlat +datum=WGS84")

min_max_values <- range(nc_map_data$Margin, na.rm = TRUE)
gop_palette <- colorNumeric(palette = "Reds", domain=c(min_max_values[1], min_max_values[2]), na.color = "FF0000")
dem_palette <- colorNumeric(palette = "Blues", domain=c(min_max_values[1], min_max_values[[2]]))

gop_df <- nc_map_data[nc_map_data$Winner == "GOP",]
dem_df <- nc_map_data[nc_map_data$Winner == "Dem",]

gop_popup <- glue("<strong>Precinct {gop_df$Precinct}</strong><br /><strong>Winner: GOP</strong><br />Township: {gop_df$Township}<br />GOP: {scales::percent(gop_df$Rep, scale = 100)}<br />DEM: {scales::percent(gop_df$Dem, scale = 100)}<br />Margin: {scales::percent(gop_df$Margin, scale = 100)}")  %>%   lapply(htmltools::HTML)

dem_popup <- glue("<strong>Precinct {dem_df$Precinct}</strong><br /><strong>Winner: DEM</strong><br />Township: {dem_df$Township}<br /><br />DEM: {scales::percent(dem_df$Dem, scale = 100)}<br />GOP: {scales::percent(dem_df$Rep, scale = 100)}<br />Margin: {scales::percent(dem_df$Margin, scale = 100)}")  %>%   lapply(htmltools::HTML)

leaflet() %>%
  addProviderTiles("CartoDB.Positron")

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addPolygons(
    data = gop_df,
    fillColor = ~gop_palette(gop_df$Margin),
    label = gop_popup,
    stroke = TRUE,
    smoothFactor = 0.2,
    fillOpacity = 0.8,
    color = "#666",
    weight = 1
  ) %>%
  addPolygons(
    data = dem_df,
    fillColor = ~dem_palette(dem_df$Margin),
    stroke = TRUE,
    smoothFactor = 0.2,
    fillOpacity = 0.8,
    color = "#666",
    weight = 1
  ) 

