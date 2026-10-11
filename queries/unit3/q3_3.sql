-- =====================================================================
-- Task 3.3: Reliable Dashboard Query Variants & Equivalence Audit
-- Two-Step Question: Find all flights that have at least one passenger booking.
-- =====================================================================

-- ---------------------------------------------------------------------
-- APPROACH 1: Subquery using IN
-- ---------------------------------------------------------------------
SELECT flight_id, flight_number, origin_country
FROM flights
WHERE flight_id IN (
    SELECT flight_id 
    FROM bookings
);

-- ---------------------------------------------------------------------
-- APPROACH 2: Common Table Expression (CTE) using WITH
-- ---------------------------------------------------------------------
WITH booked_flight_ids AS (
    SELECT DISTINCT flight_id 
    FROM bookings
)
SELECT f.flight_id, f.flight_number, f.origin_country
FROM flights f
JOIN booked_flight_ids b ON f.flight_id = b.flight_id;

-- ---------------------------------------------------------------------
-- APPROACH 3: Correlated Subquery using EXISTS (Set-based approach)
-- ---------------------------------------------------------------------
SELECT flight_id, flight_number, origin_country
FROM flights f
WHERE EXISTS (
    SELECT 1 
    FROM bookings b 
    WHERE b.flight_id = f.flight_id
);

-- ---------------------------------------------------------------------
-- VALIDATION: Demonstrate that result sets match identically 
-- (This query should return 0 rows if all three methods produce identical output)
-- ---------------------------------------------------------------------
-- Checking difference between Approach 1 (IN) and Approach 3 (EXISTS)
(
    SELECT flight_id FROM flights WHERE flight_id IN (SELECT flight_id FROM bookings)
    EXCEPT
    SELECT flight_id FROM flights f WHERE EXISTS (SELECT 1 FROM bookings b WHERE b.flight_id = f.flight_id)
)
UNION ALL
(
    SELECT flight_id FROM flights f WHERE EXISTS (SELECT 1 FROM bookings b WHERE b.flight_id = f.flight_id)
    EXCEPT
    SELECT flight_id FROM flights WHERE flight_id IN (SELECT flight_id FROM bookings)
);


-- =====================================================================
-- NOTE ON EQUIVALENCE BREAKS (Requirement 5):
-- Condition: NULL values in the inner subquery comparison column.
-- If we used NOT IN instead of IN/EXISTS, and the subquery returned even 
-- a single NULL value, the entire predicate evaluates to UNKNOWN under 
-- three-valued logic, causing the query to return zero rows silently.
-- =====================================================================