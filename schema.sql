-- ============================================================
-- schema.sql
-- Bluestock Fintech — Mutual Fund Analytics Capstone
-- Star Schema: 2 Dimension + 9 Fact tables
-- Database: bluestock_mf.db (SQLite)
-- ============================================================

PRAGMA foreign_keys = ON;

-- ─────────────────────────────────────────────────────────────
-- DIMENSION TABLES
-- ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS dim_fund (
    amfi_code           INTEGER     PRIMARY KEY,
    fund_house          TEXT        NOT NULL,
    scheme_name         TEXT        NOT NULL,
    category            TEXT        NOT NULL,          -- Equity / Debt / Hybrid
    sub_category        TEXT,                          -- Large Cap / Mid Cap / Liquid etc.
    plan                TEXT        NOT NULL,          -- Direct / Regular
    launch_date         DATE,
    benchmark           TEXT,
    expense_ratio_pct   REAL,
    exit_load_pct       REAL,
    fund_manager        TEXT,
    risk_category       TEXT,                          -- Low / Moderate / High / Very High
    sebi_category_code  TEXT
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_id     INTEGER     PRIMARY KEY AUTOINCREMENT,
    date        DATE        NOT NULL UNIQUE,
    year        INTEGER     NOT NULL,
    month       INTEGER     NOT NULL,
    month_name  TEXT        NOT NULL,
    quarter     INTEGER     NOT NULL,
    week        INTEGER,
    day_of_week TEXT,
    is_weekday  INTEGER     DEFAULT 1                  -- 1 = weekday, 0 = weekend
);

-- ─────────────────────────────────────────────────────────────
-- FACT TABLES
-- ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS fact_nav (
    id                  INTEGER     PRIMARY KEY AUTOINCREMENT,
    amfi_code           INTEGER     NOT NULL REFERENCES dim_fund(amfi_code),
    date                DATE        NOT NULL,
    nav                 REAL        NOT NULL CHECK (nav > 0),
    daily_return_pct    REAL,
    UNIQUE (amfi_code, date)
);

CREATE TABLE IF NOT EXISTS fact_transactions (
    investor_id         TEXT        NOT NULL,
    transaction_date    DATE        NOT NULL,
    amfi_code           INTEGER     NOT NULL REFERENCES dim_fund(amfi_code),
    transaction_type    TEXT        NOT NULL CHECK (transaction_type IN ('SIP','Lumpsum','Redemption')),
    amount_inr          INTEGER     NOT NULL CHECK (amount_inr > 0),
    state               TEXT,
    city                TEXT,
    city_tier           TEXT        CHECK (city_tier IN ('T30','B30')),
    age_group           TEXT,
    gender              TEXT        CHECK (gender IN ('Male','Female')),
    annual_income_lakh  REAL,
    payment_mode        TEXT,
    kyc_status          TEXT        CHECK (kyc_status IN ('Verified','Pending'))
);

CREATE TABLE IF NOT EXISTS fact_performance (
    amfi_code           INTEGER     PRIMARY KEY REFERENCES dim_fund(amfi_code),
    scheme_name         TEXT,
    fund_house          TEXT,
    category            TEXT,
    plan                TEXT,
    return_1yr_pct      REAL,
    return_3yr_pct      REAL,
    return_5yr_pct      REAL,
    benchmark_3yr_pct   REAL,
    alpha               REAL,
    beta                REAL,
    sharpe_ratio        REAL,
    sortino_ratio       REAL,
    std_dev_ann_pct     REAL,
    max_drawdown_pct    REAL,
    aum_crore           INTEGER,
    expense_ratio_pct   REAL,
    morningstar_rating  INTEGER     CHECK (morningstar_rating BETWEEN 1 AND 5),
    risk_grade          TEXT
);

CREATE TABLE IF NOT EXISTS fact_aum (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    date            DATE    NOT NULL,
    fund_house      TEXT    NOT NULL,
    aum_lakh_crore  REAL,
    aum_crore       INTEGER,
    num_schemes     INTEGER,
    UNIQUE (date, fund_house)
);

CREATE TABLE IF NOT EXISTS fact_sip_industry (
    month                       TEXT    PRIMARY KEY,  -- YYYY-MM
    sip_inflow_crore            INTEGER,
    active_sip_accounts_crore   REAL,
    new_sip_accounts_lakh       REAL,
    sip_aum_lakh_crore          REAL,
    yoy_growth_pct              REAL    -- NULL for first 12 months
);

CREATE TABLE IF NOT EXISTS fact_portfolio (
    id                  INTEGER PRIMARY KEY AUTOINCREMENT,
    amfi_code           INTEGER NOT NULL REFERENCES dim_fund(amfi_code),
    stock_symbol        TEXT    NOT NULL,
    stock_name          TEXT,
    sector              TEXT,
    weight_pct          REAL    CHECK (weight_pct BETWEEN 0 AND 100),
    market_value_cr     REAL,
    current_price_inr   REAL,
    portfolio_date      DATE
);

CREATE TABLE IF NOT EXISTS fact_category_inflows (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    month           TEXT    NOT NULL,
    category        TEXT    NOT NULL,
    net_inflow_crore REAL,
    UNIQUE (month, category)
);

CREATE TABLE IF NOT EXISTS fact_folio_count (
    month               TEXT    PRIMARY KEY,
    total_folios_crore  REAL,
    equity_folios_crore REAL,
    debt_folios_crore   REAL,
    hybrid_folios_crore REAL,
    others_folios_crore REAL
);

CREATE TABLE IF NOT EXISTS fact_benchmark_indices (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    date        DATE    NOT NULL,
    index_name  TEXT    NOT NULL,
    close_value REAL    NOT NULL,
    UNIQUE (date, index_name)
);

-- ─────────────────────────────────────────────────────────────
-- INDEXES for query performance
-- ─────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_nav_code_date     ON fact_nav(amfi_code, date);
CREATE INDEX IF NOT EXISTS idx_txn_code          ON fact_transactions(amfi_code);
CREATE INDEX IF NOT EXISTS idx_txn_date          ON fact_transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_txn_state         ON fact_transactions(state);
CREATE INDEX IF NOT EXISTS idx_benchmark_date    ON fact_benchmark_indices(date, index_name);
CREATE INDEX IF NOT EXISTS idx_aum_date          ON fact_aum(date);
CREATE INDEX IF NOT EXISTS idx_portfolio_code    ON fact_portfolio(amfi_code);
