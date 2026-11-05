# ModelBench

ModelBench is a SQLite database for recording and comparing language-model benchmark runs. It stores provider and model catalogs, benchmark suites and test cases, run-level configuration, individual responses, execution measurements, and evaluator scores. SQL views and reports calculate performance from those records.

ModelBench is a database project, not an inference service. It does not call model APIs or generate responses; users or an external evaluation process add the observations. The included records are synthetic and do not describe the real performance of commercial models.

**Video overview:** <ADD VIDEO URL HERE>

## Quick Start

Requires the SQLite command-line program, version 3.30 or newer (check with `sqlite3 --version`). Open a fresh database from this directory and load the two SQL files in order:

```text
sqlite3 modelbench.db
sqlite> .read schema.sql
sqlite> .read queries.sql
```

- `schema.sql` creates the tables, indexes, triggers, and views.
- `queries.sql` inserts the synthetic sample data in one transaction, then runs 21 reports and 2 `EXPLAIN QUERY PLAN` examples. Load it **once** on a fresh database, because the sample inserts are not repeatable.

## What the Reports Show

- Model and provider catalogs, versions, and model counts
- Suite leaderboards and top-scoring model versions
- Response-weighted scores, latency, recorded token counts, and cost
- Hallucination rates based on responses where hallucination was actually assessed
- Success, error, and timeout counts
- Scores by difficulty and test case
- Evaluator disagreements and raw response notes

Scores are stored as `raw_score` on each test's own scale and converted to 0-100 by the `v_evaluation_scores` view. Latency averages use successful responses only. Unknown token and cost values remain `NULL`, and the score-per-dollar report is blank when any attempt in a model-version/suite row lacks a score or recorded cost.

## Project Files

- `DESIGN.md` documents scope, requirements, the data model, optimizations, and limitations.
- `schema.sql` defines the normalized schema, integrity constraints, indexes, triggers, and views.
- `queries.sql` contains the synthetic sample data (12 test cases, 10 runs, 39 responses, 40 evaluations), the reporting queries, query-plan examples, and commented data-modification examples.

The sample includes an execution error, a timeout, a deliberately fabricated answer, a repeated run, and human/rule-based scoring disagreements to exercise the related reports.
