import glob
import os

import matplotlib
import numpy as np
import pandas as pd

matplotlib.use("Agg")
import matplotlib.pyplot as plt


RAW_DIR = "data/paper_runs/raw"
OUT_DIR = "data/paper_runs"
FIG_DIR = "figures"

os.makedirs(OUT_DIR, exist_ok=True)
os.makedirs(FIG_DIR, exist_ok=True)

SCENARIO_LABELS = {
    "baseline_30y": "Baseline calibrated",
    "no_migration_30y": "No migration counterfactual",
    "high_inflow_share_30y": "High Muslim inflow share (70%)",
}

SCENARIO_ORDER = [
    "baseline_30y",
    "no_migration_30y",
    "high_inflow_share_30y",
]

COLORS = {
    "baseline_30y": "#1f77b4",
    "no_migration_30y": "#444444",
    "high_inflow_share_30y": "#d62728",
}


def pick_column(df, needle, exact=False):
    for col in df.columns:
        if exact and col.lower() == needle.lower():
            return col
        if (not exact) and (needle in col.lower()):
            return col
    raise KeyError(needle)


def load_raw_runs():
    frames = []
    for path in sorted(glob.glob(os.path.join(RAW_DIR, "*_30y.csv"))):
        scenario = os.path.splitext(os.path.basename(path))[0]
        df = pd.read_csv(path, skiprows=6)

        c_run = pick_column(df, "[run number]")
        c_step = pick_column(df, "[step]")
        c_total = pick_column(df, "count turtles", exact=True)
        c_mus = pick_column(df, 'count turtles with [religion = "muslim"]', exact=True)
        c_non = pick_column(df, 'count turtles with [religion = "non-muslim"]', exact=True)
        c_share = pick_column(df, " / count turtles]")

        clean = pd.DataFrame(
            {
                "scenario": scenario,
                "scenario_label": SCENARIO_LABELS.get(scenario, scenario),
                "run": pd.to_numeric(df[c_run], errors="coerce"),
                "step": pd.to_numeric(df[c_step], errors="coerce"),
                "total_population": pd.to_numeric(df[c_total], errors="coerce"),
                "muslim_population": pd.to_numeric(df[c_mus], errors="coerce"),
                "non_muslim_population": pd.to_numeric(df[c_non], errors="coerce"),
                "muslim_share": pd.to_numeric(df[c_share], errors="coerce"),
            }
        ).dropna()

        clean["run"] = clean["run"].astype(int)
        clean["step"] = clean["step"].astype(int)
        clean["year"] = 2026 + clean["step"]
        frames.append(clean)

    if not frames:
        raise RuntimeError(f"No raw run files found in {RAW_DIR}")

    return pd.concat(frames, ignore_index=True)


def summarize_stepwise(all_runs):
    return all_runs.groupby(["scenario", "scenario_label", "step", "year"], as_index=False).agg(
        runs=("run", "nunique"),
        mean_share=("muslim_share", "mean"),
        p10_share=("muslim_share", lambda x: np.quantile(x, 0.10)),
        p50_share=("muslim_share", lambda x: np.quantile(x, 0.50)),
        p90_share=("muslim_share", lambda x: np.quantile(x, 0.90)),
        mean_total_population=("total_population", "mean"),
        p10_total_population=("total_population", lambda x: np.quantile(x, 0.10)),
        p50_total_population=("total_population", lambda x: np.quantile(x, 0.50)),
        p90_total_population=("total_population", lambda x: np.quantile(x, 0.90)),
    )


