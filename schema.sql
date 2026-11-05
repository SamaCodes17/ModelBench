-- ============================================================
-- ModelBench: LLM Evaluation and Benchmarking Database
-- Database engine: SQLite 3.30 or newer
-- (window functions and NULLS LAST are used in the views)
--
-- Load order: schema.sql, then seed.sql, then queries.sql
-- ============================================================

PRAGMA foreign_keys = ON;

-- ------------------------------------------------------------
-- 1. Providers
-- Organizations that develop or distribute AI models.
-- ------------------------------------------------------------
CREATE TABLE providers (
    provider_id INTEGER PRIMARY KEY,
    provider_name TEXT NOT NULL UNIQUE,
    website TEXT,
    headquarters TEXT
);

-- ------------------------------------------------------------
-- 2. Models
-- A provider can offer multiple models.
-- ------------------------------------------------------------
CREATE TABLE models (
    model_id INTEGER PRIMARY KEY,
    provider_id INTEGER NOT NULL,
    model_name TEXT NOT NULL,
    model_type TEXT NOT NULL
        CHECK (model_type IN ('LLM', 'Multimodal', 'Embedding', 'Other')),
    description TEXT,
    FOREIGN KEY (provider_id)
        REFERENCES providers(provider_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    UNIQUE (provider_id, model_name)
);

-- ------------------------------------------------------------
-- 3. Model versions
-- Separating versions allows historical comparisons.
-- ------------------------------------------------------------
CREATE TABLE model_versions (
    version_id INTEGER PRIMARY KEY,
    model_id INTEGER NOT NULL,
    version_name TEXT NOT NULL,
    release_date TEXT,
    context_window INTEGER
        CHECK (context_window IS NULL OR context_window > 0),
    is_active INTEGER NOT NULL DEFAULT 1
        CHECK (is_active IN (0, 1)),
    FOREIGN KEY (model_id)
        REFERENCES models(model_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    UNIQUE (model_id, version_name)
);

-- ------------------------------------------------------------
-- 4. Benchmark categories
-- Broad areas such as coding, reasoning and mathematics.
-- ------------------------------------------------------------
CREATE TABLE benchmark_categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL UNIQUE,
    description TEXT
);

-- ------------------------------------------------------------
-- 5. Benchmark suites
-- A suite groups related test cases within a category.
-- ------------------------------------------------------------
CREATE TABLE benchmark_suites (
    suite_id INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL,
    suite_name TEXT NOT NULL,
    description TEXT,
    scoring_guideline TEXT,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id)
        REFERENCES benchmark_categories(category_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    UNIQUE (category_id, suite_name)
);

-- ------------------------------------------------------------
-- 6. Test cases
-- Each test case belongs to exactly one benchmark suite.
-- expected_answer is the reference answer or evaluation target.
-- max_score is the top mark of this test's own rubric; raw scores
-- in evaluations are converted to a 0-100 scale using it.
-- ------------------------------------------------------------
CREATE TABLE test_cases (
    test_case_id INTEGER PRIMARY KEY,
    suite_id INTEGER NOT NULL,
    prompt TEXT NOT NULL,
    expected_answer TEXT,
    difficulty TEXT NOT NULL
        CHECK (difficulty IN ('Easy', 'Medium', 'Hard', 'Expert')),
    max_score REAL NOT NULL DEFAULT 100
        CHECK (max_score > 0),
    is_active INTEGER NOT NULL DEFAULT 1
        CHECK (is_active IN (0, 1)),
    FOREIGN KEY (suite_id)
        REFERENCES benchmark_suites(suite_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- ------------------------------------------------------------
-- 7. Benchmark runs
-- One run evaluates one model version against one suite.
-- attempt_number lets the same version/suite be run again
-- (a repeat) without overwriting the earlier run.
-- ------------------------------------------------------------
CREATE TABLE benchmark_runs (
    run_id INTEGER PRIMARY KEY,
    version_id INTEGER NOT NULL,
    suite_id INTEGER NOT NULL,
    attempt_number INTEGER NOT NULL DEFAULT 1
        CHECK (attempt_number >= 1),
    run_date TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status TEXT NOT NULL DEFAULT 'Pending'
        CHECK (status IN ('Pending', 'Running', 'Completed', 'Failed')),
    configuration TEXT,
    started_at TEXT,
    completed_at TEXT,
    notes TEXT,
    FOREIGN KEY (version_id)
        REFERENCES model_versions(version_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (suite_id)
        REFERENCES benchmark_suites(suite_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    UNIQUE (version_id, suite_id, attempt_number),
    CHECK (
        completed_at IS NULL
        OR started_at IS NULL
        OR completed_at >= started_at
    ),
    -- A completed run has a completion time; a pending or running run has none.
    CHECK (status <> 'Completed' OR completed_at IS NOT NULL),
    CHECK (status NOT IN ('Pending', 'Running') OR completed_at IS NULL)
);

-- ------------------------------------------------------------
-- 8. Test results
-- Stores the raw response and execution measurements.
-- One result per test case per benchmark run.
-- Failed executions are retained for reliability analysis.
-- ------------------------------------------------------------
CREATE TABLE test_results (
    result_id INTEGER PRIMARY KEY,
    run_id INTEGER NOT NULL,
    test_case_id INTEGER NOT NULL,
    response TEXT,
    execution_status TEXT NOT NULL
        CHECK (execution_status IN ('Success', 'Error', 'Timeout')),
    latency_ms REAL
        CHECK (latency_ms IS NULL OR latency_ms >= 0),
    input_tokens INTEGER
        CHECK (input_tokens IS NULL OR input_tokens >= 0),
    output_tokens INTEGER
        CHECK (output_tokens IS NULL OR output_tokens >= 0),
    estimated_cost_usd REAL
        CHECK (estimated_cost_usd IS NULL OR estimated_cost_usd >= 0),
    error_message TEXT,
    executed_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (run_id)
        REFERENCES benchmark_runs(run_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (test_case_id)
        REFERENCES test_cases(test_case_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    UNIQUE (run_id, test_case_id),
    -- A successful execution must have produced a response.
    CHECK (execution_status <> 'Success' OR response IS NOT NULL)
);

-- ------------------------------------------------------------
-- 9. Evaluation methods
-- Defines how a response is assessed.
-- ------------------------------------------------------------
CREATE TABLE evaluation_methods (
    method_id INTEGER PRIMARY KEY,
    method_name TEXT NOT NULL UNIQUE,
    method_type TEXT NOT NULL
        CHECK (method_type IN ('Human', 'Automated', 'Rule-based')),
    description TEXT
);

-- ------------------------------------------------------------
-- 10. Evaluators
-- People or systems that perform evaluations.
-- ------------------------------------------------------------
CREATE TABLE evaluators (
    evaluator_id INTEGER PRIMARY KEY,
    evaluator_name TEXT NOT NULL UNIQUE,
    evaluator_type TEXT NOT NULL
        CHECK (evaluator_type IN ('Human', 'AI Model', 'System'))
);

-- ------------------------------------------------------------
-- 11. Evaluations
-- Multiple evaluators/methods may assess one test result.
-- raw_score is the mark on the test case's own scale (0 to
-- test_cases.max_score). The normalized 0-100 score is derived
-- by the v_evaluation_scores view, so it can never drift.
-- hallucination_flag is NULL when the evaluator did not assess
-- hallucination, which is different from assessing it as 0.
-- ------------------------------------------------------------
CREATE TABLE evaluations (
    evaluation_id INTEGER PRIMARY KEY,
    result_id INTEGER NOT NULL,
    method_id INTEGER NOT NULL,
    evaluator_id INTEGER NOT NULL,
    raw_score REAL NOT NULL
        CHECK (raw_score >= 0),
    hallucination_flag INTEGER
        CHECK (hallucination_flag IS NULL OR hallucination_flag IN (0, 1)),
    correctness_notes TEXT,
    evaluated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (result_id)
        REFERENCES test_results(result_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (method_id)
        REFERENCES evaluation_methods(method_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (evaluator_id)
        REFERENCES evaluators(evaluator_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    UNIQUE (result_id, method_id, evaluator_id)
);

-- ============================================================
-- INDEXES
-- Index foreign-key columns and common filtering dimensions.
-- Composite UNIQUE constraints already index these prefixes:
--   models(provider_id), model_versions(model_id),
--   benchmark_suites(category_id), test_results(run_id),
--   evaluations(result_id), benchmark_runs(version_id)
-- ============================================================

CREATE INDEX idx_test_cases_suite
    ON test_cases(suite_id);

-- Serves "most recent run for a model version".
CREATE INDEX idx_runs_version_date
    ON benchmark_runs(version_id, run_date DESC);

CREATE INDEX idx_runs_suite
    ON benchmark_runs(suite_id);

CREATE INDEX idx_runs_status
    ON benchmark_runs(status);

CREATE INDEX idx_results_test_case
    ON test_results(test_case_id);

CREATE INDEX idx_results_execution_status
    ON test_results(execution_status);

CREATE INDEX idx_evaluations_method
    ON evaluations(method_id);

CREATE INDEX idx_evaluations_evaluator
    ON evaluations(evaluator_id);

-- ============================================================
-- TRIGGERS
-- Enforce consistency that cannot be expressed with a simple
-- foreign key or CHECK constraint.
-- ============================================================

-- A test result must belong to a test case from the same suite
-- that the benchmark run is evaluating.
CREATE TRIGGER validate_result_suite
BEFORE INSERT ON test_results
FOR EACH ROW
WHEN (
    SELECT suite_id FROM test_cases WHERE test_case_id = NEW.test_case_id
) IS NOT (
    SELECT suite_id FROM benchmark_runs WHERE run_id = NEW.run_id
)
BEGIN
    SELECT RAISE(ABORT, 'Test case does not belong to the run benchmark suite');
END;

-- Do not add results to a run that is not currently running.
CREATE TRIGGER validate_run_status
BEFORE INSERT ON test_results
FOR EACH ROW
WHEN (
    SELECT status FROM benchmark_runs WHERE run_id = NEW.run_id
) IS NOT 'Running'
BEGIN
    SELECT RAISE(ABORT, 'Results can only be added to a running benchmark');
END;

-- Apply the same suite-consistency rule if a result is updated.
CREATE TRIGGER validate_result_suite_update
BEFORE UPDATE OF run_id, test_case_id ON test_results
FOR EACH ROW
WHEN (
    SELECT suite_id FROM test_cases WHERE test_case_id = NEW.test_case_id
) IS NOT (
    SELECT suite_id FROM benchmark_runs WHERE run_id = NEW.run_id
)
BEGIN
    SELECT RAISE(ABORT, 'Test case does not belong to the run benchmark suite');
END;

-- Moving an existing run to another suite must not invalidate its results.
CREATE TRIGGER validate_run_suite_update
BEFORE UPDATE OF suite_id ON benchmark_runs
FOR EACH ROW
WHEN EXISTS (
    SELECT 1
    FROM test_results tr
    JOIN test_cases tc ON tc.test_case_id = tr.test_case_id
    WHERE tr.run_id = OLD.run_id
      AND tc.suite_id IS NOT NEW.suite_id
)
BEGIN
    SELECT RAISE(ABORT, 'Run suite cannot change while results belong to another suite');
END;

-- Moving a test case must not invalidate results already recorded for it.
CREATE TRIGGER validate_test_case_suite_update
BEFORE UPDATE OF suite_id ON test_cases
FOR EACH ROW
WHEN EXISTS (
    SELECT 1
    FROM test_results tr
    JOIN benchmark_runs br ON br.run_id = tr.run_id
    WHERE tr.test_case_id = OLD.test_case_id
      AND br.suite_id IS NOT NEW.suite_id
)
BEGIN
    SELECT RAISE(ABORT, 'Test case suite cannot change while results belong to another suite');
END;

-- A result may be transferred only into a run that is still in progress.
CREATE TRIGGER validate_run_status_update
BEFORE UPDATE OF run_id ON test_results
FOR EACH ROW
WHEN NEW.run_id <> OLD.run_id
 AND (SELECT status FROM benchmark_runs WHERE run_id = NEW.run_id) IS NOT 'Running'
BEGIN
    SELECT RAISE(ABORT, 'Results can only be moved to a running benchmark');
END;

-- A finished run is a historical record: it cannot be reopened.
CREATE TRIGGER prevent_run_reopen
BEFORE UPDATE OF status ON benchmark_runs
FOR EACH ROW
WHEN OLD.status IN ('Completed', 'Failed')
 AND NEW.status <> OLD.status
BEGIN
    SELECT RAISE(ABORT, 'A completed or failed run cannot change status');
END;

-- Only a response that was actually produced can be evaluated.
CREATE TRIGGER validate_evaluated_result
BEFORE INSERT ON evaluations
FOR EACH ROW
WHEN (
    SELECT execution_status FROM test_results WHERE result_id = NEW.result_id
) IS NOT 'Success'
BEGIN
    SELECT RAISE(ABORT, 'Only successful responses can be evaluated');
END;

-- A raw score cannot exceed the maximum of the test case it grades.
CREATE TRIGGER validate_raw_score_insert
BEFORE INSERT ON evaluations
FOR EACH ROW
WHEN NEW.raw_score > (
    SELECT tc.max_score
    FROM test_results tr
    JOIN test_cases tc ON tc.test_case_id = tr.test_case_id
    WHERE tr.result_id = NEW.result_id
)
BEGIN
    SELECT RAISE(ABORT, 'raw_score exceeds the test case max_score');
END;

CREATE TRIGGER validate_raw_score_update
BEFORE UPDATE OF raw_score, result_id ON evaluations
FOR EACH ROW
WHEN NEW.raw_score > (
    SELECT tc.max_score
    FROM test_results tr
    JOIN test_cases tc ON tc.test_case_id = tr.test_case_id
    WHERE tr.result_id = NEW.result_id
)
BEGIN
    SELECT RAISE(ABORT, 'raw_score exceeds the test case max_score');
END;

-- Lowering a test case maximum must not invalidate recorded scores.
CREATE TRIGGER validate_max_score_update
BEFORE UPDATE OF max_score ON test_cases
FOR EACH ROW
WHEN EXISTS (
    SELECT 1
    FROM test_results tr
    JOIN evaluations e ON e.result_id = tr.result_id
    WHERE tr.test_case_id = OLD.test_case_id
      AND e.raw_score > NEW.max_score
)
BEGIN
    SELECT RAISE(ABORT, 'max_score is below an existing raw_score');
END;

-- An evaluated result cannot later be turned into a failed execution.
CREATE TRIGGER protect_evaluated_result
BEFORE UPDATE OF execution_status ON test_results
FOR EACH ROW
WHEN NEW.execution_status <> 'Success'
 AND EXISTS (SELECT 1 FROM evaluations WHERE result_id = OLD.result_id)
BEGIN
    SELECT RAISE(ABORT, 'A result with evaluations must stay Success');
END;

-- ============================================================
-- VIEWS
-- Reusable analytical summaries for SQL reporting.
-- ============================================================

-- Every evaluation with its score converted to the shared 0-100 scale.
-- Not rounded, so later averages do not accumulate rounding error.
CREATE VIEW v_evaluation_scores AS
SELECT
    e.evaluation_id,
    e.result_id,
    e.method_id,
    e.evaluator_id,
    e.raw_score,
    tc.max_score,
    100.0 * e.raw_score / tc.max_score AS score,
    e.hallucination_flag,
    e.correctness_notes,
    e.evaluated_at
FROM evaluations e
JOIN test_results tr ON tr.result_id = e.result_id
JOIN test_cases tc ON tc.test_case_id = tr.test_case_id;

-- Summarizes performance by model version and benchmark suite using
-- completed runs. Evaluations are first averaged per response so a
-- response with several evaluations still counts once. Results from
-- repeat runs are pooled, weighting every response equally.
-- Averages are NOT rounded here; round when displaying.
CREATE VIEW v_model_performance AS
WITH result_evaluation AS (
    SELECT
        result_id,
        AVG(score) AS avg_score,
        AVG(hallucination_flag) AS hallucination_rate  -- NULL if never assessed
    FROM v_evaluation_scores
    GROUP BY result_id
),
result_metrics AS (
    SELECT
        tr.result_id,
        tr.run_id,
        tr.latency_ms,
        tr.input_tokens,
        tr.output_tokens,
        tr.estimated_cost_usd,
        tr.execution_status,
        re.avg_score,
        re.hallucination_rate
    FROM test_results tr
    LEFT JOIN result_evaluation re
        ON tr.result_id = re.result_id
),
run_metrics AS (
    SELECT
        br.run_id,
        br.version_id,
        br.suite_id,
        COUNT(rm.result_id) AS total_tests,
        SUM(CASE WHEN rm.execution_status = 'Success' THEN 1 ELSE 0 END)
            AS successful_tests,
        SUM(CASE WHEN rm.execution_status = 'Error' THEN 1 ELSE 0 END)
            AS error_tests,
        SUM(CASE WHEN rm.execution_status = 'Timeout' THEN 1 ELSE 0 END)
            AS timeout_tests,
        COUNT(rm.avg_score) AS evaluated_tests,
        SUM(rm.avg_score) AS total_score,
        COUNT(rm.hallucination_rate) AS hallucination_assessed,
        SUM(rm.hallucination_rate) AS hallucination_weight,
        -- Latency of failed attempts (e.g. a 30 s timeout) is excluded
        -- so it does not distort the speed of normal responses.
        COUNT(CASE WHEN rm.execution_status = 'Success'
                   THEN rm.latency_ms END) AS success_latency_observations,
        SUM(CASE WHEN rm.execution_status = 'Success'
                 THEN rm.latency_ms END) AS total_success_latency_ms,
        SUM(rm.input_tokens) AS total_input_tokens,
        SUM(rm.output_tokens) AS total_output_tokens,
        COUNT(rm.estimated_cost_usd) AS cost_observations,
        SUM(rm.estimated_cost_usd) AS total_cost_usd
    FROM benchmark_runs br
    LEFT JOIN result_metrics rm
        ON br.run_id = rm.run_id
    WHERE br.status = 'Completed'
    GROUP BY br.run_id, br.version_id, br.suite_id
)
SELECT
    p.provider_name,
    m.model_name,
    mv.version_name,
    bc.category_name,
    bs.suite_name,
    COUNT(rm.run_id) AS completed_runs,
    SUM(rm.total_tests) AS total_tests,
    SUM(rm.evaluated_tests) AS evaluated_tests,
    SUM(rm.successful_tests) AS successful_tests,
    SUM(rm.error_tests) AS error_tests,
    SUM(rm.timeout_tests) AS timeout_tests,
    SUM(rm.total_score) AS total_score,
    SUM(rm.total_score) / NULLIF(SUM(rm.evaluated_tests), 0) AS avg_score,
    SUM(rm.hallucination_assessed) AS hallucination_assessed,
    100.0 * SUM(rm.hallucination_weight)
        / NULLIF(SUM(rm.hallucination_assessed), 0) AS hallucination_rate_pct,
    SUM(rm.success_latency_observations) AS success_latency_observations,
    1.0 * SUM(rm.total_success_latency_ms)
        / NULLIF(SUM(rm.success_latency_observations), 0)
        AS avg_success_latency_ms,
    SUM(rm.total_input_tokens) AS total_input_tokens,
    SUM(rm.total_output_tokens) AS total_output_tokens,
    SUM(rm.cost_observations) AS cost_observations,
    SUM(rm.total_cost_usd) AS total_cost_usd
FROM run_metrics rm
JOIN model_versions mv
    ON rm.version_id = mv.version_id
JOIN models m
    ON mv.model_id = m.model_id
JOIN providers p
    ON m.provider_id = p.provider_id
JOIN benchmark_suites bs
    ON rm.suite_id = bs.suite_id
JOIN benchmark_categories bc
    ON bs.category_id = bc.category_id
GROUP BY
    p.provider_name,
    m.model_id,
    m.model_name,
    mv.version_id,
    mv.version_name,
    bc.category_id,
    bc.category_name,
    bs.suite_id,
    bs.suite_name;

-- Ranks model versions within each suite. Scores are comparable here
-- because every ranked version used the same benchmark suite.
-- Ranking uses the unrounded score; the displayed values are rounded.
CREATE VIEW v_model_leaderboard AS
WITH ranked AS (
    SELECT
        provider_name,
        model_name,
        version_name,
        category_name,
        suite_name,
        avg_score,
        hallucination_rate_pct,
        avg_success_latency_ms,
        total_cost_usd,
        RANK() OVER (
            PARTITION BY category_name, suite_name
            ORDER BY
                avg_score DESC,
                avg_success_latency_ms ASC NULLS LAST
        ) AS suite_rank
    FROM v_model_performance
    WHERE avg_score IS NOT NULL
)
SELECT
    provider_name,
    model_name,
    version_name,
    category_name,
    suite_name,
    ROUND(avg_score, 2) AS avg_score,
    ROUND(hallucination_rate_pct, 2) AS hallucination_rate_pct,
    ROUND(avg_success_latency_ms, 2) AS avg_success_latency_ms,
    ROUND(total_cost_usd, 6) AS total_cost_usd,
    suite_rank
FROM ranked;
