# Data Dictionary — Bluestock MF Analytics

This document describes all tables/columns in `bluestock_mf.db` and the
cleaned CSVs in `data/processed/`. Source references point to the raw
files in `data/raw/`.

---

## dim_fund (source: 01_fund_master.csv)

| Column | Type | Description |
|---|---|---|
| amfi_code | INTEGER (PK) | Unique AMFI scheme code |
| fund_house | TEXT | Asset Management Company name |
| scheme_name | TEXT | Full scheme name including plan |
| category | TEXT | Broad category (Equity / Debt) |
| sub_category | TEXT | Scheme sub-category (Large Cap, Flexi Cap, etc.) |
| plan | TEXT | Regular or Direct plan |
| launch_date | DATE | Scheme inception date |
| benchmark | TEXT | Benchmark index used for performance comparison |
| expense_ratio_pct | FLOAT | Annual expense ratio (%) |
| exit_load_pct | FLOAT | Exit load (%) |
| min_sip_amount | FLOAT | Minimum SIP investment (Rs) |
| min_lumpsum_amount | FLOAT | Minimum lumpsum investment (Rs) |
| fund_manager | TEXT | Name of fund manager |
| risk_category | TEXT | Risk classification (raw label) |
| sebi_category_code | TEXT | SEBI scheme classification code |

## fact_nav (source: 02_nav_history.csv → clean_nav_history.csv)

| Column | Type | Description |
|---|---|---|
| amfi_code | INTEGER (FK → dim_fund) | Scheme identifier |
| date | DATE (FK → dim_date) | NAV date (forward-filled to a continuous daily series) |
| nav | FLOAT | Net Asset Value (Rs); validated > 0 |
| daily_return_pct | FLOAT | Day-over-day % change in NAV |

## fact_aum (source: 03_aum_by_fund_house.csv → clean_aum_by_fund_house.csv)

| Column | Type | Description |
|---|---|---|
| date | DATE | Reporting date (quarterly) |
| fund_house | TEXT | AMC name |
| aum_lakh_crore | FLOAT | AUM in Rs Lakh Crore |
| aum_crore | FLOAT | AUM in Rs Crore |
| num_schemes | INTEGER | Number of schemes managed |

## fact_sip_inflows (source: 04_monthly_sip_inflows.csv → clean_monthly_sip_inflows.csv)

| Column | Type | Description |
|---|---|---|
| month | DATE | Reporting month |
| sip_inflow_crore | FLOAT | Total SIP inflow (Rs Crore) |
| active_sip_accounts_crore | FLOAT | Active SIP accounts (Crore) |
| new_sip_accounts_lakh | FLOAT | New SIP accounts registered (Lakh) |
| sip_aum_lakh_crore | FLOAT | AUM attributable to SIPs (Rs Lakh Crore) |
| yoy_growth_pct | FLOAT | Year-over-year SIP inflow growth (%); null for first 12 months |

## fact_category_inflows (source: 05_category_inflows.csv → clean_category_inflows.csv)

| Column | Type | Description |
|---|---|---|
| month | DATE | Reporting month |
| category | TEXT | Fund category |
| net_inflow_crore | FLOAT | Net inflow for the category (Rs Crore) |

## fact_folio_count (source: 06_industry_folio_count.csv → clean_industry_folio_count.csv)

| Column | Type | Description |
|---|---|---|
| month | DATE | Reporting month |
| total_folios_crore | FLOAT | Total industry folio count (Crore) |
| equity_folios_crore | FLOAT | Equity folio count (Crore) |
| debt_folios_crore | FLOAT | Debt folio count (Crore) |
| hybrid_folios_crore | FLOAT | Hybrid folio count (Crore) |
| others_folios_crore | FLOAT | Other category folio count (Crore) |

## fact_performance (source: 07_scheme_performance.csv → clean_scheme_performance.csv)

