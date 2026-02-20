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

## Language and SEO Setup

- GitHub Linguist is configured to classify `*.nlogo` as NetLogo via `.gitattributes`.
- Repo metadata, topics, and GitHub Pages are configured for discoverability.

## License

MIT License. See `LICENSE`.
