-- ============================================================
-- ModelBench: Sample data and commonly used SQL queries
-- Run schema.sql first, then execute this file.
--
-- IMPORTANT: All benchmark scores and measurements in this
-- seed dataset are synthetic examples for demonstrating SQL.
-- They are not claims about real commercial model performance.
-- ============================================================

-- Foreign-key enforcement is per connection, so enable it here too.
PRAGMA foreign_keys = ON;

-- ============================================================
-- PART 1: SAMPLE DATA
-- ============================================================

BEGIN TRANSACTION;

-- Providers
INSERT INTO providers (provider_id, provider_name, website, headquarters) VALUES
    (1, 'Northstar AI', 'https://example.com/northstar', 'United States'),
    (2, 'Aster Labs', 'https://example.com/aster', 'United Kingdom'),
    (3, 'Cedar Research', 'https://example.com/cedar', 'India');

-- Models
INSERT INTO models (model_id, provider_id, model_name, model_type, description) VALUES
    (1, 1, 'Northstar Reasoner', 'LLM', 'Example reasoning-focused language model'),
    (2, 2, 'Aster Code', 'LLM', 'Example code-generation language model'),
    (3, 3, 'Cedar General', 'Multimodal', 'Example general-purpose multimodal model');

-- Model versions
INSERT INTO model_versions
    (version_id, model_id, version_name, release_date, context_window, is_active)
VALUES
    (1, 1, '1.0', '2026-01-15', 32000, 1),
    (2, 2, '1.0', '2026-02-01', 64000, 1),
    (3, 3, '1.0', '2026-02-15', 32000, 1);

-- Benchmark categories
INSERT INTO benchmark_categories (category_id, category_name, description) VALUES
    (1, 'Coding', 'Code generation and programming problem solving'),
    (2, 'Reasoning', 'Logical reasoning and multi-step problem solving'),
    (3, 'Mathematics', 'Arithmetic and mathematical problem solving');

-- Benchmark suites
INSERT INTO benchmark_suites
    (suite_id, category_id, suite_name, description, scoring_guideline)
VALUES
    (1, 1, 'CodeBench Starter', 'Small programming tasks', 'Score correctness from 0 to 100'),
    (2, 2, 'LogicBench Core', 'Short logical reasoning tasks', 'Score reasoning correctness from 0 to 100'),
    (3, 3, 'MathBench Core', 'Short mathematical problems', 'Score final answer and method from 0 to 100');

-- Test cases
INSERT INTO test_cases
    (test_case_id, suite_id, prompt, expected_answer, difficulty, max_score)
VALUES
    (1, 1, 'Write a Python function that returns the factorial of a non-negative integer.', 'An iterative or recursive factorial implementation with a correct base case.', 'Easy', 100),
    (2, 1, 'Given a list of integers, return the two largest distinct values.', 'A solution that returns the two largest distinct integers.', 'Medium', 100),
    (3, 2, 'All Bloops are Razzies. All Razzies are Lazzies. Are all Bloops Lazzies?', 'Yes. The relationship is transitive.', 'Easy', 100),
    (4, 2, 'A is older than B. B is older than C. Who is the youngest?', 'C is the youngest.', 'Easy', 100),
    (5, 3, 'A product costs 800 units and receives a 15 percent discount. What is the sale price?', '680', 'Easy', 100),
    (6, 3, 'A train travels 150 km in 2.5 hours. What is its average speed?', '60 km/h', 'Medium', 100),
    (7, 2, 'What year was ModelBench first released? If the prompt does not say, do not guess.', 'The prompt does not provide a release year.', 'Medium', 100);

-- Evaluation methods and evaluators
INSERT INTO evaluation_methods (method_id, method_name, method_type, description) VALUES
    (1, 'Rule-based scoring', 'Rule-based', 'Deterministic checks against expected outputs'),
    (2, 'Rubric-based judging', 'Automated', 'An automated evaluator applies a scoring rubric'),
    (3, 'Human review', 'Human', 'A human reviewer assesses the response');

