# Calibration Notes (INSEE-Based)

Updated on: February 20, 2026.

## Data used

- INSEE Premiere No. 2087 (published January 13, 2026): 2025 demographic summary for France.
  - Population at January 1, 2026: about 69.1 million.
  - Births in 2025: about 645,000.
  - Deaths in 2025: about 651,000.
  - Total fertility indicator in 2025: about 1.56.
  - Net migration estimate in 2025: about +176,000.
- INSEE table: population by single year of age (includes provisional 2026 age structure).
- INSEE table: age-specific fertility rates (latest detailed year in file: 2022).
- INSEE table: age-group mortality rates by sex (latest detailed year in file: 2022).
- INSEE/INED TeO2 publication: around 10% of ages 18-59 identify as Muslim (2019-2020 survey).

## Mapping to model defaults

- Model size fixed at 670 agents.
- Scale factor: about 69.1 million / 670 = about 103,000 people per agent.
- Migration defaults:
  - `agents-coming = 3.36` (from 346,900 entrants / scale factor).
  - `agents-leaving = 1.66` (implied from entrants minus net migration: 346,900 - 176,000 = 170,900; then / scale factor).
  - Net = about +1.70 agents/year, approximately +176,000 people/year at this scale.
- Fertility defaults:
  - `non-muslim-birth-rate = 1.56`
  - `muslim-birth-rate = 2.81` (proxy from majority-muslim origin countries in INSEE 2023 entrant list, weighted by arrivals).
  - `coverage-coefficient = 1.00`
- Religion composition defaults:
  - `share-muslim-incoming = 0.52` (known-country weighted result rounded from 0.521).
  - `initial muslim share = 0.10` (TeO2 2019-2020 proxy for ages 18-59).

## Migration religion mapping (2023 entrants)

Method used:
- Start from INSEE 2023 immigrant entrants by country of birth.
- Map each listed country to Pew 2020 country Muslim percentage.
- Compute weighted Muslim share for listed countries.
- For residual (non-listed) entrants in each continent block, use regional fallback assumptions:
  - Africa residual = weighted blend of MENA and Sub-Saharan shares, using listed Africa split.
  - Asia residual = Pew Asia-Pacific aggregate share.
  - Europe residual = Pew Europe aggregate share.
  - Americas/Oceania residual = population-weighted Pew North + Latin America aggregate share.

Computed result:
- Covered listed countries: 250,300 of 346,900 entrants (72.15% coverage).
- Weighted Muslim share on covered countries: 52.15%.
- Weighted Muslim share including residual assumptions: 47.33%.
- Baseline model default chosen here: `share-muslim-incoming = 0.52` (known-country weighted value).
- Residual-adjusted value `0.47` is kept as a sensitivity option.

Reproducibility files:
- `data/incoming_origin_religion_mapping_2023.csv`
- `data/incoming_origin_religion_summary_2023.json`

## Muslim fertility proxy from majority-muslim origin countries

Method used:
- Select countries in the INSEE 2023 entrant-origin table with Pew 2020 Muslim share >= 50%.
- Pull latest available country TFR from World Bank indicator SP.DYN.TFRT.IN.
- Compute arrivals-weighted average TFR across selected countries.

Computed result:
- Selected countries: 11 (Algeria, Morocco, Tunisia, Afghanistan, Guinea, Senegal, Turkey, Comoros, Lebanon, Syria, Bangladesh).
- Selected arrivals: 123,400 (35.57% of total entrants; 49.30% of covered listed-country entrants).
- Weighted latest TFR proxy: 2.8057.
- Rounded baseline model default: `muslim-birth-rate = 2.81`.

Reproducibility files:
- `data/muslim_country_fertility_proxy.csv`
- `data/muslim_country_fertility_proxy_summary.json`

## Important limits

- France does not publish annual official religion counts by age, births, deaths, and migration.
- Religion at immigration is inferred from country-of-birth religious composition, not directly observed per migrant.
- The baseline setup does not explicitly impose an older native age structure versus younger muslim age structure at initialization.
- Religion-specific fertility and migration differentials remain scenario assumptions.
- The aggregate demographic core (age structure, overall TFR level, mortality shape, net migration balance) is data-informed.
