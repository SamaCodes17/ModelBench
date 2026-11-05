# ModelBench

ModelBench is a SQLite database for recording and comparing language-model benchmark runs. It stores provider and model catalogs, benchmark suites and test cases, run-level configuration, individual responses, execution measurements, and evaluator scores. SQL views and reports calculate performance from those records.

ModelBench is a database project, not an inference service. It does not call model APIs or generate responses; users or an external evaluation process add the observations. The included records are synthetic and do not describe the real performance of commercial models.

## Quick Start

Install the SQLite command-line program, open a fresh database from this directory, and load the two SQL files:

```text
sqlite3 modelbench.db
sqlite> .read schema.sql
sqlite> .read queries.sql
```

`schema.sql` creates the tables, indexes, triggers, and reporting views. `queries.sql` inserts the sample dataset in a transaction and then runs 21 reports. Run the seed file only once in a fresh database; its inserts are intentionally not a repeatable migration.

## What the Reports Show

- Model and provider catalogs, versions, and model counts
- Suite leaderboards and top-scoring model versions
- Response-weighted scores, latency, recorded token counts, and cost
- Hallucination rates based on evaluated responses
- Success, error, and timeout counts
- Scores by difficulty and test case
- Evaluator disagreements and raw response notes

The score-per-dollar report is blank when any attempt in that model-version/suite row lacks a score or recorded cost. This avoids presenting a partial cost total as a complete comparison. Unknown token and cost values remain `NULL` in the database.

## Project Files

- `schema.sql` defines the normalized schema, integrity constraints, indexes, triggers, and views.
- `queries.sql` contains synthetic seed data and the reporting queries.
- `DESIGN.md` documents the data model, relationships, integrity rules, aggregation choices, and limitations.

The sample includes a timeout, a deliberately fabricated answer, and a human/rule-based scoring disagreement to exercise the related reports. See `DESIGN.md` for how each metric is calculated and what conclusions the synthetic data can support.