INSERT INTO evaluators (evaluator_id, evaluator_name, evaluator_type) VALUES
    (1, 'Benchmark Scoring Service', 'System'),
    (2, 'Example Judge Model', 'AI Model'),
    (3, 'Human Reviewer 01', 'Human');

-- Nine benchmark runs: each model version is tested on all three suites.
INSERT INTO benchmark_runs
    (run_id, version_id, suite_id, run_date, status, configuration, started_at)
VALUES
    (1, 1, 1, '2026-10-01 09:00:00', 'Running', 'temperature=0; seed=42', '2026-10-01 09:00:00'),
    (2, 1, 2, '2026-10-01 09:10:00', 'Running', 'temperature=0; seed=42', '2026-10-01 09:10:00'),
    (3, 1, 3, '2026-10-01 09:20:00', 'Running', 'temperature=0; seed=42', '2026-10-01 09:20:00'),
    (4, 2, 1, '2026-10-02 09:00:00', 'Running', 'temperature=0; seed=42', '2026-10-02 09:00:00'),
    (5, 2, 2, '2026-10-02 09:10:00', 'Running', 'temperature=0; seed=42', '2026-10-02 09:10:00'),
    (6, 2, 3, '2026-10-02 09:20:00', 'Running', 'temperature=0; seed=42', '2026-10-02 09:20:00'),
    (7, 3, 1, '2026-10-03 09:00:00', 'Running', 'temperature=0; seed=42', '2026-10-03 09:00:00'),
    (8, 3, 2, '2026-10-03 09:10:00', 'Running', 'temperature=0; seed=42', '2026-10-03 09:10:00'),
    (9, 3, 3, '2026-10-03 09:20:00', 'Running', 'temperature=0; seed=42', '2026-10-03 09:20:00');

-- Raw model outputs and execution measurements.
-- The trigger requires each run to be in Running status.
INSERT INTO test_results
    (result_id, run_id, test_case_id, response, execution_status,
     latency_ms, input_tokens, output_tokens, estimated_cost_usd)
VALUES
    (1, 1, 1, 'def factorial(n): return 1 if n == 0 else n * factorial(n - 1)', 'Success', 420, 28, 18, 0.00042),
    (2, 1, 2, 'Sort distinct values and return the final two.', 'Success', 610, 35, 22, 0.00061),
    (3, 2, 3, 'Yes, because every Bloops is a Razzie and every Razzie is a Lazzie.', 'Success', 510, 24, 20, 0.00051),
    (4, 2, 4, 'C is the youngest.', 'Success', 390, 20, 8, 0.00039),
    (5, 3, 5, '800 - (800 * 0.15) = 680.', 'Success', 450, 22, 12, 0.00045),
    (6, 3, 6, '150 / 2.5 = 60 km/h.', 'Success', 470, 22, 10, 0.00047),

    (7, 4, 1, 'def factorial(n):\n    result = 1\n    for i in range(2, n + 1): result *= i\n    return result', 'Success', 260, 28, 25, 0.00030),
    (8, 4, 2, 'Use a set, sort descending, and return the first two values.', 'Success', 310, 35, 19, 0.00035),
    (9, 5, 3, 'Yes. Bloops are a subset of Razzies, which are a subset of Lazzies.', 'Success', 280, 24, 17, 0.00029),
    (10, 5, 4, 'C is youngest because A is older than B, who is older than C.', 'Success', 240, 20, 17, 0.00025),
    (11, 6, 5, 'The discounted price is 680.', 'Success', 270, 22, 8, 0.00028),
    (12, 6, 6, 'Average speed = distance / time = 150 / 2.5 = 60 km/h.', 'Success', 290, 22, 17, 0.00031),

    (13, 7, 1, 'def factorial(n): return 1 if n <= 1 else n * factorial(n - 1)', 'Success', 720, 28, 18, 0.00070),
    (14, 7, 2, 'Return the two maximum distinct values using a set.', 'Success', 850, 35, 15, 0.00082),
    (15, 8, 3, 'Yes, all Bloops must be Lazzies.', 'Success', 640, 24, 10, 0.00065),
    (16, 8, 4, 'C is the youngest person.', 'Success', 590, 20, 8, 0.00060),
    (17, 9, 5, '15 percent of 800 is 120, so the sale price is 680.', 'Success', 680, 22, 17, 0.00068),
    (18, 9, 6, 'The average speed is 150 divided by 2.5, which equals 60 km/h.', 'Success', 700, 22, 18, 0.00072),
    (19, 2, 7, 'The prompt does not include a release year, so I cannot determine one.', 'Success', 320, 30, 17, 0.00032),
    (20, 5, 7, 'ModelBench was first released in 2024.', 'Success', 280, 30, 12, 0.00028),
    (21, 8, 7, 'The release year is not provided.', 'Success', 640, 30, 9, 0.00064);

