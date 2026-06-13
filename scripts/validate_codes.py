"""
Bluestock Mutual Fund Analytics Project

Description:
Validates that every AMFI scheme code in fund_master also exists
in nav_history, and reports any mismatches as part of the
Day 1 data quality summary.

Run from project root: python scripts/validate_codes.py
"""

import pandas as pd
from pathlib import Path

ROOT = Path(__file__).parent.parent
RAW = ROOT / "data" / "raw"

fund_master = pd.read_csv(RAW / "01_fund_master.csv")
nav_history = pd.read_csv(RAW / "02_nav_history.csv")

master_codes = set(fund_master["amfi_code"])
nav_codes = set(nav_history["amfi_code"])

missing_in_nav = master_codes - nav_codes
extra_in_nav = nav_codes - master_codes

print("AMFI Code Validation")
print("=" * 40)
print(f"Fund master codes : {len(master_codes)}")
print(f"NAV history codes : {len(nav_codes)}")
print(f"\nCodes in fund_master missing from nav_history: {len(missing_in_nav)}")
if missing_in_nav:
    print(sorted(missing_in_nav))
print(f"\nCodes in nav_history not in fund_master: {len(extra_in_nav)}")
if extra_in_nav:
    print(sorted(extra_in_nav))

if not missing_in_nav:
    print("\nResult: All fund_master AMFI codes are present in nav_history.")
else:
    print("\nResult: Some fund_master AMFI codes are MISSING from nav_history.")
