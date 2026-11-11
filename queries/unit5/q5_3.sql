-- ==========================================
-- Task 5.3: Understand Join Performance and Execution Plans
-- ==========================================


-- ------------------------------------------
-- PART A-1: CROSS JOIN with row-count proof (one result, for one screenshot)
-- Question: How many rows does airports CROSS JOIN flights produce, and does it
-- equal (rows in airports) x (rows in flights)?
-- ------------------------------------------
SELECT
    (SELECT COUNT(*) FROM airports)                          AS airports_rows,
    (SELECT COUNT(*) FROM flights)                           AS flights_rows,
    (SELECT COUNT(*) FROM airports) * (SELECT COUNT(*) FROM flights) AS expected_rows,
    (SELECT COUNT(*) FROM airports CROSS JOIN flights)       AS cross_join_rows;


-- ------------------------------------------
-- PART A-2: The CROSS JOIN itself
-- Question: What does every possible airport-flight pairing look like?
-- ------------------------------------------
SELECT
    a.iata_code,
    f.flight_id,
    f.flight_number
FROM airports AS a
CROSS JOIN flights AS f
ORDER BY a.iata_code, f.flight_id;


-- ------------------------------------------
-- PART A-3: A useful Cartesian product
-- Question: Which airport-flight pairings are NOT currently on a route? The
-- CROSS JOIN builds the full grid of possibilities; the LEFT JOIN to the
-- junction table removes the pairings that already exist.
-- ------------------------------------------
SELECT
    a.iata_code,
    COUNT(*) AS flights_not_serving_airport
FROM airports AS a
CROSS JOIN flights AS f
LEFT JOIN flight_routes AS fr
       ON fr.flight_id  = f.flight_id
      AND fr.airport_id = a.airport_id
WHERE fr.flight_id IS NULL
GROUP BY a.iata_code
ORDER BY a.iata_code;


-- ------------------------------------------
-- PART B-1: EXPLAIN on the three-table join from Task 5.1, Question 1
-- Question: How does PostgreSQL plan to execute the bookings + passengers +
-- flights join?
-- ------------------------------------------
EXPLAIN
SELECT
    b.booking_id,
    p.passenger_name,
    f.flight_id,
    f.flight_number,
    b.booked_at,
    b.booking_status
FROM bookings AS b
INNER JOIN passengers AS p ON p.passenger_id = b.passenger_id
INNER JOIN flights    AS f ON f.flight_id    = b.flight_id
ORDER BY b.booked_at;


-- ------------------------------------------
-- PART B-2: EXPLAIN ANALYZE on the same query
-- Question: What actually happens when the query runs (real row counts and
-- timings)? Safe here because it is a read-only SELECT.
-- ------------------------------------------
EXPLAIN ANALYZE
SELECT
    b.booking_id,
    p.passenger_name,
    f.flight_id,
    f.flight_number,
    b.booked_at,
    b.booking_status
FROM bookings AS b
INNER JOIN passengers AS p ON p.passenger_id = b.passenger_id
INNER JOIN flights    AS f ON f.flight_id    = b.flight_id
ORDER BY b.booked_at;