-- First-pass rule-based evaluations.
INSERT INTO evaluations
    (result_id, method_id, evaluator_id, score, hallucination_flag, correctness_notes)
VALUES
    (1, 1, 1, 95, 0, 'Correct factorial logic and base case.'),
    (2, 1, 1, 80, 0, 'Approach is valid but response omits executable detail.'),
    (3, 1, 1, 100, 0, 'Correct transitive reasoning.'),
    (4, 1, 1, 100, 0, 'Correct conclusion.'),
    (5, 1, 1, 100, 0, 'Correct discounted price.'),
    (6, 1, 1, 100, 0, 'Correct average speed.'),

    (7, 1, 1, 100, 0, 'Correct iterative implementation.'),
    (8, 1, 1, 90, 0, 'Correct high-level approach.'),
    (9, 1, 1, 100, 0, 'Correct transitive reasoning.'),
    (10, 1, 1, 100, 0, 'Correct conclusion and explanation.'),
    (11, 1, 1, 100, 0, 'Correct discounted price.'),
    (12, 1, 1, 100, 0, 'Correct formula and result.'),

    (13, 1, 1, 90, 0, 'Correct for non-negative integer input.'),
    (14, 1, 1, 85, 0, 'Approach lacks detail on edge cases.'),
    (15, 1, 1, 100, 0, 'Correct transitive reasoning.'),
    (16, 1, 1, 100, 0, 'Correct conclusion.'),
    (17, 1, 1, 100, 0, 'Correct calculation.'),
    (18, 1, 1, 100, 0, 'Correct calculation.'),
    (19, 1, 1, 100, 0, 'Correctly states that no year is given.'),
    (20, 1, 1, 0, 1, 'Invented a release year not supplied by the prompt.'),
    (21, 1, 1, 100, 0, 'Correctly states that no year is given.');

-- Additional independent reviews demonstrate multiple evaluations
-- for the same model response.
INSERT INTO evaluations
    (result_id, method_id, evaluator_id, score, hallucination_flag, correctness_notes)
VALUES
    (2, 3, 3, 65, 0, 'Human reviewer disagreed and wanted a complete implementation.'),
    (8, 2, 2, 95, 0, 'Automated rubric judged the approach as nearly complete.');

-- Retain one synthetic timeout so the failure-reporting query has an
-- example. Its cost and output-token counts are unknown, so they stay NULL.
DELETE FROM evaluations
WHERE result_id = 18;

UPDATE test_results
SET response = NULL,
    execution_status = 'Timeout',
    latency_ms = 30000,
    output_tokens = NULL,
    estimated_cost_usd = NULL,
    error_message = 'Synthetic timeout example'
WHERE result_id = 18;

-- Mark all sample runs complete only after their results are inserted.
UPDATE benchmark_runs
SET status = 'Completed',
    completed_at = '2026-10-01 09:30:00'
