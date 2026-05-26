# AAA Team Assignment – Vollständige Aufgaben- & Teilaufgaben-Übersicht

---

## Aufgabe 1 – Datensammlung & Aufbereitung

### Taxi-Datensatz (Chicago Data Portal)
- Datensatz von https://data.cityofchicago.org herunterladen (Taxi Trips 2024)
- Datei ist sehr groß → mit Tools wie `sed` oder `xsv` vorfiltern (nicht benötigte Spalten/Zeilen entfernen)
- Datensatz vollständig beschreiben: Wie viele Zeilen? Welche Spalten? Was bedeuten sie? Gibt es fehlende Werte?
- Datenqualität prüfen: Ausreißer, fehlende Einträge, fehlerhafte Koordinaten identifizieren und bereinigen

### Wetterdaten
- Selbstständig passende Wetterdaten für Chicago besorgen (empfohlen: NOAA oder Kaggle)
- Stündliche Auflösung anstreben, da dies die Vorhersagekraft der Modelle stark beeinflusst
- Relevante Variablen auswählen: Temperatur, Niederschlag, Wind, Schnee, Bewölkung etc.
- Wetterdaten zeitlich mit den Taxifahrten zusammenführen (Join über Zeitstempel)

### Räumliche Diskretisierung (Hexagone)
- Chicago in ein Hexagon-Raster einteilen mithilfe der Bibliothek `h3` von Uber
- Verschiedene Hexagon-Größen (Auflösungsstufen) ausprobieren und vergleichen
- Taxifahrten den jeweiligen Hexagonen zuordnen (Start- und Endpunkt)
- Zensusbezirke (Census Tracts) als alternative räumliche Einheit behalten und ebenfalls nutzen

### Zeitliche Diskretisierung
- Fahrten in verschiedene Zeitfenster einteilen: stündlich, 4-stündlich, täglich
- Verschiedene Granularitäten ausprobieren und deren Einfluss auf die Analyse verstehen

### Optional: Points of Interest (POI)
- POI-Daten aus OpenStreetMap beziehen (z.B. Restaurants, Hotels, Bahnhöfe, Veranstaltungsorte)
- Prüfen, ob POI-Dichte die Nachfrage in einem Hexagon beeinflusst
- Nur wenn Zeit und Kenntnisse vorhanden – nicht verpflichtend

---

## Aufgabe 2 – Beschreibende (räumliche) Analyse

### Analyse der Fahrtmuster
- Startzeiten der Fahrten analysieren: Wann ist die Nachfrage am höchsten? (Tageszeit, Wochentag, Monat)
- Fahrtdauer und Fahrtlänge (in km und Zeit) untersuchen
- Preisverteilung analysieren: Durchschnitt, Median, Ausreißer
- Idle-Time zwischen Fahrten berechnen: Wie lange wartet ein Taxi durchschnittlich?
- Start- und Endorte auf einer Karte visualisieren

### Räumlich-zeitliche Auflösung vergleichen
- Dieselben Muster auf verschiedenen räumlichen Ebenen zeigen: Census Tract vs. große Hexagone vs. kleine Hexagone
- Dieselben Muster auf verschiedenen Zeitebenen zeigen: stündlich vs. 4-stündlich vs. täglich
- Erklären, was sich bei gröberer/feinerer Auflösung verändert und warum

### Mögliche Erklärungen liefern
- Beobachtete Muster mit realen Gegebenheiten verknüpfen (z.B. Rush Hour, Flughafen, Veranstaltungen, Wetter)
- Hypothesen aufstellen, warum bestimmte Bereiche oder Zeiten hohe Nachfrage zeigen

### Räumliche Hotspot-Erkennung (GMM / Kernel Density Estimation)
- Gaussian Mixture Models (GMM) anwenden, um Cluster hoher Nachfrage zu identifizieren
- Alternativ/ergänzend: Spatial Kernel Density Estimation (KDE) nutzen
- Ergebnisse auf einer Karte visualisieren und die gefundenen Hotspots benennen/erklären

---

## Aufgabe 3a – Vorhersagemodell mit Support Vector Machines (SVM)

### Zielvariable und Features definieren
- Zielvariable: Anzahl der Taxifahrten pro räumliche Einheit (Hexagon oder Census Tract) und Zeitfenster
- Features zusammenstellen: Tageszeit, Wochentag, Monat, Wetter, räumliche Einheit, ggf. POI

### Schrittweiser Modellaufbau
- Zunächst SVM ohne Kernel (linear) trainieren → Baseline-Ergebnis festhalten
- Dann verschiedene Kernel ausprobieren: RBF (Gauß), Polynomial, Sigmoid
- Mit jedem Schritt Komplexität erhöhen und Verbesserungen dokumentieren

### Hyperparameter-Optimierung
- Grid Search einsetzen, um optimale Werte für C (Regularisierung) und Gamma zu finden
- Ergebnisse der Grid Search übersichtlich darstellen

### Validierungsstrategie definieren
- Trainings-, Validierungs- und Testdatensatz sauber trennen
- Zeitliche Reihenfolge beim Split berücksichtigen (keine zukünftigen Daten im Training!)
- Begründen, warum welche Zeiträume für Training bzw. Test gewählt wurden

