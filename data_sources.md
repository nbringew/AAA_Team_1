# Datenquellen

Übersicht aller externen Datenquellen, die in diesem Projekt verwendet werden.
Die formalen Zitiereinträge befinden sich (bzw. werden ergänzt) in `references.bib`.

---

## 1. Chicago Taxi Trips 2025

**URL:** https://data.cityofchicago.org/Transportation/Taxi-Trips/ajtu-isnz/about_data  
**Betreiber:** City of Chicago – Department of Business Affairs & Consumer Protection  
**Abruf:** Chicago Data Portal über die Socrata Open Data API (Dataset-ID: `ajtu-isnz`)  
**Abgerufen am:** 2025 (laufend, wöchentliche Chunks via `notebooks/00_data_loading.ipynb`)

**Beschreibung:**  
Anonymisierte Fahrtdaten aller lizenzierten Chicagoer Taxis. Enthält u. a. Start- und Endzeitpunkt,
Dauer, Distanz, Pickup- und Dropoff-Community-Area sowie Census Tract (teilweise aus
Datenschutzgründen maskiert), Fahrpreis-Komponenten (Fare, Tips, Tolls, Extras),
Zahlungsart und Taxiunternehmen. Koordinaten entsprechen entweder dem Zentroid des
Census Tracts (wenn vorhanden) oder dem Zentroid der Community Area.

**Nutzung im Projekt:**  
Primärer Datensatz für alle Analysen. Geladen und bereinigt in `notebooks/00_data_loading.ipynb`,
gespeichert als `data/chicago_taxi_2025_clean.parquet`.

---

## 2. Historische Wetterdaten Chicago 2025

**URL:** https://open-meteo.com / API-Endpunkt: `https://archive-api.open-meteo.com/v1/archive`  
**Betreiber:** Open-Meteo (open-source Wetter-API, keine Registrierung erforderlich)  
**Abgerufen am:** 2025 (einmalig, `notebooks/00_data_loading.ipynb`)

**Beschreibung:**  
Stündliche historische Wetterdaten für Chicago (41.8781°N, 87.6298°W) für das Jahr 2025.
Enthält Temperatur (2 m), gefühlte Temperatur, Niederschlag, Schneefall, Windgeschwindigkeit,
Bewölkungsgrad und WMO-Wettercode (z. B. Klar, Regen, Schneefall). Zeitzone: America/Chicago.

**Nutzung im Projekt:**  
Verknüpfung mit den Taxidaten über den Zeitstempel, um Wettereinflüsse auf das Fahrtenaufkommen
und die Fahrpreise zu analysieren. Gespeichert als `data/chicago_weather_2025_hourly.csv`.

---

## 3. Chicago Taxi-Tarifstruktur (Placard-Dokument)

**URL:** https://www.chicago.gov/content/dam/city/depts/bacp/publicvehicleinfo/ridesmartchicago/chicagotaxiplacardupdated.pdf  
**Betreiber:** City of Chicago – Department of Business Affairs & Consumer Protection  
**Abgerufen am:** 2026-05-29

**Beschreibung:**  
Offizielles Dokument der Stadt Chicago mit der gültigen Tarifstruktur für lizenzierte Taxis.
Enthält u. a.:
- **Grundtarif (Flag Drop):** $3.25 beim Einsteigen
- Kilometerpreise und Zeittarife
- Zuschläge (z. B. Maut, Extras)

**Nutzung im Projekt:**  
Begründung der Untergrenze `fare >= $3.25` im Data-Cleaning-Schritt
(jeder Fare-Wert unterhalb des Grundtarifs ist kein gültiger Trip).

---

## 4. Chicago Community Areas – Grenzen (GeoJSON/Shapefile)

**URL:** https://data.cityofchicago.org/Facilities-Geographic-Boundaries/Boundaries-Community-Areas/igwz-8jzy/about_data  
**Betreiber:** City of Chicago – Department of City Planning  
**Abgerufen am:** 2026-05-29

**Beschreibung:**  
Offizielle Geometrien der 77 Community Areas der Stadt Chicago als geografische Grenzen
(Polygone). Enthält Community-Area-Nummer (`area_numbe`) und Name (`community`).

**Nutzung im Projekt:**  
Basis für räumliche Visualisierungen (Choropleth-Karten) und geografische Joins mit den
Taxidaten über `pickup_community_area` / `dropoff_community_area`.