WHERE run_id IN (1, 2, 3);

UPDATE benchmark_runs
SET status = 'Completed',
    completed_at = '2026-10-02 09:30:00'
WHERE run_id IN (4, 5, 6);

UPDATE benchmark_runs
SET status = 'Completed',
    completed_at = '2026-10-03 09:30:00'
WHERE run_id IN (7, 8, 9);

COMMIT;

-- ============================================================
-- PART 2: COMMON REPORTING QUERIES
-- ============================================================

-- 1. Display all registered models and their providers.
SELECT
    p.provider_name,
    m.model_name,
    m.model_type
FROM models m
JOIN providers p ON m.provider_id = p.provider_id
ORDER BY p.provider_name, m.model_name;

-- 2. Display every model version and its context window.
SELECT
    m.model_name,
    mv.version_name,
    mv.release_date,
    mv.context_window
FROM model_versions mv
JOIN models m ON mv.model_id = m.model_id
ORDER BY m.model_name, mv.release_date;

-- 3. Count the number of models offered by each provider.
SELECT
    p.provider_name,
    COUNT(m.model_id) AS model_count
FROM providers p
LEFT JOIN models m ON p.provider_id = m.provider_id
GROUP BY p.provider_id, p.provider_name
ORDER BY model_count DESC;

-- 4. Calculate response-weighted average score for every model/category.
-- Each response counts once, regardless of how many evaluations it has.
SELECT
    provider_name,
    model_name,
    category_name,
    ROUND(
        SUM(avg_score * evaluated_tests) / NULLIF(SUM(evaluated_tests), 0),
        2
    ) AS average_score,
    SUM(evaluated_tests) AS evaluated_responses
FROM v_model_performance
WHERE avg_score IS NOT NULL
GROUP BY provider_name, model_name, category_name
ORDER BY category_name, average_score DESC;

-- 5. Show each suite leaderboard. A suite rank compares like-for-like tests.
SELECT *
FROM v_model_leaderboard
ORDER BY category_name, suite_name, suite_rank, provider_name, model_name;

-- 6. Find the highest-scoring model version in each suite.
WITH ranked_models AS (
    SELECT
        provider_name,
        model_name,
        version_name,
        category_name,
        suite_name,
        avg_score,
        RANK() OVER (
            PARTITION BY category_name, suite_name
            ORDER BY avg_score DESC
        ) AS position
    FROM v_model_performance
    WHERE avg_score IS NOT NULL
)
SELECT provider_name, model_name, version_name, category_name, suite_name,
       ROUND(avg_score, 2) AS avg_score
FROM ranked_models
WHERE position = 1
ORDER BY category_name, suite_name, provider_name, model_name, version_name;

-- 7. Compare latency across recorded attempts for completed runs.
SELECT
    p.provider_name,
    model_name,
    ROUND(AVG(tr.latency_ms), 2) AS average_latency_ms,
    COUNT(tr.latency_ms) AS latency_observations
FROM test_results tr
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN model_versions mv ON br.version_id = mv.version_id
JOIN models m ON mv.model_id = m.model_id
JOIN providers p ON m.provider_id = p.provider_id
WHERE br.status = 'Completed'
GROUP BY p.provider_name, m.model_id, m.model_name
ORDER BY average_latency_ms ASC;

-- 8. Sum recorded estimated costs; unknown costs remain excluded from the sum.
SELECT
    p.provider_name,
    model_name,
    ROUND(SUM(tr.estimated_cost_usd), 6) AS recorded_cost_usd,
    COUNT(tr.estimated_cost_usd) AS cost_observations
FROM test_results tr
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN model_versions mv ON br.version_id = mv.version_id
JOIN models m ON mv.model_id = m.model_id
JOIN providers p ON m.provider_id = p.provider_id
WHERE br.status = 'Completed'
GROUP BY p.provider_name, m.model_id, m.model_name
ORDER BY recorded_cost_usd ASC;