| Column | Type | Description |
|---|---|---|
| amfi_code | INTEGER (PK, FK → dim_fund) | Scheme identifier |
| scheme_name | TEXT | Scheme name |
| fund_house | TEXT | AMC name |
| category | TEXT | Scheme category |
| plan | TEXT | Regular/Direct |
| return_1yr_pct | FLOAT | 1-year trailing return (%) |
| return_3yr_pct | FLOAT | 3-year CAGR (%) |
| return_5yr_pct | FLOAT | 5-year CAGR (%) |
| benchmark_3yr_pct | FLOAT | Benchmark 3-year return (%) |
| alpha | FLOAT | Jensen's alpha (reported) |
| beta | FLOAT | Beta vs benchmark (reported) |
| sharpe_ratio | FLOAT | Reported Sharpe ratio |
| sortino_ratio | FLOAT | Reported Sortino ratio |
| std_dev_ann_pct | FLOAT | Annualised standard deviation (%) |
| max_drawdown_pct | FLOAT | Reported maximum drawdown (%) |
| aum_crore | FLOAT | Scheme-level AUM (Rs Crore) |
| expense_ratio_pct | FLOAT | Expense ratio (%); validated 0.1–2.5% |
| morningstar_rating | INTEGER | Morningstar star rating (1-5) |
| risk_grade | TEXT | Risk grade (Low / Moderate / High / etc.) |

## fact_transactions (source: 08_investor_transactions.csv → clean_investor_transactions.csv)

| Column | Type | Description |
|---|---|---|
| investor_id | TEXT | Unique investor identifier |
| transaction_date | DATE (FK → dim_date) | Date of transaction |
| amfi_code | INTEGER (FK → dim_fund) | Scheme identifier |
| transaction_type | TEXT | Sip / Lumpsum / Redemption (standardised) |
| amount_inr | FLOAT | Transaction amount (Rs); validated > 0 |
| state | TEXT | Investor's state |
| city | TEXT | Investor's city |
| city_tier | TEXT | T30 (Top 30 cities) or B30 (Beyond Top 30) |
| age_group | TEXT | Investor age bracket |
| gender | TEXT | Investor gender |
| annual_income_lakh | FLOAT | Annual income (Rs Lakh) |
| payment_mode | TEXT | Payment method used |
| kyc_status | TEXT | KYC verification status |

## fact_portfolio (source: 09_portfolio_holdings.csv → clean_portfolio_holdings.csv)

| Column | Type | Description |
|---|---|---|
| amfi_code | INTEGER (FK → dim_fund) | Scheme identifier |
| stock_symbol | TEXT | Stock ticker symbol |
| stock_name | TEXT | Company name |
| sector | TEXT | Sector classification |
| weight_pct | FLOAT | Portfolio weight (%) |
| market_value_cr | FLOAT | Market value of holding (Rs Crore) |
| current_price_inr | FLOAT | Current stock price (Rs) |
| portfolio_date | DATE | Date of portfolio snapshot |

## fact_benchmarks (source: 10_benchmark_indices.csv → clean_benchmark_indices.csv)

| Column | Type | Description |
|---|---|---|
| date | DATE | Trading date |
| index_name | TEXT | Index name (NIFTY50, NIFTY100, etc.) |
| close_value | FLOAT | Index closing value |
| daily_return_pct | FLOAT | Day-over-day % change |

## dim_date (generated)

| Column | Type | Description |
|---|---|---|
| date | DATE (PK) | Calendar date (2022-01-01 to 2025-12-31) |
| year | INTEGER | Calendar year |
| quarter | INTEGER | Calendar quarter (1-4) |
| month | INTEGER | Calendar month (1-12) |
| month_name | TEXT | Month name |
| week | INTEGER | ISO week number |
| day_of_week | TEXT | Day name |
| is_weekend | BOOLEAN | True if Saturday/Sunday |

---

## Derived Analytical Outputs (data/processed/)

| File | Description |
|---|---|
| cagr_report.csv | 1/3/5-year CAGR per fund |
| sharpe_values.csv | Sharpe ratio per fund (Rf=6.5%) |
| sortino_values.csv | Sortino ratio per fund |
| alpha_beta.csv | OLS alpha/beta vs NIFTY 100 |
| max_drawdown.csv | Max drawdown, peak/trough/recovery dates |
| fund_scorecard.csv | Composite 0-100 score with category ranks |
| var_cvar_report.csv | Historical VaR(95/99) and CVaR per fund |
| cohort_analysis.csv | Investor cohort metrics by first-investment year |
| sip_continuity.csv | SIP gap analysis and at-risk flags |
| sector_hhi.csv | Herfindahl-Hirschman Index per equity fund |
