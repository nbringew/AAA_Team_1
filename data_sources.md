# Data Sources

Overview of all external data sources used in this project.
The formal citation entries are available, or will be added, in `references.bib`.

---

## 1. Chicago Taxi Trips 2024–2026

**URL:** https://data.cityofchicago.org/Transportation/Taxi-Trips/ajtu-isnz/about_data

**Provider:** City of Chicago – Department of Business Affairs & Consumer Protection

**Access:** Chicago Data Portal via the Socrata Open Data API (dataset ID: `ajtu-isnz`)

**Data period:** 2024-01-01 to 2026-05-31

**Retrieval method:** Downloaded in weekly chunks via `notebooks/00_data_loading.ipynb`

**Description:**
Anonymized trip records for all licensed Chicago taxis. The dataset includes start and end
times, duration, distance, pickup and drop-off community areas and census tracts (partially
masked for privacy), fare components (fare, tips, tolls, and extras), payment type, and taxi
company. Coordinates represent either the centroid of the census tract, where available, or
the centroid of the community area.

**Use in the project:**
Primary dataset for all analyses. It is downloaded and cleaned in
`notebooks/00_data_loading.ipynb`. The annual files are combined into the shared analytical
dataset `data/chicago_taxi_2024_2026_clean.parquet`. Some analyses, particularly the GMM
hotspot analysis, additionally use the complete 2025 extract.

---

## 2. Historical Weather Data for Chicago 2024–2026

**URL:** https://open-meteo.com

**API endpoint:** `https://archive-api.open-meteo.com/v1/archive`

**Provider:** Open-Meteo (open-source weather API; no registration required)

**Data period:** 2024-01-01 to 2026-05-31

**Retrieval method:** Retrieved once via `notebooks/00_data_loading.ipynb`

**Description:**
Hourly historical weather data for Chicago (41.8781°N, 87.6298°W) covering the entire study
period. The dataset includes temperature at 2 m, apparent temperature, precipitation,
snowfall, wind speed, cloud cover, and WMO weather codes such as clear conditions, rain, and
snowfall. The time zone is America/Chicago.

**Use in the project:**
Joined with the taxi data by timestamp to analyze the influence of weather on trip demand and
fares. Stored as `data/chicago_weather_2024_2026_hourly.csv`.

---

## 3. Chicago Taxi Fare Structure (Placard Document)

**URL:** https://www.chicago.gov/content/dam/city/depts/bacp/publicvehicleinfo/ridesmartchicago/chicagotaxiplacardupdated.pdf

**Provider:** City of Chicago – Department of Business Affairs & Consumer Protection

**Accessed:** 2026-05-29

**Description:**
Official City of Chicago document specifying the applicable fare structure for licensed taxis.
It includes, among other items:

- **Base fare (flag pull):** $3.25 upon entering the taxi
- Distance-based and time-based charges
- Surcharges such as tolls and extras

**Use in the project:**
Justifies the lower bound `fare >= $3.25` in the data-cleaning process. Any fare below the base
fare is treated as an invalid trip.

---

## 4. Chicago Community Area Boundaries (GeoJSON/Shapefile)

**URL:** https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas-Map/cauq-8yn6

**Provider:** City of Chicago – Department of City Planning

**Accessed:** 2026-05-29

**Description:**
Official polygon geometries for Chicago's 77 community areas. The data include the community
area number (`area_numbe`) and name (`community`).

**Use in the project:**
Basis for spatial visualizations, including choropleth maps, and geographic joins with the taxi
data through `pickup_community_area` and `dropoff_community_area`.

---

## 5. Chicago City Boundary (GeoJSON)

**URL:** https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-City-Map/ewy2-6yfk

**Provider:** City of Chicago – Department of Planning and Development

**Access:** Manual GeoJSON download from the Chicago Data Portal

**Description:**
Official polygon geometry of Chicago's administrative city boundary.

**Use in the project:**
Defines the study area and provides background geometry for spatial visualizations in
`notebooks/01.3_data_exploration_spatial.ipynb` and
`notebooks/01.4_data_exploration_poi_spatial.ipynb`. Stored locally as
`data/chicago_boundaries.geojson`.

---

## 6. Chicago Census Tract Boundaries (GeoJSON)

**URL:** https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Census_Tracts/4hp8-2i8z

**Provider:** City of Chicago

**Access:** Manual GeoJSON download from the Chicago Data Portal

**Description:**
Polygon geometries of the census tracts within Chicago. Census tracts provide a finer spatial
level than community areas. Because of privacy masking in the taxi data, a tract assignment is
not available for every trip.

**Use in the project:**
Used for tract-level spatial exploration, maps, and forecasting models in
`notebooks/01.3_data_exploration_spatial.ipynb` and the tract notebooks under
`notebooks/03_prediction/`. Stored locally as `data/census_tracts_chicago.geojson`.

---

## 7. OpenStreetMap Points of Interest via Overpass Turbo

**URL:** https://overpass-turbo.eu/

**Data source:** OpenStreetMap Contributors

**Access:** Manual Overpass query and export as GeoJSON

**Description:**
Points of interest within Chicago obtained from OpenStreetMap. The query retrieves nodes with
tags from the categories `amenity`, `tourism`, `shop`, `leisure`, `office`, `healthcare`,
`historic`, `man_made`, `natural`, `craft`, `sport`, `place`, `railway`, `public_transport`,
`aeroway`, and `emergency`. The complete Overpass query is documented in
`notebooks/01.4_data_exploration_poi_spatial.ipynb`.

**Use in the project:**
Used to analyze the spatial relationship between POIs and taxi demand and to create a POI-count
feature for the tract-level forecasting models. Stored locally as `data/poi_chicago.geojson`.

**License note:**
OpenStreetMap data are licensed under the Open Database License (ODbL). Figures and other reuse
must retain attribution to OpenStreetMap Contributors.

---

## 8. EPEX Day-Ahead Electricity Prices via Fraunhofer Energy-Charts

**URL:** https://api.energy-charts.info/price

**Documentation:** https://api.energy-charts.info/

**Provider:** Fraunhofer Institute for Solar Energy Systems ISE

**Original market data:** ENTSO-E / EPEX SPOT

**Bidding zone:** Germany–Luxembourg (`DE-LU`)

**Data period:** 2025-01-01 to 2025-03-31

**License:** CC BY 4.0

**Description:**
Hourly day-ahead electricity prices in EUR/MWh. For the charging experiment, prices are
converted to EUR/kWh and linearly interpolated to the 15-minute decision intervals between
14:00 and 16:00.

**Use in the project:**
Provides real price profiles for the price-aware reinforcement-learning charging environment
in `notebooks/04_reinforcement_learning.ipynb`. The prepared price windows are cached locally
as `epex_windows_q1_2025.npy`; the API is used as a fallback when the cache is unavailable.

---

## 9. OpenStreetMap Map Tiles

**URL:** https://www.openstreetmap.org/

**Tile provider:** OpenStreetMap.Mapnik via `contextily`

**Data source:** OpenStreetMap Contributors

**Description and use in the project:**
Basemaps for selected spatial visualizations in the exploratory notebooks. The map tiles are
used only to provide visual context and are not included as training data in the models.
Attribution to OpenStreetMap Contributors must be retained.