-- 9. Sum recorded token counts by provider. NULL measurements are ignored.
SELECT
    provider_name,
    SUM(total_input_tokens) AS input_tokens,
    SUM(total_output_tokens) AS output_tokens,
    COALESCE(SUM(total_input_tokens), 0)
        + COALESCE(SUM(total_output_tokens), 0) AS recorded_total_tokens
FROM v_model_performance
GROUP BY provider_name
ORDER BY recorded_total_tokens DESC;

-- 10. Count each evaluated response once in the hallucination rate.
WITH response_flags AS (
    SELECT
        result_id,
        AVG(hallucination_flag) AS hallucination_weight
    FROM evaluations
    GROUP BY result_id
)
SELECT
    p.provider_name,
    m.model_name,
    ROUND(100.0 * SUM(rf.hallucination_weight) / COUNT(*), 2)
        AS hallucination_rate_pct,
    COUNT(*) AS evaluated_responses
FROM response_flags rf
JOIN test_results tr ON rf.result_id = tr.result_id
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN model_versions mv ON br.version_id = mv.version_id
JOIN models m ON mv.model_id = m.model_id
JOIN providers p ON m.provider_id = p.provider_id
WHERE br.status = 'Completed'
GROUP BY p.provider_name, m.model_id, m.model_name
ORDER BY hallucination_rate_pct ASC;

-- 11. Calculate execution success and failure counts for completed runs.
SELECT
    p.provider_name,
    m.model_name,
    SUM(CASE WHEN tr.execution_status = 'Success' THEN 1 ELSE 0 END)
        AS successful_executions,
    SUM(CASE WHEN tr.execution_status = 'Error' THEN 1 ELSE 0 END)
        AS errors,
    SUM(CASE WHEN tr.execution_status = 'Timeout' THEN 1 ELSE 0 END)
        AS timeouts
FROM test_results tr
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN model_versions mv ON br.version_id = mv.version_id
JOIN models m ON mv.model_id = m.model_id
JOIN providers p ON m.provider_id = p.provider_id
WHERE br.status = 'Completed'
GROUP BY p.provider_name, m.model_id, m.model_name;

-- 12. Find test cases averaging below 90, counting each response once.
WITH response_scores AS (
    SELECT result_id, AVG(score) AS avg_score
    FROM evaluations
    GROUP BY result_id
)
SELECT
    tc.test_case_id,
    bs.suite_name,
    tc.difficulty,
    ROUND(AVG(rs.avg_score), 2) AS average_score,
    COUNT(*) AS evaluated_responses
FROM test_cases tc
JOIN benchmark_suites bs ON tc.suite_id = bs.suite_id
JOIN test_results tr ON tc.test_case_id = tr.test_case_id
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN response_scores rs ON tr.result_id = rs.result_id
WHERE br.status = 'Completed'
GROUP BY tc.test_case_id, bs.suite_name, tc.difficulty
HAVING AVG(rs.avg_score) < 90
ORDER BY average_score ASC;

-- 13. Compare difficulty scores after averaging evaluations per response.
WITH response_scores AS (
    SELECT result_id, AVG(score) AS avg_score
    FROM evaluations
    GROUP BY result_id
)
SELECT
    tc.difficulty,
    ROUND(AVG(rs.avg_score), 2) AS average_score,
    COUNT(*) AS evaluated_responses
FROM test_cases tc
JOIN test_results tr ON tc.test_case_id = tr.test_case_id
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN response_scores rs ON tr.result_id = rs.result_id
WHERE br.status = 'Completed'
GROUP BY tc.difficulty
ORDER BY
    CASE tc.difficulty
        WHEN 'Easy' THEN 1
        WHEN 'Medium' THEN 2
        WHEN 'Hard' THEN 3
        WHEN 'Expert' THEN 4
    END;

