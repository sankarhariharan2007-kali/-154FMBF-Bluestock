# Data Dictionary
## Bluestock Fintech — Mutual Fund Analytics Capstone

**Last updated:** June 2026  
**Database:** `bluestock_mf.db` (SQLite)  
**Primary key across all tables:** `amfi_code` (AMFI scheme code)

---

## 01_fund_master.csv → `dim_fund`

Master list of 40 real mutual fund schemes.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `amfi_code` | INTEGER | AMFI unique scheme identifier (PK) | 119552 |
| `fund_house` | TEXT | AMC name | SBI Mutual Fund |
| `scheme_name` | TEXT | Full official AMFI scheme name | SBI Bluechip Fund - Direct Plan - Growth |
| `category` | TEXT | SEBI category: Equity / Debt / Hybrid | Equity |
| `sub_category` | TEXT | Sub-category: Large Cap, Mid Cap, Liquid etc. | Large Cap |
| `plan` | TEXT | Direct or Regular | Direct |
| `launch_date` | DATE | Fund inception date (YYYY-MM-DD) | 2013-01-01 |
| `benchmark` | TEXT | Official benchmark index | NIFTY 100 TRI |
| `expense_ratio_pct` | REAL | Annual expense ratio in % | 0.66 |
| `exit_load_pct` | REAL | Exit load % charged on early redemption | 1.0 |
| `min_sip_amount` | INTEGER | Minimum SIP instalment in ₹ | 500 |
| `min_lumpsum_amount` | INTEGER | Minimum lumpsum investment in ₹ | 1000 |
| `fund_manager` | TEXT | Primary fund manager name | Sohini Andani |
| `risk_category` | TEXT | SEBI risk label: Low / Moderate / High / Very High | Moderate |
| `sebi_category_code` | TEXT | Internal SEBI code (EC01=LargeCap, EC03=SmallCap) | EC01 |

---

## 02_nav_history.csv → `fact_nav`

Daily NAV for all 40 schemes from Jan 2022 to May 2026 (~46,000 rows).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `amfi_code` | INTEGER | FK → dim_fund | 119552 |
| `date` | DATE | Business day (YYYY-MM-DD) | 2024-03-15 |
| `nav` | REAL | Net Asset Value in ₹ | 892.4560 |
| `daily_return_pct` | REAL | Day-over-day return % (added in ETL) | 0.0021 |

**Notes:**
- Forward-filled for weekends and public holidays using `ffill()`
- NAV anchored to real mfapi.in values
- Annualise returns using 252 trading days (not calendar days)

---

## 03_aum_by_fund_house.csv → `fact_aum`

Quarterly AUM for 10 fund houses (2022–2025).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `date` | DATE | Quarter end date | 2025-12-31 |
| `fund_house` | TEXT | AMC name | SBI Mutual Fund |
| `aum_lakh_crore` | REAL | AUM in ₹ lakh crore (industry scale) | 12.50 |
| `aum_crore` | INTEGER | AUM in ₹ crore (scheme scale) | 1250000 |
| `num_schemes` | INTEGER | Number of active schemes managed | 186 |

**⚠ Unit note:** `aum_lakh_crore` ≠ `aum_crore / 100`. 1 lakh crore = 1,00,000 crore. Always check units before aggregating.

---

## 04_monthly_sip_inflows.csv → `fact_sip_industry`

Industry-wide monthly SIP data from AMFI Monthly Notes.

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `month` | TEXT | Month in YYYY-MM format | 2025-12 |
| `sip_inflow_crore` | INTEGER | Total SIP inflows in ₹ crore | 31002 |
| `active_sip_accounts_crore` | REAL | Active SIP accounts in crore | 9.35 |
| `new_sip_accounts_lakh` | REAL | New SIP registrations in lakh | 49.2 |
| `sip_aum_lakh_crore` | REAL | SIP AUM in ₹ lakh crore | 13.18 |
| `yoy_growth_pct` | REAL | YoY growth % in SIP inflows (NULL for first 12 months) | 18.4 |

---

## 05_category_inflows.csv → `fact_category_inflows`

Net inflows by fund category for FY 2024–25 (144 rows).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `month` | TEXT | YYYY-MM | 2024-04 |
| `category` | TEXT | Fund category | Small Cap |
| `net_inflow_crore` | REAL | Net inflows in ₹ crore (negative = net outflow) | 3533.0 |

---

## 06_industry_folio_count.csv → `fact_folio_count`

Total mutual fund folios over time (21 quarterly data points).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `month` | TEXT | YYYY-MM | 2025-12 |
| `total_folios_crore` | REAL | Total folios in crore | 26.12 |
| `equity_folios_crore` | REAL | Equity fund folios in crore | 18.92 |
| `debt_folios_crore` | REAL | Debt fund folios in crore | 2.15 |
| `hybrid_folios_crore` | REAL | Hybrid fund folios in crore | 3.21 |
| `others_folios_crore` | REAL | Others (Index, FOF etc.) | 1.84 |

---

## 07_scheme_performance.csv → `fact_performance`

Pre-computed risk and return metrics for all 40 schemes.

