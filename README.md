# Running Breadboard Experiments on Prolific

A guide to setting up and running Breadboard experiments through Prolific, including payments, group-study rules, troubleshooting and testing.

Authored by Karen Gao. Updated by Eric Feltham (eric.feltham@aya.yale.edu), October 2026.

## Files

| File | What it is |
| --- | --- |
| `guide.typ` | The current guide (Typst source). Edit this file. |
| `guide.pdf` | Compiled copy of `guide.typ`. |
| `bulk_bonus.py` | Script that turns a Breadboard event CSV into Prolific's bulk bonus format. The guide includes it as Appendix B. |
| `media/` | Screenshots used by the guide. |
| `Running Breadboard Experiments on Prolific.docx` | The original Word guide (July 2024), kept for reference. `guide.typ` supersedes it. |

## Building

```sh
typst compile guide.typ guide.pdf
```

`guide.typ` reads `bulk_bonus.py` and the images in `media/`, so keep them next to it.

## The bonus script

```sh
python bulk_bonus.py EVENTS.csv --prolific-export PROLIFIC.csv
```

It needs `pandas`. See Appendix B of the guide for what it reads and writes. It has been tested only on synthetic data, not on a real Breadboard or Prolific export.

## Breadboard source copy

The guide's Breadboard claims were checked against `~/breadboard-v2-working`, a copy of a Breadboard v2 tree (jar `breadboard-v2.3.1.jar`). It is **not** the live install. It is kept for inspecting the engine, the Groovy DSL (`groovy/`) and the bundled dependencies, and nothing there is running.

Use it as a reference, with these limits:

- **Confirmed from it:** the CSV export columns (`id, event, event_date, data_name, data_value`), the `/game/<experiment>/<instance>/...` URL scheme, and the scripting calls `g.addAI(a, n, behavior)` and `g.addVertices(n)`.
- **Not in it:** the `/game/.../prolific` login route, the revolution game's scripts (`kickPlayers`, `removedPlayer`, `exitType`, `player`, `bonus`) and the `DEV`/`SANDBOX` globals. The guide's server directory is `revolution-v2.4`, newer than this copy's 2.3.1, so these come from the game build and its scripts.
- **Do not infer** the live server's version, configuration or state from the copy. For questions about the real deployment, check the live install.

## Still to verify

Not confirmed against a live Breadboard or Prolific session:

- The Breadboard `player` value in the CSV is the Prolific participant ID (the guide tells readers to confirm this with a test participant).
- Whether the Prolific web download's first column is headed "Submission ID", "Session ID" or something else.
- Whether Prolific's bulk bonus tool in the web UI has a review screen showing the total charge. Prolific's help center and API docs disagree about whether bulk bonuses can be paid in the web UI.
- The Prolific screenshots show an older layout. The guide's text names the current fields and says so.
