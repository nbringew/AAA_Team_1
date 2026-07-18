# Taxi Demand Prediction — Assumptions & Decisions

Quick-reference overview of the modeling choices behind `03.04`/`03.05` (SVM) and the planned
NN/tract-level work. See the notebooks themselves for full rationale.

## Task & Scope

- Predict taxi pickup demand (trip **counts**) per spatial unit per time window.
- **Course constraint**: no lagged/autoregressive demand features — only exogenous time,
  weather, and spatial-identity inputs.

## Data & Time Split

- Chicago taxi trips 2024–2026 (cleaned parquet) + hourly weather.
- Chronological holdout: **train** 2024-01-01–2025-12-31 (2 full years), **test**
  2026-01-01–2026-05-31 (5 months). June 2026+ excluded (portal reporting lag).
- **Time resolution**: 4-hour windows.
- `TimeSeriesSplit` (3 folds) for all cross-validation / `GridSearchCV` — no look-ahead.
- **Complete zero-filled grid** (every unit × every window), not just observed
  combinations — so models see genuine zero-demand windows too. No demand-threshold exclusion.

## Spatial Resolutions

- **Community area** (77 units) — implemented first, primary/validated resolution.
- **Census tract** (878 units) — implemented as an extension.
  - `pickup_census_tract` in the source data is **not usable**: only 44.6% populated, and
    stored as `float32`, which corrupts 11-digit tract GEOIDs on rounding.
  - Fix: spatial join of pickup lat/lon against tract polygons instead (100% match rate).
  - Spatial identity in **two layers**: the same 76 community-area dummies (via each tract's
    parent community area) + tract-level covariates (POI count, tract area, distance to each
    of 6 empirically-derived demand hot spots via GMM over pickup coordinates), rather than
    ~800 raw one-hot tract dummies.

## Architecture

- **One pooled model per resolution** (all spatial units trained together, spatial identity
  as a feature) rather than one model per unit. Reasons: scales to census-tract count, and
  keeps panel-building/evaluation code identical across resolutions and across SVM vs. NN.

## Features

- Time: hour/day-of-week/month sin-cos (+ 2nd harmonic for hour and day-of-week), is_weekend,
  is_holiday.
- Weather: temperature, precipitation, snowfall, wind speed, cloud cover.
- Spatial identity: community-area one-hot dummies (76, `drop_first`).
- Tract-level only: POI count (log), tract area (log), distance to each of 6 GMM-derived
  demand hot spots (km).
- **Dummies are never scaled** — `StandardScaler` on continuous features only, dummies pass
  through raw (scaling them distorted the RBF kernel's distance calc and slowed `LinearSVR`
  convergence ~5x).

## Target & Loss

- Target: `log1p(count)`; predictions back-transformed via clipped `expm1` (log-prediction
  clipped to ±20 pre-`expm1` to avoid overflow on an unstable fit).
- Models fit under **SVR's epsilon-insensitive loss** on the log-transformed target.

## Models

- **Profile baseline**: train-set mean demand per (hour, weekday) per unit — the reference
  model, not a candidate.
- **LinearSVR (no kernel), full data** — the primary/credible SVM entry at every resolution.
- **Kernel SVR** (poly/rbf/sigmoid/linear): exact kernel SVR is O(n²)–O(n³), infeasible on the
  full training set (338k community rows / 3.85M tract rows) → subsampled to 20k rows for a
  naive comparison and for `GridSearchCV` tuning.
  - Finding: subsample-tuned kernel results are **high-variance and unreliable** — a
    hyperparameter combo can look best-of-five on one subsample draw and worse-than-baseline
    on the true test set.
  - **Decision**: not repeated at tract level (thinner data fraction → worse, not better).
    `LinearSVR` stays the credible SVM entry; one small kernel snapshot kept only for
    documentation, not model selection.
  - A `Nystroem` approximate-kernel attempt (to get a scalable non-linear SVM) failed
    (numerically unstable) — unresolved follow-up.
- **Feedforward NN** — planned, not yet implemented. Trains via mini-batch gradient descent
  (~linear in row count), so it does **not** hit the kernel-SVR scalability wall and is
  expected to train on the full data at either resolution.

## Known Issues

- **Pooled `LinearSVR` at tract level effectively ignores time and underperforms the profile
  baseline**: median skill -0.259 (90 of 179 tracts negative), pooled R²=0.026 vs. baseline's
  0.860, weighted RMSE 355 vs. 133. GMM hotspot-distance features absorb 99.6% of total
  |coefficient| mass despite being only 6 of 25 continuous features; time/calendar and weather
  coefficients are effectively zero. The model has learned each tract's average demand level
  from its distance to the nearest hot spot rather than any time-varying signal — top-3-tract
  plots show predictions flat near zero across an entire evaluation week while actual and
  baseline demand both trace the daily cycle. Same pooling-loses-to-baseline pattern as
  community-area resolution, but far worse: 179 pooled units (vs. 77) means between-unit
  demand variance dominates the loss even more, and the hotspot-distance covariates give the
  optimizer an easy per-unit shortcut a purely time-based fit wouldn't have.
- **Decision**: not fixed by dropping the hotspot-distance features. The mechanism isn't
  specific to that feature family — a pooled linear model will always prioritize between-unit
  level differences over within-unit time dynamics when the former dominates the loss; removing
  hotspot distance would likely just push the same shortcut onto the coarser community-area
  dummies, at the cost of real signal. Kept as-is and documented as a limitation rather than
  re-run; revisiting would need per-unit time interactions, not feature removal.

## Model Comparison Methodology

- Metrics: R², MAE, RMSE — computed both **pooled** (all rows at once) and **per spatial
  unit**.
- **Pooled R²/MAE/RMSE are a sanity check only**, not how models are compared: demand varies
  ~3 orders of magnitude across units, so pooled numbers are dominated by a handful of
  highest-volume units and hide poor performance elsewhere.
- **Skill score** (the actual comparison metric): `1 - MAE_model / MAE_baseline`, computed
  per unit (a ratio, so unit scale cancels out — makes units of very different demand
  comparable).
- Aggregated two ways:
  - **Demand-weighted mean skill (headline)** — weighted by each unit's own median demand;
    matches the business case (fleet allocated mostly to high-demand areas).
  - **Unweighted median skill (guard rail)** — every unit counted equally; catches a model
    that only wins by nailing a few huge units while losing almost everywhere else.
  - Decision rule: pick the winner on demand-weighted skill, but treat a **large gap** between
    the two as a red flag to investigate, not noise to average away.

## Known Data-Quality Fixes Applied

- Dummy columns excluded from scaling (see Features).
- `pickup_census_tract` replaced by a lat/lon → tract spatial join (see Spatial Resolutions).
- 9 of 878 tracts have no official community-area code (`tract_comm = 0`, likely water/edge
  artifacts) — kept in the panel, encoded as all-zero community-area dummies rather than
  dropped or given a spurious 78th category.

## Not Yet Done

- Feedforward NN implementation and SVM-vs-NN comparison.
- Rolling-origin backtest and 1-hour resolution (present in `03.04`, not yet repeated here).
- Fixing the failed `Nystroem` scalable-kernel approximation.
