---
title: BSomuah_FlameSafe.R
author:Beatrice
date: '2025-04-23'
---
  # Load required libraries for spatial data handling and mapping
  library(terra)         # For working with spatial vector and raster data
library(leaflet)       # For creating interactive web maps
library(sf)            # For handling simple feature spatial data
library(htmlwidgets)   # For saving interactive maps as HTML files

# Load shapefiles for fire perimeters, schools, and hospitals from local directories
fire <- vect("C:/Users/somua/OneDrive/Desktop/Hackaton/Data/2024_Fire_Permeter.shp")
schools <- vect("C:/Users/somua/OneDrive/Desktop/Hackaton/Data/BC_Schools.shp")
hospitals <- vect("C:/Users/somua/OneDrive/Desktop/Hackaton/Data/BC_Health_Care_Facilities_(Hospital)/BC_Health_Care_Facilities_(Hospital).shp")

# Reproject the spatial data to WGS84 coordinate reference system (EPSG:4326)
# This CRS is required for compatibility with leaflet interactive maps
fire_wgs <- project(fire, "EPSG:4326")
schools_wgs <- project(schools, "EPSG:4326")
hospitals_wgs <- project(hospitals, "EPSG:4326")

# Convert terra SpatVector objects to sf (Simple Features) objects
# sf package is often used with leaflet for easier spatial operations and plotting
fire_wgs_sf <- st_as_sf(fire_wgs)
schools_wgs_sf <- st_as_sf(schools_wgs)
hospitals_wgs_sf <- st_as_sf(hospitals_wgs)

# Ensure all spatial data is in the correct CRS (WGS84)
fire_wgs_sf <- st_transform(fire_wgs_sf, 4326)
schools_wgs_sf <- st_transform(schools_wgs_sf, 4326)
hospitals_wgs_sf <- st_transform(hospitals_wgs_sf, 4326)

# Fix invalid geometries in fire polygons:
# Remove any invalid features first to avoid errors in spatial operations
fire_wgs_sf <- fire_wgs_sf[st_is_valid(fire_wgs_sf), ]
# Attempt to repair any remaining invalid geometries
fire_wgs_sf <- st_make_valid(fire_wgs_sf)

# Create a buffer zone of 5 km (5000 meters) around fire perimeters to identify at-risk areas
fire_buffer <- buffer(fire_wgs, width = 5000)
# Convert buffer to sf object for spatial operations with other data
fire_buffer_sf <- st_as_sf(fire_buffer)

# Fix invalid geometries in buffer polygons (same process as above)
fire_buffer_sf <- fire_buffer_sf[st_is_valid(fire_buffer_sf), ]
fire_buffer_sf <- st_make_valid(fire_buffer_sf)

# Identify schools and hospitals located within the 5 km fire buffer zones (i.e., at risk)
schools_at_risk <- schools_wgs_sf[fire_buffer_sf, ]
hospitals_at_risk <- hospitals_wgs_sf[fire_buffer_sf, ]

# Extract XY coordinates (latitude and longitude) from sf geometries for plotting markers
schools_coords <- st_coordinates(schools_wgs_sf)[, 1:2]           # All schools
schools_at_risk_coords <- st_coordinates(schools_at_risk)[, 1:2]   # Schools within buffer
hospitals_coords <- st_coordinates(hospitals_wgs_sf)[, 1:2]       # All hospitals
hospitals_at_risk_coords <- st_coordinates(hospitals_at_risk)[, 1:2] # Hospitals within buffer

# Create data frames combining coordinates and attributes for leaflet markers
schools_wgs_df <- data.frame(schools_coords, name = schools_wgs_sf$name)               # All schools with names
schools_at_risk_df <- data.frame(schools_at_risk_coords, name = schools_at_risk$name)  # At-risk schools with names
hospitals_wgs_df <- data.frame(hospitals_coords, OCCUPANT_N = hospitals_wgs_sf$OCCUPANT_N)              # All hospitals with occupant names
hospitals_at_risk_df <- data.frame(hospitals_at_risk_coords, OCCUPANT_N = hospitals_at_risk$OCCUPANT_N) # At-risk hospitals with occupant names

# Build the interactive leaflet map
flame_safe_map <- leaflet() %>%
  # Add base map tiles with CartoDB Positron style for a clean background
  addProviderTiles(providers$CartoDB.Positron) %>%
  
  # Add fire zone polygons with red fill and dark red border
  addPolygons(data = fire_wgs_sf,
              fillColor = "#FF4500", weight = 1, color = "#8B0000", opacity = 1, fillOpacity = 0.5,
              group = "Fire Zones", popup = ~paste("Fire Zone ID:", fire_wgs_sf$ID)) %>%
  
  # Add 5 km fire buffer polygons with orange fill and border
  addPolygons(data = fire_buffer_sf,
              fillColor = "#FFA500", color = "#FF6347", weight = 1, fillOpacity = 0.3,
              group = "5km Fire Buffer", popup = "5km Fire Buffer Area") %>%
  
  # Add circle markers for all schools (blue, smaller radius)
  addCircleMarkers(data = schools_wgs_df,
                   lat = ~Y, lng = ~X, radius = 4, color = "#0000FF", stroke = FALSE, fillOpacity = 0.7,
                   label = ~name, group = "All Schools", popup = ~paste("School:", name)) %>%
  
  # Add circle markers for schools at risk (gold, larger radius, outlined)
  addCircleMarkers(data = schools_at_risk_df,
                   lat = ~Y, lng = ~X, radius = 6, color = "#FFD700", stroke = TRUE, weight = 2, fillOpacity = 0.8,
                   label = ~name, group = "Schools at Risk", popup = ~paste("School at Risk:", name)) %>%
  
  # Add circle markers for all hospitals (lime green, smaller radius)
  addCircleMarkers(data = hospitals_wgs_df,
                   lat = ~Y, lng = ~X, radius = 4, color = "#32CD32", stroke = FALSE, fillOpacity = 0.7,
                   label = ~OCCUPANT_N, group = "All Hospitals", popup = ~paste("Hospital:", OCCUPANT_N)) %>%
  
  # Add circle markers for hospitals at risk (purple, larger radius, outlined)
  addCircleMarkers(data = hospitals_at_risk_df,
                   lat = ~Y, lng = ~X, radius = 6, color = "#800080", stroke = TRUE, weight = 2, fillOpacity = 0.8,
                   label = ~OCCUPANT_N, group = "Hospitals at Risk", popup = ~paste("Hospital at Risk:", OCCUPANT_N)) %>%
  
  # Add layer controls for toggling visibility of different feature groups
  addLayersControl(
    overlayGroups = c("Fire Zones", "5km Fire Buffer", "All Schools", "Schools at Risk", "All Hospitals", "Hospitals at Risk"),
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  
  # Add a map title/control in the top right corner
  addControl("<strong>FlameSafe</strong><br>Fire Risk Analysis Map", position = "topright") %>%
  
  # Add a legend to explain colors and symbols in the bottom right corner
  addLegend(position = "bottomright", 
            colors = c("#FF4500", "#FFA500", "#0000FF", "#FFD700", "#32CD32", "#800080"), 
            labels = c("Fire Zones", "Fire Buffer", "Schools", "Schools at Risk", "Hospitals", "Hospitals at Risk"), 
            title = "Legend")

# Save the interactive map as an HTML file
saveWidget(flame_safe_map, "FlameSafe_map.html")

# Optionally display the map in the RStudio Viewer pane
flame_safe_map
