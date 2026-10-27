-- ==========================================
-- Task 4.1: Measure the Platform
-- ==========================================

-- ------------------------------------------
-- 1. Platform-wide summary statistics
-- Question: What are the count, total, average, minimum, and maximum of fares across all bookings, and how many distinct passengers appear?
-- ------------------------------------------
SELECT 
    COUNT(*) AS total_bookings,
    SUM(fare_paid) AS total_revenue,
    AVG(fare_paid) AS average_fare,
    MIN(fare_paid) AS min_fare,
    MAX(fare_paid) AS max_fare,
    COUNT(DISTINCT passenger_id) AS distinct_passengers
FROM bookings;


-- ------------------------------------------
-- 2. Event count and average metric per producer
-- Question: What is the booking count and average fare for each flight (producer), sorted from most to least bookings?
-- ------------------------------------------
SELECT 
    flight_id,
    COUNT(*) AS booking_count,
    AVG(fare_paid) AS avg_fare
FROM bookings
GROUP BY flight_id
ORDER BY booking_count DESC;


-- ------------------------------------------
-- 3. Filtering grouped results with HAVING
-- Question: Which flights have enough booking volume (at least 5 bookings) for their average fare to be representative?
-- ------------------------------------------
SELECT 
    flight_id,
    COUNT(*) AS booking_count,
    AVG(fare_paid) AS avg_fare
FROM bookings
GROUP BY flight_id
HAVING COUNT(*) >= 5
ORDER BY booking_count DESC;


-- ------------------------------------------
-- 4. Two-dimension grouping (Flight and Booking Country / Region)
-- Question: How do booking counts and average fares vary across flights and booking countries (regions) combined?
-- ------------------------------------------
SELECT 
    flight_id,
    booking_country,
    COUNT(*) AS booking_count,
    AVG(fare_paid) AS avg_fare
FROM bookings
GROUP BY flight_id, booking_country
ORDER BY flight_id, booking_country;