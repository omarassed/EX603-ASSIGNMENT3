-- ==========================================
-- Task 5.1: Connect Producers to Their Data
-- Dataset: ex603 airline reference dataset (airline.sql)
--   event    = bookings        actor   = passengers
--   producer = flights         catalog = airports
--   junction = flight_routes   (flights <-> airports, many-to-many)
-- Producers flagged in Assignment 4: flight 11 and flight 9
-- ==========================================


-- ------------------------------------------
-- QUESTION 1: Three-table INNER JOIN (event + actor + producer)
-- Question: Who are the people behind each booking? For every booking, which
-- passenger made it, which flight it was on, and when was it booked?
-- ------------------------------------------
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
-- QUESTION 2a: Junction-table traversal (producer -> junction -> catalog)
-- Question: Which flights serve our catalog tag, Incheon (ICN)? ICN is the
-- airport on flagged flight 11's route and has the highest cancellation rate
-- of the five airports, so it is the tag worth checking first.
-- ------------------------------------------
SELECT
    a.iata_code,
    a.airport_name,
    f.flight_id,
    f.flight_number,
    f.is_active,
    fr.effective_from
FROM flights AS f
INNER JOIN flight_routes AS fr ON fr.flight_id  = f.flight_id
INNER JOIN airports      AS a  ON a.airport_id  = fr.airport_id
WHERE a.iata_code = 'ICN'
ORDER BY f.flight_id;


-- ------------------------------------------
-- QUESTION 2b: Junction-table traversal for the flagged producers
-- Question: Which airports do flagged flights 9 and 11 serve, and how many
-- other flights share each of those airports?
-- ------------------------------------------
SELECT
    f.flight_id,
    f.flight_number,
    a.iata_code,
    a.airport_name,
    (SELECT COUNT(*) - 1
       FROM flight_routes AS fr2
      WHERE fr2.airport_id = a.airport_id) AS other_flights_at_airport
FROM flights AS f
INNER JOIN flight_routes AS fr ON fr.flight_id = f.flight_id
INNER JOIN airports      AS a  ON a.airport_id = fr.airport_id
WHERE f.flight_id IN (9, 11)
ORDER BY f.flight_id, a.iata_code;


-- ------------------------------------------
-- QUESTION 3: Self join on the producer table
-- Question: How do flagged flights 9 and 11 compare with other flights from
-- the same origin country? Do their peers share the same profile (capacity,
-- active status) and the same cancellation problem, or do activity levels differ?
-- (Failure = 'cancelled', the definition used in Assignment 4; disputed
--  bookings are shown separately for transparency.)
-- ------------------------------------------
WITH flight_stats AS (
    SELECT
        f.flight_id,
        COUNT(b.booking_id) AS bookings,
        SUM(CASE WHEN b.booking_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
        SUM(CASE WHEN b.booking_status = 'disputed'  THEN 1 ELSE 0 END) AS disputed
    FROM flights AS f
    LEFT JOIN bookings AS b ON b.flight_id = f.flight_id
    GROUP BY f.flight_id
)
SELECT
    f1.origin_country,
    f1.flight_id      AS flagged_flight,
    f1.seat_capacity  AS flagged_capacity,
    f1.is_active      AS flagged_active,
    s1.bookings       AS flagged_bookings,
    s1.cancelled      AS flagged_cancelled,
    ROUND(100.0 * s1.cancelled / NULLIF(s1.bookings, 0), 1) AS flagged_cancel_pct,
    f2.flight_id      AS peer_flight,
    f2.seat_capacity  AS peer_capacity,
    f2.is_active      AS peer_active,
    s2.bookings       AS peer_bookings,
    s2.cancelled      AS peer_cancelled,
    ROUND(100.0 * s2.cancelled / NULLIF(s2.bookings, 0), 1) AS peer_cancel_pct
FROM flights AS f1
INNER JOIN flights AS f2
        ON f2.origin_country = f1.origin_country
       AND f2.flight_id <> f1.flight_id
INNER JOIN flight_stats AS s1 ON s1.flight_id = f1.flight_id
INNER JOIN flight_stats AS s2 ON s2.flight_id = f2.flight_id
WHERE f1.flight_id IN (9, 11)
ORDER BY f1.flight_id, f2.flight_id;
