-- ==========================================
-- Task 5.2: Find Records That Joins May Exclude
-- Relationship examined: flights (producer) <-> bookings (event)
-- ==========================================


-- ------------------------------------------
-- PART A-1: LEFT JOIN
-- Question: How many bookings does every flight have, including flights that
-- have never had a booking?
-- ------------------------------------------
SELECT
    f.flight_id,
    f.flight_number,
    COUNT(b.booking_id) AS booking_count
FROM flights AS f
LEFT JOIN bookings AS b ON b.flight_id = f.flight_id
GROUP BY f.flight_id, f.flight_number
ORDER BY f.flight_id;


-- ------------------------------------------
-- PART A-2: Equivalent INNER JOIN
-- Question: The same per-flight booking count, using an INNER JOIN. Which
-- flights silently disappear?
-- ------------------------------------------
SELECT
    f.flight_id,
    f.flight_number,
    COUNT(b.booking_id) AS booking_count
FROM flights AS f
INNER JOIN bookings AS b ON b.flight_id = f.flight_id
GROUP BY f.flight_id, f.flight_number
ORDER BY f.flight_id;


-- ------------------------------------------
-- PART A-3: Count of producers excluded by the INNER JOIN
-- Question: How many distinct flights does the LEFT JOIN return, how many does
-- the INNER JOIN return, and how many are excluded? (COUNT(DISTINCT flight_id)
-- so a flight with many bookings is counted once.)
-- ------------------------------------------
SELECT
    (SELECT COUNT(DISTINCT f.flight_id)
       FROM flights AS f
       LEFT JOIN bookings AS b ON b.flight_id = f.flight_id)  AS left_join_flights,
    (SELECT COUNT(DISTINCT f.flight_id)
       FROM flights AS f
      INNER JOIN bookings AS b ON b.flight_id = f.flight_id)  AS inner_join_flights,
    (SELECT COUNT(DISTINCT f.flight_id)
       FROM flights AS f
       LEFT JOIN bookings AS b ON b.flight_id = f.flight_id)
  - (SELECT COUNT(DISTINCT f.flight_id)
       FROM flights AS f
      INNER JOIN bookings AS b ON b.flight_id = f.flight_id)  AS flights_excluded_by_inner_join;


-- ------------------------------------------
-- PART A-4: Which flights are excluded?
-- Question: Which flights does the LEFT JOIN keep that the INNER JOIN drops?
-- (LEFT JOIN rows where no booking matched have a NULL booking_id.)
-- ------------------------------------------
SELECT
    f.flight_id,
    f.flight_number,
    f.origin_country,
    f.is_active,
    f.first_scheduled_on
FROM flights AS f
LEFT JOIN bookings AS b ON b.flight_id = f.flight_id
WHERE b.booking_id IS NULL
ORDER BY f.flight_id;


-- ------------------------------------------
-- PART B-1: RIGHT JOIN that returns the same records as Part A-1
-- Question: Can the same "every flight, with or without bookings" result be
-- produced by flipping the table order and using RIGHT JOIN?
-- ------------------------------------------
SELECT
    f.flight_id,
    f.flight_number,
    COUNT(b.booking_id) AS booking_count
FROM bookings AS b
RIGHT JOIN flights AS f ON f.flight_id = b.flight_id
GROUP BY f.flight_id, f.flight_number
ORDER BY f.flight_id;


-- ------------------------------------------
-- PART B-2: Verify LEFT JOIN and RIGHT JOIN results match
-- Question: Do the LEFT JOIN and RIGHT JOIN return exactly the same rows?
-- Rows in either result but not the other are counted in both directions;
-- 0 and 0 (with 15 rows each) proves they are identical.
-- ------------------------------------------
WITH left_result AS (
    SELECT f.flight_id, f.flight_number, COUNT(b.booking_id) AS booking_count
    FROM flights AS f
    LEFT JOIN bookings AS b ON b.flight_id = f.flight_id
    GROUP BY f.flight_id, f.flight_number
),
right_result AS (
    SELECT f.flight_id, f.flight_number, COUNT(b.booking_id) AS booking_count
    FROM bookings AS b
    RIGHT JOIN flights AS f ON f.flight_id = b.flight_id
    GROUP BY f.flight_id, f.flight_number
)
SELECT
    (SELECT COUNT(*) FROM left_result)  AS left_rows,
    (SELECT COUNT(*) FROM right_result) AS right_rows,
    (SELECT COUNT(*) FROM (SELECT * FROM left_result  EXCEPT SELECT * FROM right_result) x) AS in_left_not_right,
    (SELECT COUNT(*) FROM (SELECT * FROM right_result EXCEPT SELECT * FROM left_result)  y) AS in_right_not_left;