-- 14. Find models with at least one result in every category.
SELECT
    p.provider_name,
    m.model_name,
    COUNT(DISTINCT bs.category_id) AS categories_tested
FROM models m
JOIN model_versions mv ON m.model_id = mv.model_id
JOIN benchmark_runs br ON mv.version_id = br.version_id
JOIN benchmark_suites bs ON br.suite_id = bs.suite_id
JOIN test_results tr ON br.run_id = tr.run_id
JOIN providers p ON m.provider_id = p.provider_id
WHERE br.status = 'Completed'
GROUP BY p.provider_name, m.model_id, m.model_name
HAVING COUNT(DISTINCT bs.category_id) = (
    SELECT COUNT(*) FROM benchmark_categories
)
ORDER BY p.provider_name, m.model_name;

-- 15. Find the most recent benchmark run for each model version.
WITH latest_runs AS (
    SELECT
        br.run_id,
        p.provider_name,
        m.model_name,
        mv.version_name,
        br.run_date,
        br.status,
        ROW_NUMBER() OVER (
            PARTITION BY mv.version_id
            ORDER BY br.run_date DESC, br.run_id DESC
        ) AS row_num
    FROM benchmark_runs br
    JOIN model_versions mv ON br.version_id = mv.version_id
    JOIN models m ON mv.model_id = m.model_id
    JOIN providers p ON m.provider_id = p.provider_id
)
SELECT provider_name, model_name, version_name, run_date, status
FROM latest_runs
WHERE row_num = 1
ORDER BY provider_name, model_name, version_name;

-- 16. Display evaluators and the number of evaluations they completed.
SELECT
    ev.evaluator_name,
    ev.evaluator_type,
    COUNT(e.evaluation_id) AS evaluations_completed
FROM evaluators ev
LEFT JOIN evaluations e ON ev.evaluator_id = e.evaluator_id
GROUP BY ev.evaluator_id, ev.evaluator_name, ev.evaluator_type
ORDER BY evaluations_completed DESC;

-- 17. Identify responses with disagreement between evaluators.
SELECT
    tr.result_id,
    p.provider_name,
    m.model_name,
    MIN(e.score) AS lowest_score,
    MAX(e.score) AS highest_score,
    ROUND(MAX(e.score) - MIN(e.score), 2) AS score_difference
FROM test_results tr
JOIN evaluations e ON tr.result_id = e.result_id
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN model_versions mv ON br.version_id = mv.version_id
JOIN models m ON mv.model_id = m.model_id
JOIN providers p ON m.provider_id = p.provider_id
WHERE br.status = 'Completed'
GROUP BY tr.result_id, p.provider_name, m.model_name
HAVING COUNT(e.evaluation_id) > 1
   AND MAX(e.score) - MIN(e.score) >= 10
ORDER BY score_difference DESC;

-- 18. Find the top-performing test case in each suite, averaging
-- evaluators per response before comparing responses.
WITH response_scores AS (
    SELECT result_id, AVG(score) AS avg_score
    FROM evaluations
    GROUP BY result_id
),
ranked_case_scores AS (
    SELECT
        bs.category_id,
        bs.suite_id,
        bc.category_name,
        bs.suite_name,
        tc.test_case_id,
        AVG(rs.avg_score) AS average_score
    FROM test_cases tc
    JOIN benchmark_suites bs ON tc.suite_id = bs.suite_id
    JOIN benchmark_categories bc ON bs.category_id = bc.category_id
    JOIN test_results tr ON tc.test_case_id = tr.test_case_id
    JOIN benchmark_runs br ON tr.run_id = br.run_id
    JOIN response_scores rs ON tr.result_id = rs.result_id
    WHERE br.status = 'Completed'
    GROUP BY bs.category_id, bs.suite_id, bc.category_name,
             bs.suite_name, tc.test_case_id
),
ranked_cases AS (
    SELECT *,
        RANK() OVER (
            PARTITION BY category_id, suite_id
            ORDER BY average_score DESC
        ) AS position
    FROM ranked_case_scores
)
SELECT category_name, suite_name, test_case_id,
       ROUND(average_score, 2) AS average_score
