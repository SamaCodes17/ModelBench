-- ============================================================
-- ModelBench: sample data and commonly used SQL queries
-- Load order: schema.sql, then this file (once, on a fresh database).
--
-- PART 1 inserts the sample data in one transaction (INSERT, then
-- UPDATE to mark runs completed). PART 2 holds the reporting queries.
-- PART 3 shows common data-modification statements.
--
-- IMPORTANT: every score and measurement is synthetic. None of it
-- describes real commercial model performance.
-- ============================================================

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

-- Benchmark suites (each has its own rubric scale, see test_cases.max_score)
INSERT INTO benchmark_suites
    (suite_id, category_id, suite_name, description, scoring_guideline)
VALUES
    (1, 1, 'CodeBench Starter', 'Small programming tasks', 'Score 0-10 for correctness and completeness'),
    (2, 2, 'LogicBench Core', 'Short logical reasoning tasks', 'Score 0-5 for reasoning correctness'),
    (3, 3, 'MathBench Core', 'Short mathematical problems', 'Score 0-20 for final answer and method');

-- Test cases: 4 per suite; max_score differs by suite to show normalization
INSERT INTO test_cases
    (test_case_id, suite_id, prompt, expected_answer, difficulty, max_score)
VALUES
    (1, 1, 'Write a Python function that returns the factorial of a non-negative integer.', 'An iterative or recursive factorial implementation with a correct base case.', 'Easy', 10),
    (2, 1, 'Given a list of integers, return the two largest distinct values.', 'A solution that returns the two largest distinct integers.', 'Medium', 10),
    (3, 1, 'Write a function that checks whether a string is a palindrome, ignoring case and punctuation.', 'A function that normalizes the string and compares it with its reverse.', 'Medium', 10),
    (4, 1, 'Design an LRU cache with O(1) get and put operations.', 'A hash map combined with a doubly linked list (or an ordered dictionary).', 'Hard', 10),
    (5, 2, 'All Bloops are Razzies. All Razzies are Lazzies. Are all Bloops Lazzies?', 'Yes. The relationship is transitive.', 'Easy', 5),
    (6, 2, 'A is older than B. B is older than C. Who is the youngest?', 'C is the youngest.', 'Easy', 5),
    (7, 2, 'What year was ModelBench first released? If the prompt does not say, do not guess.', 'The prompt does not provide a release year.', 'Medium', 5),
    (8, 2, 'Alice is taller than Bob. Carol is shorter than Bob. Dave is taller than Alice. Order them from tallest to shortest.', 'Dave, Alice, Bob, Carol.', 'Hard', 5),
    (9, 3, 'A product costs 800 units and receives a 15 percent discount. What is the sale price?', '680', 'Easy', 20),
    (10, 3, 'A train travels 150 km in 2.5 hours. What is its average speed?', '60 km/h', 'Medium', 20),
    (11, 3, 'What is 1000 invested for 2 years at 10 percent annual compound interest worth?', '1210', 'Medium', 20),
    (12, 3, 'Two fair dice are rolled. What is the probability that the sum is 8?', '5/36', 'Hard', 20);

-- Evaluation methods and evaluators
INSERT INTO evaluation_methods (method_id, method_name, method_type, description) VALUES
    (1, 'Rule-based scoring', 'Rule-based', 'Deterministic checks against expected outputs'),
    (2, 'Rubric-based judging', 'Automated', 'An automated evaluator applies a scoring rubric'),
    (3, 'Human review', 'Human', 'A human reviewer assesses the response');

INSERT INTO evaluators (evaluator_id, evaluator_name, evaluator_type) VALUES
    (1, 'Benchmark Scoring Service', 'System'),
    (2, 'Example Judge Model', 'AI Model'),
    (3, 'Human Reviewer 01', 'Human');

