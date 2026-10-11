-- Task 3.1: Exploration of active, high-capacity flights
SELECT flight_id, flight_number, seat_capacity, is_active
FROM flights
WHERE is_active = TRUE AND seat_capacity >= 180;