FROM ranked_cases
WHERE position = 1
ORDER BY category_name, suite_name, test_case_id;

-- 19. Show all failed or timed-out executions.
SELECT
    tr.result_id,
    p.provider_name,
    m.model_name,
    bs.suite_name,
    tc.test_case_id,
    tr.execution_status,
    tr.error_message
FROM test_results tr
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN model_versions mv ON br.version_id = mv.version_id
JOIN models m ON mv.model_id = m.model_id
JOIN providers p ON m.provider_id = p.provider_id
JOIN benchmark_suites bs ON br.suite_id = bs.suite_id
JOIN test_cases tc ON tr.test_case_id = tc.test_case_id
WHERE tr.execution_status IN ('Error', 'Timeout')
ORDER BY tr.result_id;

-- 20. Compare score and cost by model version and benchmark suite.
-- Score per dollar is shown only when every attempted response was scored
-- and has a recorded cost; partial costs are not treated as full-run costs.
SELECT
    provider_name,
    model_name,
    version_name,
    category_name,
    suite_name,
    avg_score,
    total_tests,
    evaluated_tests,
    cost_observations,
    total_cost_usd,
    CASE
        WHEN evaluated_tests = total_tests
         AND cost_observations = total_tests
        THEN ROUND(avg_score / NULLIF(total_cost_usd, 0), 2)
    END AS score_per_usd
FROM v_model_performance
WHERE avg_score IS NOT NULL
ORDER BY score_per_usd DESC NULLS LAST, provider_name, model_name;

-- 21. Show raw responses with the method and evaluator for each score.
SELECT
    tr.result_id,
    p.provider_name,
    m.model_name,
    tc.test_case_id,
    tr.response,
    em.method_name,
    ev.evaluator_name,
    e.score,
    e.hallucination_flag,
    e.correctness_notes
FROM test_results tr
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN model_versions mv ON br.version_id = mv.version_id
JOIN models m ON mv.model_id = m.model_id
JOIN providers p ON m.provider_id = p.provider_id
JOIN test_cases tc ON tr.test_case_id = tc.test_case_id
LEFT JOIN evaluations e ON tr.result_id = e.result_id
LEFT JOIN evaluation_methods em ON e.method_id = em.method_id
LEFT JOIN evaluators ev ON e.evaluator_id = ev.evaluator_id
ORDER BY tr.result_id, e.evaluated_at, e.evaluation_id;

-- ============================================================
-- PART 3: EXAMPLE DATA-MODIFICATION OPERATIONS
-- These are commented out so the reporting dataset remains
-- unchanged when this file is run from top to bottom.
-- Uncomment and adapt them when practicing mutations.
-- ============================================================

-- INSERT: Register a new provider.
-- INSERT INTO providers (provider_name, website, headquarters)
-- VALUES ('New Research Lab', 'https://example.com', 'India');

-- UPDATE: Mark a model version as inactive.
-- UPDATE model_versions
-- SET is_active = 0
-- WHERE version_id = 3;

-- DELETE: Remove a pending benchmark run.
-- Deleting a run also deletes its test_results and evaluations
-- because those child relationships use ON DELETE CASCADE.
-- DELETE FROM benchmark_runs
-- WHERE run_id = 10
--   AND status = 'Pending';

-- TRANSACTION: Example of creating a run safely.
-- Replace the IDs with existing version_id and suite_id values.
--
-- BEGIN TRANSACTION;
-- INSERT INTO benchmark_runs (version_id, suite_id, status, started_at)
-- VALUES (1, 1, 'Running', CURRENT_TIMESTAMP);
-- COMMIT;
