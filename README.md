# France Religious Composition ABM

- 🌐 [Project page](https://nikolailen.github.io/france-religious-composition-abm/)
- 👤 Project contact: [Nikolai Len](https://www.linkedin.com/in/niklen/)

NetLogo agent-based model (ABM) project for scenario analysis of religious composition change in France under migration, fertility, and mortality assumptions.

## Repository Contents

- `france_religious_composition_abm.nlogo`: main NetLogo model.
- `index.md`: GitHub Pages report.
- `calibration_notes.md`: calibration assumptions and data mapping notes.
- `data/`: input mappings and generated run outputs.
- `scripts/`: reproducible experiment and analysis scripts.
- `figures/`: charts generated from simulation runs.

## Quick Start

1. Install NetLogo 6.4+.
2. Run scenarios:
   - `powershell -ExecutionPolicy Bypass -File scripts/run_paper_experiments.ps1`
3. Rebuild summaries and figures:
   - `python scripts/analyze_paper_runs.py`

## Tech Stack

- NetLogo language (`*.nlogo`)
- Python (analysis pipeline)
- GitHub Pages (project site)

## License

MIT License. See `LICENSE`.
