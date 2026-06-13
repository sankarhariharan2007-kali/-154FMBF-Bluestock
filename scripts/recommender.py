"""
Bluestock Mutual Fund Analytics Project

Description:
This script recommends the top 3 mutual funds based on the
investor's selected risk appetite (Low / Moderate / High).
Funds are ranked using the calculated Sharpe Ratio from the
fund scorecard to identify better risk-adjusted investment options.

Run from project root: python scripts/recommender.py
"""

import pandas as pd
from pathlib import Path

ROOT = Path(__file__).parent.parent
scorecard_df = pd.read_csv(ROOT / "data" / "processed" / "fund_scorecard.csv")

# Map broad risk appetite to the dataset's risk_grade values
RISK_MAP = {
    "Low": ["Low", "Low to Moderate"],
    "Moderate": ["Moderate", "Moderately High"],
    "High": ["High", "Very High"],
}

# Get investor risk preference
risk = input("Enter Risk Level (Low/Moderate/High): ").strip().title()

if risk not in RISK_MAP:
    print(f"Invalid risk level '{risk}'. Choose Low, Moderate, or High.")
else:
    recommendation = (
        scorecard_df[scorecard_df["risk_grade"].isin(RISK_MAP[risk])]
        .sort_values("sharpe_calculated", ascending=False)
        .head(3)
    )

    print(f"\nTop 3 Recommended Funds for '{risk}' Risk Appetite:\n")
    print(
        recommendation[
            [
                "scheme_name",
                "fund_house",
                "category",
                "risk_grade",
                "sharpe_calculated",
                "cagr_3yr",
                "expense_ratio_pct",
            ]
        ].to_string(index=False)
    )
