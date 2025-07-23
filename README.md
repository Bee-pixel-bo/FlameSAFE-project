
# FlameSAFE: Wildfire Risk Mapping for Critical Infrastructure

## Overview

FlameSAFE is an interactive wildfire risk mapping tool designed to identify and visualize critical infrastructure such as schools and hospitals, that are vulnerable to wildfire threats in British Columbia. The tool highlights facilities located within a 5 km buffer zone around wildfire perimeters, providing valuable insights for decision-makers to support proactive planning, resource allocation, and emergency response.

The project uses R programming and spatial analysis libraries to process geospatial data and create an interactive web map, which is saved as an HTML file for easy sharing and visualization.

---

## Live Project

You can view the interactive FlameSAFE map here:  
[FlameSAFE Interactive Map](https://bee-pixel-bo.github.io/hackaton_dashboard/)

---

## Features

- Visualizes 2024 wildfire perimeters and 5 km buffer zones around fire areas.  
- Identifies schools and hospitals within the buffer zones considered at risk.  
- Provides interactive map layers for fire zones, buffers, schools, and hospitals with popups and labels.  
- Includes a custom legend and layer controls for an enhanced user experience.

---

## Data Sources

- **Wildfire Perimeters (2024):** Geo.ca  
- **Public Schools & Hospitals:** OpenStreetMap (OSM)

---

## Getting Started

### Prerequisites

Ensure R is installed on your system. Install the following R packages if they are not already installed:

```r
install.packages(c("terra", "leaflet", "sf", "htmlwidgets"))
```

### Running the Code

1. Clone or download this repository.  
2. Place the required shapefiles in an accessible directory and update the file paths in the script accordingly.  
3. Run the `FlameSAFE_script.R` script to process the data and generate the interactive map.  
4. The map will be saved as `FlameSafe_map.html`, which can be opened in any modern web browser or hosted online.

---

## File Structure

- `FlameSAFE_script.R` — The main R script performing data processing and map creation.  
- `FlameSafe_map.html` — The resulting interactive web map is saved as an HTML file.

---

## Contact

For questions or collaborations, please reach out at [somuahbeatrice2000@gmail.com].

---