| Column | Type | Description | Formula / Source |
|--------|------|-------------|-----------------|
| `amfi_code` | INTEGER | FK → dim_fund (PK) | — |
| `return_1yr_pct` | REAL | 1-year absolute return % | (NAV_end/NAV_start − 1) × 100 |
| `return_3yr_pct` | REAL | 3-year CAGR % | (NAV_end/NAV_start)^(1/3) − 1 |
| `return_5yr_pct` | REAL | 5-year CAGR % | (NAV_end/NAV_start)^(1/5) − 1 |
| `benchmark_3yr_pct` | REAL | Benchmark 3yr CAGR for comparison | From benchmark_indices |
| `alpha` | REAL | Return above benchmark | return_3yr − benchmark_3yr |
| `beta` | REAL | Market sensitivity (1.0 = same as market) | OLS regression slope |
| `sharpe_ratio` | REAL | Risk-adjusted return (>1 is good) | (Rp − Rf) / σp × √252 |
| `sortino_ratio` | REAL | Downside-adjusted return | (Rp − Rf) / σ_downside × √252 |
| `std_dev_ann_pct` | REAL | Annualised volatility % | σ_daily × √252 × 100 |
| `max_drawdown_pct` | REAL | Worst peak-to-trough decline (negative) | min(NAV/cummax − 1) |
| `aum_crore` | INTEGER | Scheme AUM in ₹ crore | AMFI monthly data |
| `expense_ratio_pct` | REAL | Annual expense ratio % | AMFI / fund factsheet |
| `morningstar_rating` | INTEGER | 1–5 star rating (based on Sharpe) | Simulated |
| `risk_grade` | TEXT | Risk label matching dim_fund | — |

**Risk-free rate used:** Rf = 6.5% (RBI repo rate proxy)

---

## 08_investor_transactions.csv → `fact_transactions`

Simulated SIP + Lumpsum + Redemption transactions for 5,000 investors (~32,778 rows).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `investor_id` | TEXT | Unique investor ID | INV003054 |
| `transaction_date` | DATE | Date of transaction | 2024-01-01 |
| `amfi_code` | INTEGER | FK → dim_fund | 119092 |
| `transaction_type` | TEXT | SIP / Lumpsum / Redemption | SIP |
| `amount_inr` | INTEGER | Transaction amount in ₹ | 1834 |
| `state` | TEXT | Investor's Indian state | Telangana |
| `city` | TEXT | Investor's city | Hyderabad |
| `city_tier` | TEXT | T30 (top 30 cities) or B30 (beyond top 30) | T30 |
| `age_group` | TEXT | 18-25 / 26-35 / 36-45 / 46-55 / 56+ | 56+ |
| `gender` | TEXT | Male / Female | Female |
| `annual_income_lakh` | REAL | Annual income in ₹ lakh | 77.1 |
| `payment_mode` | TEXT | UPI / Net Banking / Mandate / Cheque | UPI |
| `kyc_status` | TEXT | Verified (92%) / Pending (8%) | Verified |

---

## 09_portfolio_holdings.csv → `fact_portfolio`

Top equity stock holdings for equity mutual funds as of Dec 2025 (322 rows).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `amfi_code` | INTEGER | FK → dim_fund | 119551 |
| `stock_symbol` | TEXT | NSE ticker symbol | HDFCBANK |
| `stock_name` | TEXT | Full company name | HDFC Bank Ltd |
| `sector` | TEXT | GICS/NIC sector classification | Banking |
| `weight_pct` | REAL | % of fund portfolio in this stock | 11.19 |
| `market_value_cr` | REAL | Market value of holding in ₹ crore | 88.97 |
| `current_price_inr` | REAL | Stock price in ₹ | 1074.65 |
| `portfolio_date` | DATE | Portfolio disclosure date | 2025-12-31 |

---

## 10_benchmark_indices.csv → `fact_benchmark_indices`

Daily closing values for 6 benchmark indices (8,050 rows).

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `date` | DATE | Trading date | 2024-03-15 |
| `index_name` | TEXT | Index identifier | NIFTY50 |
| `close_value` | REAL | Index closing level | 22335.65 |

**Indices covered:**
- `NIFTY50` — benchmark for Large Cap funds
- `NIFTY100` — benchmark for Large & Mid Cap funds
- `NIFTYMIDCAP150` — benchmark for Mid Cap funds
- `BSE250SMALLCAP` — benchmark for Small Cap funds
- `CRISILLIQDX` — benchmark for Liquid / Debt funds
- `CRISILGILT` — benchmark for Gilt funds

---

## Data Quality Notes

| Dataset | Nulls | Duplicates | Key Anomalies |
|---------|-------|------------|---------------|
| fund_master | 0 | 0 | ✓ Clean |
| nav_history | 0 | 0 | ✓ Clean; ffill applied for holidays |
| aum_by_fund_house | 0 | 0 | ✓ Clean |
| monthly_sip_inflows | 12 | 0 | `yoy_growth_pct` NULL for first 12 months (expected) |
| category_inflows | 0 | 0 | ✓ Clean |
| industry_folio_count | 0 | 0 | ✓ Clean |
| scheme_performance | 0 | 0 | `max_drawdown_pct` all negative (correct — drawdowns are losses) |
| investor_transactions | 0 | 0 | ✓ Clean |
| portfolio_holdings | 0 | 0 | ✓ Clean |
| benchmark_indices | 0 | 0 | ✓ Clean |

---

## Sources

| Dataset | Source |
|---------|--------|
| NAV data | mfapi.in API + AMFI India |
| AUM data | AMFI Quarterly Reports |
| SIP data | AMFI Monthly Notes |
| Benchmark indices | NSE India / BSE India |
| Investor transactions | Synthetically generated (realistic distributions) |
| Portfolio holdings | AMFI monthly portfolio disclosures |
