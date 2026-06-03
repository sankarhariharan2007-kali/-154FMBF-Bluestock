-- ============================================================
-- queries.sql
-- Bluestock Fintech — Mutual Fund Analytics Capstone
-- 10 Analytical SQL Queries (Day 2 Task 6)
-- Database: bluestock_mf.db (SQLite)
-- ============================================================

-- ─────────────────────────────────────────────────────────────
-- Q1: Top 5 funds by AUM (crore)
-- ─────────────────────────────────────────────────────────────
SELECT
    scheme_name,
    fund_house,
    category,
    aum_crore,
    expense_ratio_pct,
    sharpe_ratio
FROM fact_performance
ORDER BY aum_crore DESC
LIMIT 5;

-- ─────────────────────────────────────────────────────────────
-- Q2: Average NAV per month for each fund (2024)
-- ─────────────────────────────────────────────────────────────
SELECT
    n.amfi_code,
    f.scheme_name,
    STRFTIME('%Y-%m', n.date)   AS month,
    ROUND(AVG(n.nav), 4)        AS avg_nav,
    ROUND(MIN(n.nav), 4)        AS min_nav,
    ROUND(MAX(n.nav), 4)        AS max_nav
FROM fact_nav n
JOIN dim_fund f ON n.amfi_code = f.amfi_code
WHERE n.date LIKE '2024%'
GROUP BY n.amfi_code, month
ORDER BY n.amfi_code, month;

-- ─────────────────────────────────────────────────────────────
-- Q3: SIP inflow YoY growth (month-by-month)
-- ─────────────────────────────────────────────────────────────
SELECT
    month,
    sip_inflow_crore,
    yoy_growth_pct,
    ROUND(sip_aum_lakh_crore, 2)    AS sip_aum_lakh_crore,
    active_sip_accounts_crore
FROM fact_sip_industry
ORDER BY month;

-- ─────────────────────────────────────────────────────────────
-- Q4: Total transaction amount by state (Top 10)
-- ─────────────────────────────────────────────────────────────
SELECT
    state,
    COUNT(*)                            AS num_transactions,
    SUM(amount_inr)                     AS total_amount_inr,
    ROUND(AVG(amount_inr), 0)           AS avg_amount_inr,
    COUNT(DISTINCT investor_id)         AS unique_investors
FROM fact_transactions
GROUP BY state
ORDER BY total_amount_inr DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────
-- Q5: Funds with expense ratio < 1% (Direct plans — good value)
-- ─────────────────────────────────────────────────────────────
SELECT
    scheme_name,
    fund_house,
    category,
    plan,
    expense_ratio_pct,
    sharpe_ratio,
    return_3yr_pct,
    aum_crore
FROM fact_performance
WHERE expense_ratio_pct < 1.0
ORDER BY expense_ratio_pct ASC;

-- ─────────────────────────────────────────────────────────────
-- Q6: Best risk-adjusted funds — Top 10 by Sharpe ratio
-- ─────────────────────────────────────────────────────────────
SELECT
    scheme_name,
    fund_house,
    category,
    sharpe_ratio,
    sortino_ratio,
    return_3yr_pct,
    std_dev_ann_pct,
    max_drawdown_pct
FROM fact_performance
ORDER BY sharpe_ratio DESC
LIMIT 10;

-- ─────────────────────────────────────────────────────────────
-- Q7: AUM growth by fund house over time
-- ─────────────────────────────────────────────────────────────
SELECT
    fund_house,
    date,
    aum_lakh_crore,
    aum_crore,
    ROUND(
        (aum_crore - LAG(aum_crore) OVER (PARTITION BY fund_house ORDER BY date))
        * 100.0 / NULLIF(LAG(aum_crore) OVER (PARTITION BY fund_house ORDER BY date), 0),
        2
    ) AS qoq_growth_pct
FROM fact_aum
ORDER BY fund_house, date;

-- ─────────────────────────────────────────────────────────────
-- Q8: SIP vs Lumpsum vs Redemption split by transaction type
-- ─────────────────────────────────────────────────────────────
SELECT
    transaction_type,
    COUNT(*)                                AS num_transactions,
    SUM(amount_inr)                         AS total_amount_inr,
    ROUND(AVG(amount_inr), 0)               AS avg_amount_inr,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM fact_transactions
GROUP BY transaction_type
ORDER BY total_amount_inr DESC;

-- ─────────────────────────────────────────────────────────────
-- Q9: Top sectors by weight across all equity fund portfolios
-- ─────────────────────────────────────────────────────────────
SELECT
    sector,
    COUNT(DISTINCT amfi_code)           AS num_funds_holding,
    ROUND(AVG(weight_pct), 2)           AS avg_weight_pct,
    ROUND(SUM(market_value_cr), 2)      AS total_market_value_cr
FROM fact_portfolio
GROUP BY sector
ORDER BY total_market_value_cr DESC;

-- ─────────────────────────────────────────────────────────────
-- Q10: Fund performance vs benchmark — funds beating benchmark
-- ─────────────────────────────────────────────────────────────
SELECT
    scheme_name,
    fund_house,
    category,
    return_3yr_pct,
    benchmark_3yr_pct,
    alpha,
    beta,
    CASE
        WHEN alpha > 0 THEN 'Outperforming'
        ELSE 'Underperforming'
    END AS vs_benchmark
FROM fact_performance
ORDER BY alpha DESC;