-- Ten benchmark runs: each model version is tested on all three suites,
-- plus one partial repeat (attempt 2) of Aster Code on CodeBench Starter.
-- Runs start as 'Running' so that results can be inserted.
INSERT INTO benchmark_runs
    (run_id, version_id, suite_id, attempt_number, run_date, status, configuration, started_at)
VALUES
    (1, 1, 1, 1, '2026-10-01 09:00:00', 'Running', 'temperature=0; seed=42', '2026-10-01 09:00:00'),
    (2, 1, 2, 1, '2026-10-01 09:10:00', 'Running', 'temperature=0; seed=42', '2026-10-01 09:10:00'),
    (3, 1, 3, 1, '2026-10-01 09:20:00', 'Running', 'temperature=0; seed=42', '2026-10-01 09:20:00'),
    (4, 2, 1, 1, '2026-10-02 09:00:00', 'Running', 'temperature=0; seed=42', '2026-10-02 09:00:00'),
    (5, 2, 2, 1, '2026-10-02 09:10:00', 'Running', 'temperature=0; seed=42', '2026-10-02 09:10:00'),
    (6, 2, 3, 1, '2026-10-02 09:20:00', 'Running', 'temperature=0; seed=42', '2026-10-02 09:20:00'),
    (7, 3, 1, 1, '2026-10-03 09:00:00', 'Running', 'temperature=0; seed=42', '2026-10-03 09:00:00'),
    (8, 3, 2, 1, '2026-10-03 09:10:00', 'Running', 'temperature=0; seed=42', '2026-10-03 09:10:00'),
    (9, 3, 3, 1, '2026-10-03 09:20:00', 'Running', 'temperature=0; seed=42', '2026-10-03 09:20:00'),
    (10, 2, 1, 2, '2026-10-04 09:00:00', 'Running', 'temperature=0; seed=42', '2026-10-04 09:00:00');

-- Raw model outputs and execution measurements.
-- Result 28 is an Error and result 36 is a Timeout; both keep unknown
-- measurements as NULL and have no evaluations.
INSERT INTO test_results
    (result_id, run_id, test_case_id, response, execution_status,
     latency_ms, input_tokens, output_tokens, estimated_cost_usd,
     error_message, executed_at)
