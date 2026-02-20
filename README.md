# Religious Composition ABM

- :globe_with_meridians: [Project page](https://nikolailen.github.io/religious-composition-abm/)
- :bust_in_silhouette: Project contact: [Nikolai Len](https://www.linkedin.com/in/niklen/)

Agent-based modeling project in NetLogo for scenario analysis of religious composition change in France under migration, fertility, and mortality assumptions.

## What This Project Does

- Simulates yearly demographic dynamics with births, deaths, in-migration, and out-migration.
- Tracks composition for two modeled groups (`muslim` and `non-muslim`) over time.
- Produces short-horizon scenario outputs (30 years) and long-horizon threshold checks (majority crossing).
- Publishes findings via GitHub Pages (`index.md`).

## Main Model

- `france_religious_composition_abm.nlogo`

Key baseline assumptions used in the current report:

- `share-muslim-incoming = 0.52`
- `muslim-birth-rate = 2.81`
- `non-muslim-birth-rate = 1.56`
- `agents-coming = 3.36`
- `agents-leaving = 1.66`

## Datasets and Sources

- INSEE Premiere No. 2087 (published January 13, 2026): aggregate France demography for 2025.
- INSEE table on immigrant entries by country of birth (2023): used for migration-origin mapping.
- INSEE population and age-profile tables in `data/insee_2025/`: age structure, fertility schedule, mortality schedule.
- Pew Research Center dataset `Religious Composition 2010-2020`: country Muslim-share mapping.
- World Bank indicator `SP.DYN.TFRT.IN`: country total fertility rates used for proxy construction.

Repository source files used directly:

- `data/incoming_origin_religion_mapping_2023.csv`
- `data/incoming_origin_religion_summary_2023.json`
- `data/muslim_country_fertility_proxy.csv`
- `data/muslim_country_fertility_proxy_summary.json`
- `calibration_notes.md`

## Included Numeric Inputs (Current Baseline)

- Population scale basis: about 69.1 million people represented by 670 agents.
- INSEE aggregate anchors (2025): births about 645,000, deaths about 651,000, net migration about +176,000, TFR about 1.56.
- 2023 entrant total used in mapping: 346,900.
- Covered listed-country arrivals: 250,300 (72.15% coverage).
- Weighted Muslim share of covered countries: 52.15% (baseline uses `share-muslim-incoming = 0.52`).
- Residual-adjusted alternative share: 47.33% (kept as sensitivity reference).
- Majority-Muslim origin-country fertility proxy: 2.8057, rounded to `muslim-birth-rate = 2.81`.
- Migration flow rates in model: `agents-coming = 3.36`, `agents-leaving = 1.66`.

## Repository Structure

- `index.md`: main project report page.
- `calibration_notes.md`: calibration and data mapping documentation.
- `data/`: input mappings and simulation outputs.
- `scripts/run_paper_experiments.ps1`: NetLogo headless run orchestrator.
- `scripts/analyze_paper_runs.py`: summary table + figure generator.
- `figures/`: generated charts for the report.

## Reproduce Results

### Prerequisites

- NetLogo 6.4+ installed at `C:\Program Files\NetLogo 6.4.0\`
- Python 3.13+

### Install Python dependencies

```powershell
python -m pip install -r requirements-paper.txt
```

### Run 30-year scenario set

```powershell
powershell -ExecutionPolicy Bypass -File scripts/run_paper_experiments.ps1
```

### Rebuild summaries and figures

```powershell
python scripts/analyze_paper_runs.py
```

Outputs are written to:

- `data/paper_runs/`
- `figures/`

## Notes on Interpretation

- This is a scenario model, not a deterministic forecast.
- Results are sensitive to assumptions, especially migration composition and fertility differentials.
- See limitations in `index.md` and `calibration_notes.md`.

## License

MIT License. See `LICENSE`.
