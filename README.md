# Bluestock MF Analytics Capstone

Mutual Fund analytics capstone project — ETL, EDA, performance metrics, dashboard and advanced analytics for Bluestock Fintech.

## Objectives
- Ingest and clean 10 mutual fund datasets (fund master, NAV history, AUM, SIP inflows, transactions, portfolio holdings, benchmarks).
- Build a SQLite star schema and run analytical SQL queries.
- Perform EDA: NAV trends, AUM growth, SIP flows, demographics, geography, correlations, sector allocation.
- Compute performance metrics: CAGR, Sharpe, Sortino, Alpha/Beta, Max Drawdown, composite Fund Scorecard.
- Run advanced risk analytics: VaR/CVaR, rolling Sharpe, investor cohorts, SIP continuity, sector HHI, and a risk-based fund recommender.

## Project Structure
```
data/
├── raw/        ← original 10 CSVs + live NAV pulls from mfapi.in
├── processed/  ← cleaned CSVs + derived analytics (CAGR, Sharpe, VaR, scorecard, etc.)
└── db/         ← bluestock_mf.db (SQLite, excluded from git — see schema.sql)

notebooks/
├── 01_data_ingestion.ipynb       ← load 10 CSVs, live NAV fetch, data quality checks
├── 02_data_cleaning.ipynb        ← run ETL, verify SQLite row counts, sample queries
├── 03_eda_analysis.ipynb         ← 15+ EDA charts + 10 key insights
├── 04_performance_analytics.ipynb ← CAGR, Sharpe, Sortino, Alpha/Beta, Max DD, scorecard
└── 05_advanced_analytics.ipynb   ← VaR/CVaR, rolling Sharpe, cohorts, SIP continuity, HHI

scripts/
├── etl_pipeline.py    ← full ETL: clean all 10 datasets, load into SQLite
├── run_pipeline.py    ← master runner (validation + ETL)
├── validate_codes.py  ← AMFI code consistency check
├── live_nav_fetch.py  ← fetch live NAV from mfapi.in
└── recommender.py     ← standalone fund recommender by risk appetite

sql/
├── schema.sql         ← star schema DDL
├── queries.sql        ← 10 analytical queries
└── data_dictionary.md ← column-level documentation

reports/  ← 20+ exported PNG charts + data_quality_summary.txt
dashboard/ ← Power BI / Streamlit dashboard (pending)
```

## How to Run

```bash
pip install -r requirements.txt

# Run ETL + validation
python scripts/run_pipeline.py

# Run fund recommender
python scripts/recommender.py

# Run notebooks in order
jupyter nbconvert --to notebook --execute notebooks/01_data_ingestion.ipynb
jupyter nbconvert --to notebook --execute notebooks/02_data_cleaning.ipynb
jupyter nbconvert --to notebook --execute notebooks/03_eda_analysis.ipynb
jupyter nbconvert --to notebook --execute notebooks/04_performance_analytics.ipynb
jupyter nbconvert --to notebook --execute notebooks/05_advanced_analytics.ipynb
```

## Deliverables
| ID | Deliverable | Format | Weight |
|----|-------------|--------|--------|
| D1 | ETL pipeline | .py | 15% |
| D2 | SQLite database | .db + schema.sql | 10% |
| D3 | EDA notebook | .ipynb | 15% |
| D4 | Performance metrics | .ipynb + CSVs | 15% |
| D5 | Interactive dashboard | .pbix / .twbx | 20% |
| D6 | Advanced analytics | .ipynb | 10% |
| D7 | Final report + slides | .pdf + .pptx | 15% |

## Key Findings
- SIP inflows hit an all-time high of ~Rs 31,002 Cr in Dec 2025.
- Industry folio count grew from 13.26 Cr (Jan 2022) to 26.12 Cr (Dec 2025).
- Direct plans with expense ratio < 0.5% outperform Regular plans by 1-2% CAGR over 3 years.
- ~22% of SIP investors (6+ SIPs) show average gaps > 35 days, flagged as at-risk.
- Sectoral/thematic funds show HHI > 3,000 (highly concentrated) vs Flexi Cap/Large Cap < 1,200.

## Author
Hariharan S — Dual Degree (B.Tech + M.Tech) CSE, IIITDM Kurnool
