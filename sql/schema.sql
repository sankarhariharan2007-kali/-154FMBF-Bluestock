-- Bluestock MF Analytics - Star Schema DDL
-- SQLite compatible

CREATE TABLE IF NOT EXISTS dim_fund (
    amfi_code           INTEGER PRIMARY KEY,
    fund_house          TEXT    NOT NULL,
    scheme_name         TEXT    NOT NULL,
    category            TEXT,
    sub_category        TEXT,
    plan                TEXT,
    launch_date         TEXT,
    benchmark           TEXT,
    expense_ratio_pct   REAL,
    exit_load_pct       REAL,
    min_sip_amount      REAL,
    min_lumpsum_amount  REAL,
    fund_manager        TEXT,
    risk_category       TEXT,
    sebi_category_code  TEXT
);

CREATE TABLE IF NOT EXISTS dim_date (
    date        TEXT PRIMARY KEY,
    year        INTEGER,
    quarter     INTEGER,
    month       INTEGER,
    month_name  TEXT,
    week        INTEGER,
    day_of_week TEXT,
    is_weekend  INTEGER
);

CREATE TABLE IF NOT EXISTS fact_nav (
    amfi_code         INTEGER REFERENCES dim_fund(amfi_code),
    date              TEXT    REFERENCES dim_date(date),
    nav               REAL    CHECK (nav > 0),
    daily_return_pct  REAL,
    PRIMARY KEY (amfi_code, date)
);

CREATE TABLE IF NOT EXISTS fact_transactions (
    investor_id          TEXT,
    transaction_date     TEXT  REFERENCES dim_date(date),
    amfi_code            INTEGER REFERENCES dim_fund(amfi_code),
    transaction_type     TEXT  CHECK (transaction_type IN ('Sip','Lumpsum','Redemption')),
    amount_inr           REAL  CHECK (amount_inr > 0),
    state                TEXT,
    city                 TEXT,
    city_tier            TEXT,
    age_group            TEXT,
    gender               TEXT,
    annual_income_lakh   REAL,
    payment_mode         TEXT,
    kyc_status           TEXT
);

CREATE TABLE IF NOT EXISTS fact_performance (
    amfi_code           INTEGER PRIMARY KEY REFERENCES dim_fund(amfi_code),
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
    aum_crore           REAL,
    expense_ratio_pct   REAL,
    morningstar_rating  INTEGER,
    risk_grade          TEXT
);

CREATE TABLE IF NOT EXISTS fact_aum (
    fund_house        TEXT,
    year              INTEGER,
    quarter           TEXT,
    month             TEXT,
    aum_lakh_crore    REAL,
    PRIMARY KEY (fund_house, year, month)
);

CREATE TABLE IF NOT EXISTS fact_portfolio (
    amfi_code         INTEGER REFERENCES dim_fund(amfi_code),
    stock_symbol      TEXT,
    stock_name        TEXT,
    sector            TEXT,
    weight_pct        REAL,
    market_value_cr   REAL,
    current_price_inr REAL,
    portfolio_date    TEXT
);
