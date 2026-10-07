"""
Format bulk bonus payments for Prolific from a Breadboard event export.

Usage:
    python bulk_bonus.py EVENTS.csv [--prolific-export PROLIFIC.csv]

EVENTS.csv is the CSV downloaded from the Breadboard console. Each
"removedPlayer" event carries the player, bonus (in cents) and exitType.

Prolific's bulk bonus tool needs submission IDs. If the Breadboard "player"
value is the Prolific participant ID, pass the Prolific "Download demographic
data" file with --prolific-export and the script swaps in submission IDs. It
refuses to write the payment file if any payee has no match.

Writes bulk_bonus_payment.csv ("id,amount", paste into Prolific) and
metadata_bonus.csv (id, amount, exit type, for reference), then prints a
summary to check against what Prolific shows before you pay.
"""
import argparse
import sys

import pandas as pd

EVENT_COLUMNS = {"id", "event", "event_date", "data_name", "data_value"}


def find_column(df, candidates, label):
    """Find a column by name, ignoring case, spaces and underscores."""
    norm = {c.lower().replace(" ", "").replace("_", ""): c for c in df.columns}
    for cand in candidates:
        if cand in norm:
            return norm[cand]
    sys.exit(f"Could not find the {label} column in the Prolific export. "
             f"Columns present: {list(df.columns)}")


def removed_players(events):
    """One row per removedPlayer event: player, bonus (dollars), exit type."""
    rows = []
    removed = events[events["event"] == "removedPlayer"]
    for _, group in removed.groupby("id"):
        values = {}
        for _, row in group.iterrows():
            values[row["data_name"]] = row["data_value"]
        if "player" in values and "bonus" in values:
            rows.append({
                "player": str(values["player"]),
                "bonus": round(float(values["bonus"]) / 100, 2),
                "exit_type": values.get("exitType"),
                "event_date": group["event_date"].min(),
            })
    return pd.DataFrame(rows, columns=["player", "bonus", "exit_type", "event_date"])


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("events", help="Breadboard event CSV")
    parser.add_argument("--prolific-export", help="Prolific 'Download demographic data' CSV")
    args = parser.parse_args()

    events = pd.read_csv(args.events, dtype=str)
    missing = EVENT_COLUMNS - set(events.columns)
    if missing:
        sys.exit(f"{args.events} is missing columns {sorted(missing)}; "
                 "is this the Breadboard event export?")

    players = removed_players(events)
    if players.empty:
        sys.exit("No removedPlayer events with a player and bonus were found.")

    # A player can be removed more than once; pay only the first removal.
    players = players.sort_values("event_date")
    duplicates = players["player"].duplicated().sum()
    players = players.drop_duplicates("player")

    if args.prolific_export:
        export = pd.read_csv(args.prolific_export, dtype=str)
        pid_col = find_column(export, ["participantid"], "participant ID")
        sid_col = find_column(export, ["submissionid", "sessionid"], "submission ID")
        lookup = dict(zip(export[pid_col], export[sid_col]))
        players["pay_id"] = players["player"].map(lookup)
        unmatched = players[players["pay_id"].isna() & (players["bonus"] != 0)]
        if not unmatched.empty:
            sys.exit("No Prolific submission found for: "
                     + ", ".join(unmatched["player"]) + "\nNothing written.")
    else:
        print("WARNING: no --prolific-export given; the output uses Breadboard "
              "player IDs, which Prolific's bulk bonus tool rejects unless they "
              "are submission IDs.")
        players["pay_id"] = players["player"]

    paid = players[players["bonus"] != 0]
    with open("bulk_bonus_payment.csv", "w") as out:
        for _, row in paid.iterrows():
            out.write(f"{row['pay_id']},{row['bonus']:.2f}\n")
    with open("metadata_bonus.csv", "w") as out:
        for _, row in players.iterrows():
            out.write(f"{row['pay_id']},{row['bonus']:.2f},{row['exit_type']}\n")

    print(f"Players removed: {len(players)} ({duplicates} repeat removals ignored)")
    print(f"Payments written: {len(paid)} ({len(players) - len(paid)} with no bonus)")
    print(f"Total bonus: {paid['bonus'].sum():.2f}")


if __name__ == "__main__":
    main()