### Modellbewertung
- Fehlermetriken berechnen: MAE, RMSE, R²
- Erklären, was diese Zahlen praktisch bedeuten (z.B. „Das Modell liegt im Schnitt um X Fahrten daneben")
- Schwächen und Grenzen des Modells benennen

### Räumliche und zeitliche Auflösung variieren
- Testen, wie sich die Vorhersagegenauigkeit verändert, wenn man gröbere oder feinere Hexagone nutzt
- Testen mit Census Tracts statt Hexagonen – Unterschied dokumentieren
- Testen mit verschiedenen Zeitfenstern (stündlich vs. 4-stündlich vs. täglich)

### Verbesserungspotenziale benennen
- Welche Features könnten ergänzt werden?
- Welche Datenlücken limitieren das Modell?
- Was würde man in einem Folgeprojekt anders machen?

---

## Aufgabe 3b – Vorhersagemodell mit Neuronalem Netz (Deep Learning)

### Modellaufbau (Feedforward Neural Network)
- Netzarchitektur festlegen: Anzahl Schichten, Neuronen pro Schicht, Aktivierungsfunktionen
- Schrittweise Komplexität erhöhen (analog zur SVM-Vorgehensweise)
- Regularisierungsmaßnahmen einbauen: Dropout, L2-Regularisierung, Early Stopping

### Training und Optimierung
- Lernrate, Batch-Größe und Epochenzahl als Hyperparameter tunen
- Trainingsverlauf visualisieren (Loss-Kurve für Training und Validierung)
- Overfitting erkennen und gegensteuern

### Vergleich mit SVM
- Beide Modelle auf demselben Holdout-Testset mit gleicher räumlicher und zeitlicher Auflösung auswerten
- Fehlermetriken direkt gegenüberstellen (gleiche Metriken wie bei SVM)
- Diskutieren: Lohnt sich der Mehraufwand des Deep-Learning-Ansatzes?
- Rechenzeit und Interpretierbarkeit als zusätzliche Vergleichsdimensionen nennen

---

## Aufgabe 4 – Intelligentes Laden mit Reinforcement Learning

### Problemdefinition
- Szenario verstehen: Taxi kommt täglich um 14 Uhr heim, fährt um 16 Uhr los
- Ladeentscheidung alle 15 Minuten → 8 Entscheidungen pro Tag
- Energiebedarf beim Abfahren ist zufällig (Normalverteilung, z.B. μ=30 kWh, σ=5 kWh)

### Markov Decision Process (MDP) definieren
- Zustandsraum (States): aktueller Ladestand (SoC), aktuelle Uhrzeit, verbleibende Zeit bis Abfahrt
- Aktionsraum (Actions): diskrete Ladeoptionen – z.B. 0 kW, 7 kW (niedrig), 14 kW (mittel), 22 kW (hoch)
- Belohnungsfunktion (Reward): negative Ladekosten minus hohe Strafe bei zu wenig Energie bei Abfahrt
- Übergangslogik: wie verändert sich der Ladestand je nach gewählter Ladeleistung?

### Simulation (Umgebung) programmieren
- Einfache diskrete Ereignissimulation implementieren
- Umgebung nimmt Aktion entgegen und gibt neuen Zustand + Reward zurück
- Energiebedarf bei Abfahrt zufällig aus Normalverteilung ziehen
- Ladekosten als exponentielle Funktion der Ladeleistung implementieren: `Kosten(t,p) = Σ tₜ · p²`

### RL-Algorithmus trainieren
- Deep Q-Network (DQN) oder ähnlichen Algorithmus implementieren
- Agenten über viele Episoden trainieren lassen
- Lernfortschritt visualisieren: kumulativer Reward über Episoden

### Ergebnisse auswerten
- Optimale Ladestrategie des Agenten darstellen und erklären
- Vergleich: Wie unterscheidet sich die gelernte Strategie von einer einfachen Flat-Rate-Strategie?
- Sensitivitätsanalyse: Was passiert, wenn Energiebedarf höher/niedriger ist?

---

## Aufgabe 5 – Diskussion & Ausblick

### Implikationen für den Flottenbetreiber
- Was bedeuten die gefundenen Nachfragemuster konkret für den Betrieb? (z.B. Fahrzeugpositionierung, Schichtplanung)
- Was sagen die Vorhersagemodelle über die Planbarkeit der Nachfrage aus?
- Was empfiehlt die RL-Ladestrategie für den täglichen Betrieb?

### Weiterführende Analysen auf dem bestehenden Datensatz
- Welche Fragen könnten mit den vorhandenen Daten noch beantwortet werden?
- z.B. Preisoptimierung, Fahrereffizienz, Routen-Analyse

### Weitere externe Datenquellen
- Welche zusätzlichen Daten wären wertvoll? (z.B. Eventkalender, ÖPNV-Daten, Bevölkerungsdichte, Verkehr)
- Welche dieser Quellen wären realistisch beschaffbar?

### Ladeinfrastruktur-Empfehlung
- Abwägung: Private Ladestationen zu Hause vs. öffentliche Ladeinfrastruktur
- Kosten, Flexibilität, Skalierbarkeit vergleichen
- Empfehlung für den Kunden formulieren und begründen

### Kritische Reflexion der eigenen Methodik
- Wo liegen die Grenzen der verwendeten Modelle?
- Was würde man mit mehr Zeit oder Rechenkapazität anders machen?
- Wie gut lässt sich Taxi-Nachfrage auf Ride-Hailing übertragen? (Proxy-Qualität diskutieren)
