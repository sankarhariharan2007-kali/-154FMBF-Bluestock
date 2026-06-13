-- Bluestock MF Analytics - 10 Analytical SQL Queries

-- Q1: Top 5 Funds by AUM
SELECT scheme_name, fund_house, category, aum_crore,
       RANK() OVER (ORDER BY aum_crore DESC) AS aum_rank
FROM fact_performance
ORDER BY aum_crore DESC
LIMIT 5;

-- Q2: Average NAV per Month (all funds)
SELECT SUBSTR(date,1,7) AS month, amfi_code,
       ROUND(AVG(nav),2) AS avg_nav
FROM fact_nav
GROUP BY month, amfi_code
ORDER BY month, amfi_code;

-- Q3: SIP Inflow YoY Growth
WITH monthly AS (
  SELECT CAST(SUBSTR(transaction_date,1,4) AS INTEGER) AS yr,
         CAST(SUBSTR(transaction_date,6,2) AS INTEGER) AS mo,
         SUM(amount_inr) AS inflow
  FROM fact_transactions
  WHERE transaction_type = 'Sip'
  GROUP BY yr, mo
),
prev AS (
  SELECT yr, mo, inflow,
         LAG(inflow,12) OVER (ORDER BY yr, mo) AS prev_year_inflow
  FROM monthly
)
SELECT yr, mo, inflow,
       ROUND((inflow - prev_year_inflow)*100.0/prev_year_inflow, 2) AS yoy_growth_pct
FROM prev WHERE prev_year_inflow IS NOT NULL
ORDER BY yr, mo;

-- Q4: Total Transactions by State (Top 10)
SELECT state, COUNT(*) AS num_transactions,
       ROUND(SUM(amount_inr)/1e7, 2) AS total_invested_crore
FROM fact_transactions
GROUP BY state
ORDER BY total_invested_crore DESC
LIMIT 10;

-- Q5: Funds with Expense Ratio < 1%
SELECT f.scheme_name, f.fund_house, f.category, f.plan,
       p.expense_ratio_pct, p.sharpe_ratio, p.return_3yr_pct
FROM fact_performance p
JOIN dim_fund f ON f.amfi_code = p.amfi_code
WHERE p.expense_ratio_pct < 1.0
ORDER BY p.expense_ratio_pct;

-- Q6: Top Performing Funds by 3-Year CAGR
SELECT scheme_name, fund_house, category,
       return_3yr_pct, benchmark_3yr_pct,
       ROUND(return_3yr_pct - benchmark_3yr_pct, 2) AS outperformance_pct
FROM fact_performance
ORDER BY return_3yr_pct DESC
LIMIT 10;

-- Q7: Monthly SIP Count and Avg Ticket Size
SELECT SUBSTR(transaction_date,1,7) AS month,
       COUNT(*) AS num_sips,
       ROUND(AVG(amount_inr),0) AS avg_sip_amount,
       ROUND(SUM(amount_inr)/1e7,2) AS total_crore
FROM fact_transactions
WHERE transaction_type = 'Sip'
GROUP BY month
ORDER BY month;

-- Q8: Investor Gender & Age Group Distribution
SELECT age_group, gender,
       COUNT(DISTINCT investor_id) AS investors,
       ROUND(AVG(amount_inr),0) AS avg_amount
FROM fact_transactions
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- Q9: T30 vs B30 City Tier Analysis
SELECT city_tier,
       COUNT(*) AS transactions,
       COUNT(DISTINCT investor_id) AS unique_investors,
       ROUND(SUM(amount_inr)/1e7, 2) AS total_invested_crore,
       ROUND(AVG(amount_inr), 0) AS avg_ticket_size
FROM fact_transactions
GROUP BY city_tier;

-- Q10: Funds with Highest Sharpe Ratio by Category
SELECT category,
       scheme_name, fund_house,
       sharpe_ratio, sortino_ratio, return_3yr_pct
FROM (
  SELECT *, RANK() OVER (PARTITION BY category ORDER BY sharpe_ratio DESC) AS rk
  FROM fact_performance
) WHERE rk = 1
ORDER BY sharpe_ratio DESC;
