
-- ------------------------------------------
-- PART A: The rows that vanished (3VL)
-- ------------------------------------------

-- Step 1: Deliberately insert a row with a NULL value in origin_country (or update one)
-- To demonstrate this safely without breaking constraints, look at origin_country or add a test flight,
-- or, can update one row's origin_country to NULL temporarily, or use a column we can alter.
-- Alter the table to add a nullable column for demonstration:
ALTER TABLE flights ADD COLUMN gate VARCHAR(20);

-- Insert/Update a few sample gate values, leaving some as NULL
UPDATE flights SET gate = 'Gate A' WHERE flight_id IN (1, 2);
UPDATE flights SET gate = 'Gate B' WHERE flight_id IN (4, 5);
-- Remaining flights will have NULL gates automatically.

-- Step 2: Query with an inequality predicate (rows where gate != 'Gate A' silently drops NULLs)
SELECT flight_id, flight_number, gate
FROM flights
WHERE gate != 'Gate A';

-- Step 3: Count rows silently omitted (including NULLs)
SELECT COUNT(*) AS omitted_rows_count
FROM flights
WHERE gate = 'Gate A' OR gate IS NULL;

-- Step 4: Repair the query using explicit IS NULL check
SELECT flight_id, flight_number, gate
FROM flights
WHERE gate != 'Gate A' OR gate IS NULL;


-- ------------------------------------------
-- PART B: The alias that did not exist yet
-- ------------------------------------------

-- Step 1 (Error Demonstration): Referencing an alias in WHERE fails because of logical order of evaluation
/*
SELECT flight_number, (seat_capacity * 0.8) AS capped_seats
FROM flights
WHERE capped_seats > 200;
-- ERROR: column "capped_seats" does not exist
*/

-- Step 2 (Rewrite 1): Repeating the expression directly in the WHERE clause
SELECT flight_number, (seat_capacity * 0.8) AS capped_seats
FROM flights
WHERE (seat_capacity * 0.8) > 200;

-- Step 2 (Rewrite 2): Using a CTE so the alias becomes a real, queryable column
WITH flight_caps AS (
    SELECT flight_number, (seat_capacity * 0.8) AS capped_seats
    FROM flights
)
SELECT flight_number, capped_seats
FROM flight_caps
WHERE capped_seats > 200;