-- ------------------------------------------
-- PART B-3: FULL OUTER JOIN (flights <-> bookings)
-- Question: Across both tables, how many rows are matched, how many flights
-- have no booking, and how many bookings point to no known flight?
-- ------------------------------------------
SELECT
    CASE
        WHEN f.flight_id IS NOT NULL AND b.booking_id IS NOT NULL THEN 'matched: flight with booking'
        WHEN b.booking_id IS NULL THEN 'unmatched: flight with no booking'
        ELSE 'unmatched: booking with no flight'
    END AS match_type,
    COUNT(*)                       AS row_count,
    COUNT(DISTINCT f.flight_id)    AS distinct_flights,
    COUNT(DISTINCT b.booking_id)   AS distinct_bookings
FROM flights AS f
FULL OUTER JOIN bookings AS b ON b.flight_id = f.flight_id
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------
-- PART B-4: FULL OUTER JOIN where BOTH sides can be unmatched
-- Question: Comparing "flights that have a route on file" with "flights that
-- have bookings", which flights appear on only one side? Neither a LEFT nor a
-- RIGHT join alone shows both kinds of gap at once.
-- ------------------------------------------
WITH routed AS (
    SELECT DISTINCT flight_id FROM flight_routes
),
booked AS (
    SELECT flight_id, COUNT(*) AS booking_count
    FROM bookings
    GROUP BY flight_id
)
SELECT
    COALESCE(r.flight_id, k.flight_id) AS flight_id,
    (r.flight_id IS NOT NULL)          AS has_route,
    COALESCE(k.booking_count, 0)       AS booking_count,
    CASE
        WHEN r.flight_id IS NULL THEN 'bookings but NO route on file'
        WHEN k.flight_id IS NULL THEN 'route but NO bookings'
        ELSE 'route and bookings'
    END AS status
FROM routed AS r
FULL OUTER JOIN booked AS k ON k.flight_id = r.flight_id
ORDER BY 1;


-- ------------------------------------------
-- PART C-1: Producers with no events, using NOT EXISTS
-- Question: Which flights have never had a single booking?
-- ------------------------------------------
SELECT
    f.flight_id,
    f.flight_number,
    f.is_active
FROM flights AS f
WHERE NOT EXISTS (
    SELECT 1
    FROM bookings AS b
    WHERE b.flight_id = f.flight_id
)
ORDER BY f.flight_id;


-- ------------------------------------------
-- PART C-2: Producers with no events, using EXCEPT
-- Question: Same question, answered as a set difference: all flight IDs minus
-- the flight IDs that appear in bookings.
-- ------------------------------------------
SELECT flight_id FROM flights
EXCEPT
SELECT flight_id FROM bookings
ORDER BY flight_id;


-- ------------------------------------------
-- PART C-3: Confirm both approaches identify the same producers
-- Question: Do NOT EXISTS and EXCEPT return exactly the same flight IDs?
-- (Expect: 2 rows each, 0 differences in either direction.)
-- ------------------------------------------
WITH not_exists_ids AS (
    SELECT f.flight_id
    FROM flights AS f
    WHERE NOT EXISTS (SELECT 1 FROM bookings AS b WHERE b.flight_id = f.flight_id)
),
except_ids AS (
    SELECT flight_id FROM flights
    EXCEPT
    SELECT flight_id FROM bookings
)
SELECT
    (SELECT COUNT(*) FROM not_exists_ids) AS not_exists_rows,
    (SELECT COUNT(*) FROM except_ids)     AS except_rows,
    (SELECT COUNT(*) FROM (SELECT flight_id FROM not_exists_ids EXCEPT SELECT flight_id FROM except_ids) x) AS only_in_not_exists,
    (SELECT COUNT(*) FROM (SELECT flight_id FROM except_ids EXCEPT SELECT flight_id FROM not_exists_ids) y) AS only_in_except;
