"""
Bluestock MF Analytics - Full ETL Pipeline
Cleans all 10 CSVs, loads into SQLite, validates row counts.
"""
import pandas as pd
import numpy as np
from pathlib import Path
from sqlalchemy import create_engine
import warnings
warnings.filterwarnings('ignore')

ROOT      = Path(__file__).parent.parent
RAW       = ROOT / "data" / "raw"
PROCESSED = ROOT / "data" / "processed"
DB_PATH   = ROOT / "data" / "db" / "bluestock_mf.db"
PROCESSED.mkdir(parents=True, exist_ok=True)

engine = create_engine(f"sqlite:///{DB_PATH}")

# ── 1. Fund Master ────────────────────────────────────────────────────────────
fm = pd.read_csv(RAW / "01_fund_master.csv")
fm["launch_date"] = pd.to_datetime(fm["launch_date"], errors="coerce")
fm["amfi_code"] = fm["amfi_code"].astype(int)
fm.to_csv(PROCESSED / "clean_fund_master.csv", index=False)
fm.to_sql("dim_fund", engine, if_exists="replace", index=False)
print(f"fund_master:          {len(fm):>6} rows")

# ── 2. NAV History ────────────────────────────────────────────────────────────
nav = pd.read_csv(RAW / "02_nav_history.csv", parse_dates=["date"])
nav = nav.sort_values(["amfi_code", "date"]).drop_duplicates(["amfi_code","date"])
nav = nav[nav["nav"] > 0]

# forward-fill weekends/holidays
all_dates = pd.date_range(nav["date"].min(), nav["date"].max(), freq="D")
codes = nav["amfi_code"].unique()
idx   = pd.MultiIndex.from_product([codes, all_dates], names=["amfi_code","date"])
nav   = (nav.set_index(["amfi_code","date"])
             .reindex(idx).groupby(level=0)["nav"].ffill()
             .reset_index())
nav = nav.dropna(subset=["nav"])

# daily returns
nav = nav.sort_values(["amfi_code","date"])
nav["daily_return_pct"] = nav.groupby("amfi_code")["nav"].pct_change().round(6)

nav.to_csv(PROCESSED / "clean_nav_history.csv", index=False)
nav.to_sql("fact_nav", engine, if_exists="replace", index=False)
print(f"nav_history:          {len(nav):>6} rows  (after ffill)")

# ── 3. AUM by Fund House ──────────────────────────────────────────────────────
aum = pd.read_csv(RAW / "03_aum_by_fund_house.csv")
aum["aum_lakh_crore"] = pd.to_numeric(aum["aum_lakh_crore"], errors="coerce")
aum.to_csv(PROCESSED / "clean_aum_by_fund_house.csv", index=False)
aum.to_sql("fact_aum", engine, if_exists="replace", index=False)
print(f"aum_by_fund_house:    {len(aum):>6} rows")

# ── 4. Monthly SIP Inflows ────────────────────────────────────────────────────
sip = pd.read_csv(RAW / "04_monthly_sip_inflows.csv", parse_dates=["month"])
sip.to_csv(PROCESSED / "clean_monthly_sip_inflows.csv", index=False)
sip.to_sql("fact_sip_inflows", engine, if_exists="replace", index=False)
print(f"monthly_sip_inflows:  {len(sip):>6} rows")

# ── 5. Category Inflows ───────────────────────────────────────────────────────
cat_inf = pd.read_csv(RAW / "05_category_inflows.csv", parse_dates=["month"])
cat_inf.to_csv(PROCESSED / "clean_category_inflows.csv", index=False)
cat_inf.to_sql("fact_category_inflows", engine, if_exists="replace", index=False)
print(f"category_inflows:     {len(cat_inf):>6} rows")

# ── 6. Industry Folio Count ───────────────────────────────────────────────────
folio = pd.read_csv(RAW / "06_industry_folio_count.csv", parse_dates=["month"])
folio.to_csv(PROCESSED / "clean_industry_folio_count.csv", index=False)
folio.to_sql("fact_folio_count", engine, if_exists="replace", index=False)
print(f"industry_folio_count: {len(folio):>6} rows")

# ── 7. Scheme Performance ─────────────────────────────────────────────────────
perf = pd.read_csv(RAW / "07_scheme_performance.csv")
numeric_cols = [c for c in perf.columns if "pct" in c or c in
                ["alpha","beta","sharpe_ratio","sortino_ratio","std_dev_ann_pct","aum_crore"]]
for c in numeric_cols:
    perf[c] = pd.to_numeric(perf[c], errors="coerce")
perf = perf[perf["expense_ratio_pct"].between(0.1, 2.5, inclusive="both") | perf["expense_ratio_pct"].isna()]
perf.to_csv(PROCESSED / "clean_scheme_performance.csv", index=False)
perf.to_sql("fact_performance", engine, if_exists="replace", index=False)
print(f"scheme_performance:   {len(perf):>6} rows")

# ── 8. Investor Transactions ──────────────────────────────────────────────────
txn = pd.read_csv(RAW / "08_investor_transactions.csv", parse_dates=["transaction_date"])
txn["transaction_type"] = txn["transaction_type"].str.strip().str.title()
txn = txn[txn["amount_inr"] > 0]
txn = txn[txn["kyc_status"].isin(["Verified","Pending","Rejected"])]
txn.to_csv(PROCESSED / "clean_investor_transactions.csv", index=False)
txn.to_sql("fact_transactions", engine, if_exists="replace", index=False)
print(f"investor_transactions:{len(txn):>6} rows")

# ── 9. Portfolio Holdings ─────────────────────────────────────────────────────
port = pd.read_csv(RAW / "09_portfolio_holdings.csv", parse_dates=["portfolio_date"])
port.to_csv(PROCESSED / "clean_portfolio_holdings.csv", index=False)
port.to_sql("fact_portfolio", engine, if_exists="replace", index=False)
print(f"portfolio_holdings:   {len(port):>6} rows")

# ── 10. Benchmark Indices ─────────────────────────────────────────────────────
bench = pd.read_csv(RAW / "10_benchmark_indices.csv", parse_dates=["date"])
bench = bench.sort_values(["index_name","date"]).drop_duplicates()
bench["daily_return_pct"] = bench.groupby("index_name")["close_value"].pct_change().round(6)
bench.to_csv(PROCESSED / "clean_benchmark_indices.csv", index=False)
bench.to_sql("fact_benchmarks", engine, if_exists="replace", index=False)
print(f"benchmark_indices:    {len(bench):>6} rows")

# ── Dim Date ──────────────────────────────────────────────────────────────────
dates = pd.date_range("2022-01-01", "2025-12-31", freq="D")
dim_date = pd.DataFrame({
    "date"       : dates,
    "year"       : dates.year,
    "quarter"    : dates.quarter,
    "month"      : dates.month,
    "month_name" : dates.month_name(),
    "week"       : dates.isocalendar().week.astype(int),
    "day_of_week": dates.day_name(),
    "is_weekend" : dates.dayofweek >= 5,
})
dim_date.to_sql("dim_date", engine, if_exists="replace", index=False)
print(f"dim_date:             {len(dim_date):>6} rows")

print("\nETL pipeline complete. DB at:", DB_PATH)