VALUES
    (1, 1, 1, 'def factorial(n): return 1 if n == 0 else n * factorial(n - 1)', 'Success', 420, 28, 18, 0.00042, NULL, '2026-10-01 09:01:00'),
    (2, 1, 2, 'Sort the distinct values and return the final two.', 'Success', 610, 35, 22, 0.00061, NULL, '2026-10-01 09:01:00'),
    (3, 1, 3, 'def is_pal(s): t = ''''.join(c.lower() for c in s if c.isalnum()); return t == t[::-1]', 'Success', 700, 40, 34, 0.00071, NULL, '2026-10-01 09:01:00'),
    (4, 1, 4, 'Use a dict plus a doubly linked list to track recency; move nodes to the head on access.', 'Success', 1180, 48, 40, 0.00118, NULL, '2026-10-01 09:01:00'),
    (5, 2, 5, 'Yes, because every Bloop is a Razzie and every Razzie is a Lazzie.', 'Success', 510, 24, 20, 0.00051, NULL, '2026-10-01 09:11:00'),
    (6, 2, 6, 'C is the youngest.', 'Success', 390, 20, 8, 0.00039, NULL, '2026-10-01 09:11:00'),
    (7, 2, 7, 'The prompt does not include a release year, so I cannot determine one.', 'Success', 320, 30, 17, 0.00032, NULL, '2026-10-01 09:11:00'),
    (8, 2, 8, 'Dave > Alice > Bob > Carol, so Dave is tallest and Carol is shortest.', 'Success', 820, 52, 26, 0.00083, NULL, '2026-10-01 09:11:00'),
    (9, 3, 9, '800 - (800 * 0.15) = 680.', 'Success', 450, 22, 12, 0.00045, NULL, '2026-10-01 09:21:00'),
    (10, 3, 10, '150 / 2.5 = 60 km/h.', 'Success', 470, 22, 10, 0.00047, NULL, '2026-10-01 09:21:00'),
    (11, 3, 11, '1000 * 1.1^2 = 1210.', 'Success', 520, 26, 12, 0.00052, NULL, '2026-10-01 09:21:00'),
    (12, 3, 12, 'There are 5 ways to roll a sum of 8 out of 36 outcomes, so the probability is 5/36.', 'Success', 760, 30, 24, 0.00076, NULL, '2026-10-01 09:21:00'),
    (13, 4, 1, 'def factorial(n): result = 1; [result := result * i for i in range(2, n + 1)]; return result', 'Success', 260, 28, 25, 0.0003, NULL, '2026-10-02 09:01:00'),
    (14, 4, 2, 'Use a set, sort descending, and return the first two values.', 'Success', 310, 35, 19, 0.00035, NULL, '2026-10-02 09:01:00'),
    (15, 4, 3, 'def is_pal(s): t = [c.lower() for c in s if c.isalnum()]; return t == t[::-1]', 'Success', 290, 40, 31, 0.00033, NULL, '2026-10-02 09:01:00'),
    (16, 4, 4, 'Use an OrderedDict: get() calls move_to_end; put() pops the oldest key when over capacity.', 'Success', 540, 48, 38, 0.00056, NULL, '2026-10-02 09:01:00'),
    (17, 5, 5, 'Yes. Bloops are a subset of Razzies, which are a subset of Lazzies.', 'Success', 280, 24, 17, 0.00029, NULL, '2026-10-02 09:11:00'),
    (18, 5, 6, 'C is youngest because A is older than B, who is older than C.', 'Success', 240, 20, 17, 0.00025, NULL, '2026-10-02 09:11:00'),
    (19, 5, 7, 'ModelBench was first released in 2024.', 'Success', 280, 30, 12, 0.00028, NULL, '2026-10-02 09:11:00'),
    (20, 5, 8, 'Dave, Alice, Bob, Carol.', 'Success', 300, 52, 10, 0.0003, NULL, '2026-10-02 09:11:00'),
    (21, 6, 9, 'The discounted price is 680.', 'Success', 270, 22, 8, 0.00028, NULL, '2026-10-02 09:21:00'),
    (22, 6, 10, 'Average speed = distance / time = 150 / 2.5 = 60 km/h.', 'Success', 290, 22, 17, 0.00031, NULL, '2026-10-02 09:21:00'),
    (23, 6, 11, 'After two years the amount is 1210.', 'Success', 300, 26, 10, 0.0003, NULL, '2026-10-02 09:21:00'),
    (24, 6, 12, 'The probability is 6/36 = 1/6.', 'Success', 330, 30, 14, 0.00033, NULL, '2026-10-02 09:21:00'),
    (25, 7, 1, 'def factorial(n): return 1 if n <= 1 else n * factorial(n - 1)', 'Success', 720, 28, 18, 0.0007, NULL, '2026-10-03 09:01:00'),
    (26, 7, 2, 'Return the two maximum distinct values using a set.', 'Success', 850, 35, 15, 0.00082, NULL, '2026-10-03 09:01:00'),
    (27, 7, 3, 'Strip punctuation, lowercase the string, and compare it with its reverse.', 'Success', 780, 40, 17, 0.00078, NULL, '2026-10-03 09:01:00'),
    (28, 7, 4, NULL, 'Error', 120, 48, NULL, NULL, 'Rate limit exceeded (HTTP 429)', '2026-10-03 09:01:00'),
    (29, 8, 5, 'Yes, all Bloops must be Lazzies.', 'Success', 640, 24, 10, 0.00065, NULL, '2026-10-03 09:11:00'),
    (30, 8, 6, 'C is the youngest person.', 'Success', 590, 20, 8, 0.0006, NULL, '2026-10-03 09:11:00'),
    (31, 8, 7, 'The release year is not provided.', 'Success', 640, 30, 9, 0.00064, NULL, '2026-10-03 09:11:00'),
    (32, 8, 8, 'Alice is taller than Bob and Dave is taller than Alice, so Dave is tallest.', 'Success', 900, 52, 24, 0.0009, NULL, '2026-10-03 09:11:00'),
    (33, 9, 9, '15 percent of 800 is 120, so the sale price is 680.', 'Success', 680, 22, 17, 0.00068, NULL, '2026-10-03 09:21:00'),
    (34, 9, 10, 'The average speed is 150 divided by 2.5, which equals 60 km/h.', 'Success', 700, 22, 18, 0.00072, NULL, '2026-10-03 09:21:00'),
    (35, 9, 11, 'Interest is 10 percent per year, giving about 1200.', 'Success', 710, 26, 13, 0.00071, NULL, '2026-10-03 09:21:00'),
    (36, 9, 12, NULL, 'Timeout', 30000, 30, NULL, NULL, 'Synthetic timeout example', '2026-10-03 09:21:00'),
    (37, 10, 1, 'def factorial(n): return 1 if n < 2 else n * factorial(n - 1)', 'Success', 250, 28, 18, 0.00028, NULL, '2026-10-04 09:01:00'),
    (38, 10, 2, 'Collect distinct values in a set, sort descending, and return the first two.', 'Success', 320, 35, 22, 0.00036, NULL, '2026-10-04 09:01:00'),
    (39, 10, 4, 'Use an OrderedDict: move accessed keys to the end and pop the oldest key when capacity is exceeded.', 'Success', 560, 48, 30, 0.00058, NULL, '2026-10-04 09:01:00');

-- Evaluations. raw_score is on each test case's own scale (see
-- test_cases.max_score); v_evaluation_scores converts it to 0-100.
-- hallucination_flag is NULL where the evaluator did not check for
-- hallucination (rule-based coding checks), 0 or 1 where it did.
-- Extra reviews of the same response (human / automated) show how
-- evaluators can disagree.
INSERT INTO evaluations
    (result_id, method_id, evaluator_id, raw_score, hallucination_flag,
     correctness_notes, evaluated_at)
VALUES
    (1, 1, 1, 9.5, NULL, 'Correct factorial logic and base case.', '2026-10-01 10:00:00'),
    (2, 1, 1, 8, NULL, 'Valid approach but the response omits executable code.', '2026-10-01 10:00:00'),
    (2, 3, 3, 6.5, 0, 'Human reviewer wanted a complete implementation.', '2026-10-01 10:30:00'),
    (3, 1, 1, 10, NULL, 'Correct, handles case and punctuation.', '2026-10-01 10:00:00'),
    (4, 1, 1, 6.5, NULL, 'Right data structures but no code given.', '2026-10-01 10:00:00'),
    (5, 1, 1, 5, 0, 'Correct transitive reasoning.', '2026-10-01 10:00:00'),
    (6, 1, 1, 5, 0, 'Correct conclusion.', '2026-10-01 10:00:00'),
    (7, 1, 1, 5, 0, 'Correctly states that no year is given.', '2026-10-01 10:00:00'),
    (8, 1, 1, 5, 0, 'Correct full ordering.', '2026-10-01 10:00:00'),
    (9, 1, 1, 20, 0, 'Correct discounted price.', '2026-10-01 10:00:00'),
    (10, 1, 1, 20, 0, 'Correct average speed.', '2026-10-01 10:00:00'),
    (11, 1, 1, 20, 0, 'Correct compound interest.', '2026-10-01 10:00:00'),
    (12, 1, 1, 20, 0, 'Correct probability with reasoning.', '2026-10-01 10:00:00'),
    (13, 1, 1, 10, NULL, 'Correct implementation.', '2026-10-02 10:00:00'),
    (14, 1, 1, 9, NULL, 'Correct high-level approach.', '2026-10-02 10:00:00'),
    (14, 2, 2, 9.5, 0, 'Automated rubric judged the approach nearly complete.', '2026-10-02 10:30:00'),
    (15, 1, 1, 10, NULL, 'Correct, handles case and punctuation.', '2026-10-02 10:00:00'),
    (16, 1, 1, 9, NULL, 'Correct O(1) design, minor edge case missing.', '2026-10-02 10:00:00'),
    (17, 1, 1, 5, 0, 'Correct transitive reasoning.', '2026-10-02 10:00:00'),
    (18, 1, 1, 5, 0, 'Correct conclusion and explanation.', '2026-10-02 10:00:00'),
    (19, 1, 1, 0, 1, 'Invented a release year not supplied by the prompt.', '2026-10-02 10:00:00'),
    (20, 1, 1, 4, 0, 'Correct order but no explanation.', '2026-10-02 10:00:00'),
    (21, 1, 1, 20, 0, 'Correct discounted price.', '2026-10-02 10:00:00'),
    (22, 1, 1, 20, 0, 'Correct formula and result.', '2026-10-02 10:00:00'),
    (23, 1, 1, 17, 0, 'Correct result but the method is omitted.', '2026-10-02 10:00:00'),
    (24, 1, 1, 4, 0, 'Miscounted the favourable outcomes.', '2026-10-02 10:00:00'),
    (25, 1, 1, 9, NULL, 'Correct for non-negative integer input.', '2026-10-03 10:00:00'),
    (26, 1, 1, 8.5, NULL, 'Approach lacks detail on edge cases.', '2026-10-03 10:00:00'),
    (27, 1, 1, 8, NULL, 'Correct idea, no code.', '2026-10-03 10:00:00'),
    (29, 1, 1, 5, 0, 'Correct transitive reasoning.', '2026-10-03 10:00:00'),
    (30, 1, 1, 5, 0, 'Correct conclusion.', '2026-10-03 10:00:00'),
    (31, 1, 1, 5, 0, 'Correctly states that no year is given.', '2026-10-03 10:00:00'),
    (32, 1, 1, 3, 0, 'Incomplete ordering; Carol is omitted.', '2026-10-03 10:00:00'),
    (33, 1, 1, 20, 0, 'Correct calculation.', '2026-10-03 10:00:00'),
    (34, 1, 1, 20, 0, 'Correct calculation.', '2026-10-03 10:00:00'),
    (35, 1, 1, 12, 0, 'Ignored compounding.', '2026-10-03 10:00:00'),
    (37, 1, 1, 10, NULL, 'Correct implementation.', '2026-10-04 10:00:00'),
    (38, 1, 1, 9, NULL, 'Correct approach.', '2026-10-04 10:00:00'),
    (38, 3, 3, 8, 0, 'Human reviewer wanted a complete implementation.', '2026-10-04 10:30:00'),
    (39, 1, 1, 8.5, NULL, 'Correct design, edge cases not discussed.', '2026-10-04 10:00:00');

-- Mark every run finished only after its results are inserted.
UPDATE benchmark_runs
SET status = 'Completed',
    completed_at = substr(started_at, 1, 10) || ' 09:30:00'
WHERE run_id BETWEEN 1 AND 10;

COMMIT;

-- ============================================================
-- PART 2: COMMON REPORTING QUERIES
-- ============================================================

.headers on
.mode column

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
ORDER BY model_count DESC, p.provider_name;

-- 4. Response-weighted average score for every model/category.
-- Uses the view's unrounded total_score, so rounding happens only once.
SELECT
    provider_name,
    model_name,
    category_name,
    ROUND(SUM(total_score) / NULLIF(SUM(evaluated_tests), 0), 2)
        AS average_score,
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
-- Ranking uses the unrounded score so rounding cannot create false ties.
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

-- 7. Compare latency per model for completed runs.
-- Average latency counts successful responses only; the slowest attempt
-- (which may be a timeout) is shown separately.
SELECT
    p.provider_name,
    m.model_name,
    ROUND(AVG(CASE WHEN tr.execution_status = 'Success'
                   THEN tr.latency_ms END), 2) AS avg_success_latency_ms,
    COUNT(CASE WHEN tr.execution_status = 'Success'
               THEN tr.latency_ms END) AS success_observations,
    MAX(tr.latency_ms) AS slowest_attempt_ms
FROM test_results tr
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN model_versions mv ON br.version_id = mv.version_id
JOIN models m ON mv.model_id = m.model_id
JOIN providers p ON m.provider_id = p.provider_id
WHERE br.status = 'Completed'
GROUP BY p.provider_name, m.model_id, m.model_name
ORDER BY avg_success_latency_ms ASC;

-- 8. Sum recorded estimated costs; unknown costs remain excluded from the sum.
SELECT
    p.provider_name,
    m.model_name,
    ROUND(SUM(tr.estimated_cost_usd), 6) AS recorded_cost_usd,
    COUNT(tr.estimated_cost_usd) AS cost_observations,
    COUNT(*) AS total_attempts
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

-- 10. Hallucination rate per model. Each assessed response counts once;
-- responses where no evaluator checked for hallucination (NULL flag)
-- are left out of the denominator instead of counting as "clean".
WITH response_flags AS (
    SELECT
        result_id,
        AVG(hallucination_flag) AS hallucination_weight   -- NULL if never assessed
    FROM evaluations
    GROUP BY result_id
)
SELECT
    p.provider_name,
    m.model_name,
    ROUND(100.0 * SUM(rf.hallucination_weight)
          / NULLIF(COUNT(rf.hallucination_weight), 0), 2)
        AS hallucination_rate_pct,
    COUNT(rf.hallucination_weight) AS assessed_responses,
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

-- 11. Execution success and failure counts for completed runs.
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
GROUP BY p.provider_name, m.model_id, m.model_name
ORDER BY p.provider_name, m.model_name;

-- 12. Find test cases averaging below 90 (normalized), counting each response once.
WITH response_scores AS (
    SELECT result_id, AVG(score) AS avg_score
    FROM v_evaluation_scores
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
    FROM v_evaluation_scores
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
        bs.suite_name,
        br.attempt_number,
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
    JOIN benchmark_suites bs ON br.suite_id = bs.suite_id
)
SELECT provider_name, model_name, version_name, suite_name,
       attempt_number, run_date, status
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
ORDER BY evaluations_completed DESC, ev.evaluator_name;

-- 17. Identify responses where evaluators disagree by 10+ points (0-100 scale).
SELECT
    tr.result_id,
    p.provider_name,
    m.model_name,
    tr.test_case_id,
    ROUND(MIN(es.score), 2) AS lowest_score,
    ROUND(MAX(es.score), 2) AS highest_score,
    ROUND(MAX(es.score) - MIN(es.score), 2) AS score_difference
FROM test_results tr
JOIN v_evaluation_scores es ON tr.result_id = es.result_id
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN model_versions mv ON br.version_id = mv.version_id
JOIN models m ON mv.model_id = m.model_id
JOIN providers p ON m.provider_id = p.provider_id
WHERE br.status = 'Completed'
GROUP BY tr.result_id, p.provider_name, m.model_name, tr.test_case_id
HAVING COUNT(es.evaluation_id) > 1
   AND MAX(es.score) - MIN(es.score) >= 10
ORDER BY score_difference DESC, tr.result_id;

-- 18. Find the top-performing test case in each suite, averaging
-- evaluators per response before comparing responses.
WITH response_scores AS (
    SELECT result_id, AVG(score) AS avg_score
    FROM v_evaluation_scores
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
    tr.latency_ms,
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
    ROUND(avg_score, 2) AS avg_score,
    total_tests,
    evaluated_tests,
    cost_observations,
    ROUND(total_cost_usd, 6) AS total_cost_usd,
    CASE
        WHEN evaluated_tests = total_tests
         AND cost_observations = total_tests
        THEN ROUND(avg_score / NULLIF(total_cost_usd, 0), 2)
    END AS score_per_usd
FROM v_model_performance
WHERE avg_score IS NOT NULL
ORDER BY score_per_usd DESC NULLS LAST, provider_name, model_name, suite_name;

-- 21. Show raw responses with the method and evaluator for each score.
-- Both the raw mark and the normalized 0-100 score are displayed.
SELECT
    tr.result_id,
    p.provider_name,
    m.model_name,
    tc.test_case_id,
    tr.execution_status,
    tr.response,
    em.method_name,
    ev.evaluator_name,
    es.raw_score,
    es.max_score,
    ROUND(es.score, 2) AS score_0_100,
    es.hallucination_flag,
    es.correctness_notes
FROM test_results tr
JOIN benchmark_runs br ON tr.run_id = br.run_id
JOIN model_versions mv ON br.version_id = mv.version_id
JOIN models m ON mv.model_id = m.model_id
JOIN providers p ON m.provider_id = p.provider_id
JOIN test_cases tc ON tr.test_case_id = tc.test_case_id
LEFT JOIN v_evaluation_scores es ON tr.result_id = es.result_id
LEFT JOIN evaluation_methods em ON es.method_id = em.method_id
LEFT JOIN evaluators ev ON es.evaluator_id = ev.evaluator_id
ORDER BY tr.result_id, es.evaluated_at, es.evaluation_id;

-- ============================================================
-- QUERY PLANS
-- EXPLAIN QUERY PLAN shows that the indexes are actually used.
-- ============================================================

-- 22. Results of one run: served by the (run_id, test_case_id) UNIQUE index.
EXPLAIN QUERY PLAN
SELECT result_id, test_case_id, execution_status
FROM test_results
WHERE run_id = 4;

-- 23. Latest run for one model version: served by idx_runs_version_date.
EXPLAIN QUERY PLAN
SELECT run_id, run_date
FROM benchmark_runs
WHERE version_id = 2
ORDER BY run_date DESC
LIMIT 1;

-- ============================================================
-- PART 3: EXAMPLE DATA-MODIFICATION OPERATIONS
-- Commented out so the sample data stays unchanged when this
-- file is run from top to bottom. Uncomment and adapt to practice.
-- ============================================================

-- INSERT: Register a new provider.
-- INSERT INTO providers (provider_name, website, headquarters)
-- VALUES ('New Research Lab', 'https://example.com', 'India');

-- UPDATE: Mark a model version as inactive.
-- UPDATE model_versions
-- SET is_active = 0
-- WHERE version_id = 3;

-- TRANSACTION: Record a repeat run, one response, and its evaluation.
-- BEGIN TRANSACTION;
-- INSERT INTO benchmark_runs
--     (version_id, suite_id, attempt_number, status, started_at)
-- VALUES (1, 1, 2, 'Running', CURRENT_TIMESTAMP);
-- INSERT INTO test_results
--     (run_id, test_case_id, response, execution_status, latency_ms)
-- VALUES (last_insert_rowid(), 1, 'def factorial(n): ...', 'Success', 400);
-- INSERT INTO evaluations (result_id, method_id, evaluator_id, raw_score)
-- VALUES (last_insert_rowid(), 1, 1, 9);   -- 9 out of the test's max_score
-- COMMIT;

-- DELETE: Remove a pending benchmark run.
-- Deleting a run also deletes its test_results and evaluations
-- because those child relationships use ON DELETE CASCADE.
-- DELETE FROM benchmark_runs
-- WHERE run_id = 11
--   AND status = 'Pending';
