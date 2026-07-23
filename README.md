# Predicting Urban Taxi Demand and Smart Charging Strategies for Electric Fleets

This repository contains the Team 1 project for the course **Advanced Analytics and
Applications**. The project analyzes Chicago taxi trip data as a proxy for urban ride-hailing
demand, builds spatio-temporal demand prediction models, and studies an electric-taxi charging
problem with reinforcement learning.

The final report is written in Quarto and rendered to PDF. The analysis code is organized in
Jupyter notebooks, with the report text split into modular `.qmd` section files.

## Setup

The project uses Python and `uv` for dependency management. From the repository root, run:

```bash
uv sync
```

To make the environment available as a Jupyter kernel, run:

```bash
uv run python -m ipykernel install --user --name aaa-team-1 --display-name "Python (AAA Team 1)"
```

Quarto and a LaTeX distribution are required to render the PDF. If TinyTeX is not installed,
it can be installed via:

```bash
quarto install tinytex
```

## Render the Report

The main report file is `report.qmd`. To render the final PDF, run:

```bash
uv run quarto render report.qmd
```

The rendered PDF is written to:

```text
docs/report.pdf
```

## Execution Order

The notebooks are named in the intended analytical order. The report itself does not require
rerunning every notebook during rendering, but the following order reproduces the main analysis
workflow:

1. **Data exploration** — `notebooks/01_data_exploration/`
   - `00_data_loading.ipynb`: Loads the raw Chicago taxi data, fetches/loads weather data,
     applies the main cleaning pipeline, and writes the cleaned taxi dataset.
   - `01.1_data_exploration_taxis.ipynb`: Explores temporal patterns, trip characteristics,
     prices, and spatial pickup/dropoff summaries.
   - `01.2_data_exploration_weather.ipynb`: Explores hourly Chicago weather data and summarizes
     seasonal, daily, and extreme-weather patterns.
   - `01.3_data_exploration_spatial.ipynb`: Performs spatial exploration using Chicago boundaries,
     community areas, census tracts, and H3 hexagons.
   - `01.4_data_exploration_poi_spatial.ipynb`: Explores point-of-interest data and links POI
     context to the spatial demand analysis.

2. **Descriptive analytics** — `notebooks/02_descriptive_analytics/`
   - `02.1_trip_patterns.ipynb`: Analyzes descriptive trip-level and daily operating patterns.
   - `02.2_gmm.ipynb`: Identifies spatial demand hot spots with a Gaussian Mixture Model.

3. **Predictive analytics** — `notebooks/03_predictive_analytics/`
   Builds and evaluates Support Vector Regression and neural-network demand prediction models at
   different spatial and temporal resolutions:
   - `03.01_prediction_svm_CA_4h.ipynb`
   - `03.02_prediction_svm_CA_1h.ipynb`
   - `03.03_prediction_svm_tract.ipynb`
   - `03.04_prediction_nn_CA_4h.ipynb`
   - `03.05_prediction_nn_CA_1h.ipynb`
   - `03.06_prediction_nn_tract.ipynb`

4. **Reinforcement learning** — `notebooks/04_reinforcement_learning/`
   - `04_reinforcement_learning.ipynb`: Implements the smart-charging environment, trains DQN
     agents, compares them with heuristic baselines, and evaluates operational implications.

The `notebooks/archive/` directory contains earlier experiments and is not part of the primary
execution path.


## Report Structure

The report is assembled from `report.qmd` and the following section files:

- `sections/01-problem_description.qmd`
- `sections/02-data_description.qmd`
- `sections/03-data-preparation-details.qmd`
- `sections/04-descriptive-analytics.qmd`
- `sections/05-predictions.qmd`
- `sections/06-reinforcement.qmd`
- `sections/07-conclusions.qmd`
- `sections/08-appendix.qmd`

Quarto includes these files automatically when `report.qmd` is rendered.

## Data Files

The `data/` directory contains the local data files used by the notebooks, including:

- Chicago taxi trip data and cleaned taxi data
- hourly Chicago weather data
- Chicago community-area, census-tract, and city-boundary GeoJSON files
- OpenStreetMap point-of-interest data

Some raw data files are large. If a file is unavailable locally, the corresponding notebook
documents the data source and loading procedure.

## Reproducibility Notes

- Dependencies are managed through `pyproject.toml` and `uv.lock`.
- The final report can be reproduced with `uv run quarto render report.qmd`.
- Several notebooks are computationally expensive, especially the prediction and reinforcement
  learning notebooks. Their latest outputs are kept in the notebooks for inspection.
- The reinforcement learning notebook uses a simulated environment and may take longer to rerun
  because DQN agents are trained over many episodes.

## Repository Layout

```text
.
├── report.qmd
├── sections/
├── notebooks/
│   ├── 01_data_exploration/
│   ├── 02_descriptive_analytics/
│   ├── 03_predictive_analytics/
│   ├── 04_reinforcement_learning/
│   ├── archive/
│   └── prototyping.ipynb
├── data/
├── assets/
├── docs/
├── references.bib
├── pyproject.toml
└── uv.lock
```
