-- ==========================================
-- Task 4.2: Build the Breakdown Leadership Asked For
-- ==========================================

-- ------------------------------------------
-- PART A: Two numbers in one pass (Conditional Aggregation)
-- Question: For each flight (producer), what is the total number of bookings and the total number of failed/cancelled bookings computed in a single pass without a global WHERE filter?
-- ------------------------------------------
SELECT 
    flight_id,
    COUNT(*) AS total_events,
    SUM(CASE WHEN booking_status = 'cancelled' OR booking_status = 'failed' THEN 1 ELSE 0 END) AS failure_count
FROM bookings
GROUP BY flight_id
ORDER BY total_events DESC;


-- ------------------------------------------
-- PART B: Subtotals and a grand total
-- Question: What are the regional (booking_country) and status subtotals and platform grand total of bookings using ROLLUP, without individual detail rows?
-- ------------------------------------------
SELECT 
    booking_country,
    booking_status,
    COUNT(*) AS total_bookings,
    AVG(fare_paid) AS avg_fare
FROM bookings
GROUP BY ROLLUP (booking_country, booking_status)
ORDER BY booking_country, booking_status;


-- ------------------------------------------
-- PART C: A two-step pipeline
-- Question: What is the average booking count across high-volume producers, established using a two-step CTE pipeline?
-- ------------------------------------------
WITH producer_summary AS (
    SELECT 
        flight_id,
        COUNT(*) AS booking_count,
        AVG(fare_paid) AS avg_fare
    FROM bookings
    GROUP BY flight_id
)
SELECT 
    AVG(booking_count) AS avg_bookings_per_high_volume_producer,
    AVG(avg_fare) AS overall_avg_fare
FROM producer_summary
WHERE booking_count >= 5;