def summarize_final(all_runs):
    final_step = int(all_runs["step"].max())
    final_df = all_runs[all_runs["step"] == final_step].copy()

    crossings = []
    for (scenario, run), group in all_runs.groupby(["scenario", "run"]):
        group = group.sort_values("step")
        row = {"scenario": scenario, "run": run}
        for threshold in [0.5, 0.75, 0.95]:
            hit = group[group["muslim_share"] >= threshold]
            key = f"first_step_ge_{str(threshold).replace('.', '_')}"
            row[key] = int(hit["step"].iloc[0]) if not hit.empty else np.nan
        crossings.append(row)
    crossings_df = pd.DataFrame(crossings)

    final_summary = final_df.groupby(["scenario", "scenario_label"], as_index=False).agg(
        runs=("run", "nunique"),
        mean_final_share=("muslim_share", "mean"),
        p10_final_share=("muslim_share", lambda x: np.quantile(x, 0.10)),
        median_final_share=("muslim_share", "median"),
        p90_final_share=("muslim_share", lambda x: np.quantile(x, 0.90)),
        mean_final_total_pop=("total_population", "mean"),
        mean_final_muslim_pop=("muslim_population", "mean"),
        mean_final_non_muslim_pop=("non_muslim_population", "mean"),
        share_runs_ge_50=("muslim_share", lambda x: float(np.mean(x >= 0.5))),
        share_runs_ge_75=("muslim_share", lambda x: float(np.mean(x >= 0.75))),
        share_runs_ge_95=("muslim_share", lambda x: float(np.mean(x >= 0.95))),
    )

    for threshold in [0.5, 0.75, 0.95]:
        col = f"first_step_ge_{str(threshold).replace('.', '_')}"
        median_name = f"median_first_step_ge_{str(threshold).replace('.', '_')}"
        med = crossings_df.groupby("scenario")[col].median().rename(median_name)
        final_summary = final_summary.merge(med, on="scenario", how="left")

    return final_df, crossings_df, final_summary


def make_figures(step_summary, final_df):
    final_year = int(final_df["year"].iloc[0])
    plt.figure(figsize=(11, 6))
    for scenario in SCENARIO_ORDER:
        sub = step_summary[step_summary["scenario"] == scenario].sort_values("year")
        if sub.empty:
            continue
        plt.plot(
            sub["year"],
            sub["p50_share"],
            label=SCENARIO_LABELS[scenario],
            color=COLORS[scenario],
            linewidth=2,
        )
        plt.fill_between(
            sub["year"],
            sub["p10_share"],
            sub["p90_share"],
            color=COLORS[scenario],
            alpha=0.15,
        )
    plt.ylim(0, 1)
    plt.xlabel("Year")
    plt.ylabel("Muslim share of population")
    plt.title("Simulated Muslim population share over time (median with 10-90% interval)")
    plt.legend(loc="best", fontsize=8)
    plt.grid(alpha=0.25)
    plt.tight_layout()
    plt.savefig(os.path.join(FIG_DIR, "fig1_muslim_share_trajectories.png"), dpi=200)
    plt.close()

    plot_df = final_df.copy()
    plot_df["scenario_label"] = pd.Categorical(
        plot_df["scenario_label"],
        categories=[SCENARIO_LABELS[s] for s in SCENARIO_ORDER],
        ordered=True,
    )

    plt.figure(figsize=(12, 6))
    plot_df.boxplot(column="muslim_share", by="scenario_label", grid=False, rot=25)
    plt.ylim(0, 1)
    plt.ylabel(f"Muslim share at year {final_year}")
    plt.xlabel("Scenario")
    plt.title("Distribution of final Muslim share across 200 stochastic runs")
    plt.suptitle("")
    plt.tight_layout()
    plt.savefig(os.path.join(FIG_DIR, "fig2_final_share_boxplot.png"), dpi=200)
    plt.close()

    plt.figure(figsize=(11, 6))
    for scenario in SCENARIO_ORDER:
        sub = step_summary[step_summary["scenario"] == scenario].sort_values("year")
        if sub.empty:
            continue
        plt.plot(
            sub["year"],
            sub["p50_total_population"],
            label=SCENARIO_LABELS[scenario],
            color=COLORS[scenario],
            linewidth=2,
        )
        plt.fill_between(
            sub["year"],
            sub["p10_total_population"],
            sub["p90_total_population"],
            color=COLORS[scenario],
            alpha=0.12,
        )
    plt.xlabel("Year")
    plt.ylabel("Population (agents)")
    plt.title("Simulated total population trajectories (median with 10-90% interval)")
    plt.legend(loc="best", fontsize=8)
    plt.grid(alpha=0.25)
    plt.tight_layout()
    plt.savefig(os.path.join(FIG_DIR, "fig3_total_population_trajectories.png"), dpi=200)
    plt.close()

    baseline = step_summary[step_summary["scenario"] == "baseline_30y"][
        ["year", "p50_share"]
    ].rename(columns={"p50_share": "baseline"})
    no_migration = step_summary[step_summary["scenario"] == "no_migration_30y"][
        ["year", "p50_share"]
    ].rename(columns={"p50_share": "no_migration"})
    diff = baseline.merge(no_migration, on="year")
    diff["difference"] = diff["baseline"] - diff["no_migration"]
    diff.to_csv(os.path.join(OUT_DIR, "baseline_vs_no_migration_median_diff_30y.csv"), index=False)

    plt.figure(figsize=(10, 4.5))
    plt.plot(diff["year"], diff["difference"], color="#1f77b4", linewidth=2)
    plt.axhline(0, color="black", linewidth=1)
    plt.xlabel("Year")
    plt.ylabel("Median share difference")
    plt.title("Baseline minus no-migration: median Muslim share difference")
    plt.grid(alpha=0.25)
    plt.tight_layout()
    plt.savefig(os.path.join(FIG_DIR, "fig4_baseline_minus_no_migration.png"), dpi=200)
    plt.close()


