"""
Bluestock Mutual Fund Analytics Project

Description:
Master pipeline script to execute the full ETL and validation
sequence in order. Run from the project root:

    python scripts/run_pipeline.py
"""

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent

steps = [
    ("Validating AMFI codes",     ["validate_codes.py"]),
    ("Running ETL pipeline",      ["etl_pipeline.py"]),
]

print("Starting Bluestock MF Analytics Pipeline...")
print("=" * 50)

for label, script_args in steps:
    print(f"\n>> {label}")
    result = subprocess.run(
        [sys.executable, str(ROOT / "scripts" / script_args[0])] + script_args[1:],
        capture_output=False,
    )
    if result.returncode != 0:
        print(f"Step failed: {label}")
        sys.exit(result.returncode)

print("\n" + "=" * 50)
print("Pipeline executed successfully.")
print("DB: data/db/bluestock_mf.db")
print("Cleaned CSVs: data/processed/")
print("\nNext steps:")
print("  - Run notebooks/01-05 for ingestion, EDA, performance & advanced analytics")
print("  - python scripts/recommender.py  (fund recommendation by risk appetite)")
