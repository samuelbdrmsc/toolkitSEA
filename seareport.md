# COVID Country-level Snapshot — Visual Findings

**Source:** `country_wise_latest.csv` (user-provided)  
**Files with visualisations:**  

- `plot_top15_confirmed.png`  
- `plot_confirmed_vs_deaths.png`  
- `plot_active_distribution.png`  
- `plot_top12_cfr.png`  
- `plot_top10_newcases_clean.png`

---

## Executive summary

The dataset is a country/region snapshot containing confirmed cases, deaths, recoveries, active cases and new cases. Visual analysis shows that a small set of countries concentrate most confirmed cases, deaths scale roughly with confirmed cases (with notable outliers), active-case counts are strongly right-skewed, and some countries show high case-fatality ratios (CFR) suggesting either high mortality or under-reporting of infections.

---

## 1. Top 15 Countries by Confirmed Cases

**Figure:** `plot_top15_confirmed.png`  
**What it shows:** horizontal bar chart of the 15 countries with the largest cumulative confirmed case counts.

**Findings / interpretation**

- A small number of countries hold a disproportionately large fraction of global confirmed cases — the top bars dominate the chart.
- This concentration suggests that global response and healthcare resources remain especially critical in these top countries.
- When preparing policies or allocating resources, prioritize countries in the top group due to absolute case burden.

**Caveats**

- Confirmed cases depend on testing volume and reporting protocols; high confirmed counts may reflect more extensive testing.

---

## 2. Confirmed vs Deaths (Log scale)

**Figure:** `plot_confirmed_vs_deaths.png`  
**What it shows:** a log–log scatter of confirmed cases (x) vs deaths (y). Top death-count countries are labeled.

**Findings / interpretation**

- There is a clear positive association: countries with more confirmed cases tend to report more deaths.
- On a log scale, many countries lie along an approximate trend line; departures above that trend indicate higher deaths relative to confirmed cases (higher CFR) and departures below indicate relatively fewer deaths.
- Outliers above the trendline may be due to:
  - Higher mortality (older population, health system strain)
  - Under-detection of cases (low testing), which inflates measured CFR
  - Differences in death attribution or reporting delays

**Caveats**

- The warning about infinite values in the log transform occurs when deaths equal 0 for some rows; those points are excluded from the log plot.

---

## 3. Distribution of Active Cases (log10)

**Figure:** `plot_active_distribution.png`  
**What it shows:** histogram of log10(active cases) to reveal skewness.

**Findings / interpretation**

- Active cases are **right-skewed** (heavy tail): most countries have relatively low active counts, while a minority have very large active caseloads.
- This heavy tail indicates resource concentration: only a few healthcare systems face the highest ongoing burden.
- For surveillance and resource planning, consider both the number of countries affected and the intensity of burden in those few with very high active counts.

---

## 4. Top 12 Countries by CFR (%)

**Figure:** `plot_top12_cfr.png`  
**What it shows:** bar chart of top countries by Case Fatality Rate (CFR) among countries with >1,000 confirmed cases (to reduce small-number noise).

**Findings / interpretation**

- Some countries show notably higher CFR. Possible explanations:
  - Low testing (cases undercounted → inflated CFR)
  - Healthcare strain or worse outcomes in vulnerable populations
  - Differences in counting deaths (some may include suspected COVID deaths, others may not)
- We restricted to countries with >1,000 confirmed to avoid high CFR values driven by very small denominators.

**Caveats**

- CFR is not infection fatality ratio (IFR) and is heavily influenced by testing policy and case ascertainment.

---

## 5. Top 10 Countries by New Cases (and distribution)

**Figure:** `plot_top10_newcases_clean.png`  
**What it shows:** top 10 countries by newly reported cases and distribution histogram.

**Findings / interpretation**

- The top-10 new-case list highlights countries currently experiencing the largest short-term increases; these are potential hotspots requiring short-term attention.
- The histogram shows whether many countries have similar small increases or whether new-case increases are concentrated.

**Caveats**

- "New cases" reflect reporting cadence and testing; spikes may sometimes reflect backlog reporting rather than true day-to-day increases.

---

## Overall recommendations

1. **Focus resources on the highest-burden countries** (top confirmed and top active) — they carry most of the absolute case load.  
2. **Investigate high-CFR outliers** — check testing rates and death reporting rules before drawing conclusions about mortality risk.  
3. **Monitor new-case surges** — countries with rising new-case counts should be prioritized for short-term containment measures and surge capacity.  
4. **Complement this analysis with testing and population data** — per-capita and testing-adjusted metrics (cases per 100k, tests per 100k, test positivity) provide a less biased comparison across countries.

---

## Limitations of this analysis

- Country-level snapshot only — no time-series trends were analyzed here.  
- Metrics like CFR are dependent on testing and reporting practices and should be interpreted with caution.  
- Population-size adjustments (per 100k) and testing-volume data were not available; adding them would improve comparability.

---

## Appendix — Reproducibility

Plots were generated from `country_wise_latest.csv` using ggplot2 in R. Filenames:

- `plot_top15_confirmed.png`  
- `plot_confirmed_vs_deaths.png`  
- `plot_active_distribution.png`  
- `plot_top12_cfr.png`  
- `plot_top10_newcases_clean.png`