def build_key_points(step_summary, final_summary):
    final_year = int(step_summary["year"].max())
    years = [2026, 2035, 2050, final_year]
    rows = []
    for scenario, group in step_summary.groupby("scenario"):
        row = {"scenario": scenario, "scenario_label": group["scenario_label"].iloc[0]}
        for year in years:
            sub = group[group["year"] == year]
            if sub.empty:
                continue
            row[f"median_share_{year}"] = float(sub["p50_share"].iloc[0])
            row[f"p10_share_{year}"] = float(sub["p10_share"].iloc[0])
            row[f"p90_share_{year}"] = float(sub["p90_share"].iloc[0])
            row[f"median_pop_{year}"] = float(sub["p50_total_population"].iloc[0])
        rows.append(row)

    key_points = pd.DataFrame(rows)
    key_points = key_points.merge(
        final_summary[
            [
                "scenario",
                "mean_final_share",
                "p10_final_share",
                "p90_final_share",
                "mean_final_total_pop",
                "share_runs_ge_50",
                "share_runs_ge_75",
                "share_runs_ge_95",
            ]
        ],
        on="scenario",
        how="left",
    )
    return key_points


def main():
    all_runs = load_raw_runs()
    all_runs.to_csv(os.path.join(OUT_DIR, "combined_runs_30y.csv"), index=False)

    step_summary = summarize_stepwise(all_runs)
    step_summary.to_csv(os.path.join(OUT_DIR, "step_summary_30y.csv"), index=False)

    final_df, crossings_df, final_summary = summarize_final(all_runs)
    crossings_df.to_csv(os.path.join(OUT_DIR, "crossing_steps_30y.csv"), index=False)
    final_summary.to_csv(os.path.join(OUT_DIR, "final_summary_30y.csv"), index=False)

    key_points = build_key_points(step_summary, final_summary)
    key_points.to_csv(os.path.join(OUT_DIR, "key_points_30y.csv"), index=False)

    make_figures(step_summary, final_df)

    print(f"Combined rows: {len(all_runs)}")
    print(final_summary[["scenario", "mean_final_share", "p10_final_share", "p90_final_share"]])


if __name__ == "__main__":
    main()
