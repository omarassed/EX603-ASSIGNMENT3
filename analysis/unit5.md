# Unit 5 Analysis & Written Deliverables

**Dataset mapping:** event = `bookings` · actor = `passengers` · producer = `flights` · catalog = `airports` · junction = `flight_routes`

**Producers flagged in Assignment 4:** Flight 11 (5 cancellations in 16 bookings, 31.3%) and Flight 9 (4 in 14, 28.6%). "Failure" here means `booking_status = 'cancelled'`, which is the definition the Unit 4 query applied.

---

## Task 5.1 Write-up: Connect Producers to Their Data

### Results summary

- **Question 1 (three-table join):** returns all 200 bookings, each with the passenger's name, the flight number and the booking time, sorted chronologically. Nothing is lost in the join, because every booking has a valid passenger and flight (both are enforced by foreign keys).
- **Question 2a (junction traversal, ICN tag):** Incheon (ICN) is served by three flights: 4, **11** and 12. Of the five airports, ICN has the highest cancellation rate (9 of 39 bookings on its flights, 23.1%).
- **Question 2b (flagged flights' airports):** Flight 9 serves only SGN, which is shared with 8 other flights. Flight 11 serves ICN (2 other flights) and SIN (4 other flights). The two flagged flights have **no airport in common**, so a single shared airport does not explain both of them.
- **Question 3 (self join on `flights`):** each flagged flight was compared with the other flights from the same origin country.

| Flagged flight | Capacity | Active | Cancel % | Peer | Capacity | Active | Cancel % |
|---|---|---|---|---|---|---|---|
| 9 (Singapore) | 280 | **No** | 28.6% | 4 | 320 | Yes | 33.3% (6 bookings) |
| 11 (Japan) | 193 | Yes | 31.3% | 2 | 320 | Yes | 25.0% |
| 11 (Japan) | 193 | Yes | 31.3% | 6 | 90 | Yes | 19.0% |

Flight 11 cancels more often than both of its Japanese peers, even though Flight 6 carries more volume (21 bookings), so volume does not explain its rate. Flight 9's only Singapore peer (Flight 4) actually has a higher cancellation rate, but on just 6 bookings, which is too few to treat as a pattern. The detail that stands out is that **Flight 9 is marked inactive (`is_active = false`) yet still has 14 bookings, 4 of them cancelled.** Passengers may be booking a flight that is being wound down, which would naturally lead to cancellations. The data shows this pattern but does not prove it is the cause.

### What feature or report could use the three-table join?

A **"Booking Activity Log"** in the operations console. Each row would show the passenger's name, the flight number, when it was booked and the status (confirmed, cancelled or disputed). Customer-service agents could look up a passenger's history, and route managers could filter to one flight (for example VN211) and see exactly who was affected by each cancellation, rather than just a flight ID and a count.

### Why is the junction table important for Question 2?

One flight serves many airports and one airport is served by many flights, which is a many-to-many relationship. `flight_routes` stores each flight-airport pairing as its own row, so "which flights serve ICN?" is a simple two-join query. Without it we would have to store airports as a list inside the `flights` table (e.g. `"SIN,ICN"`) and search text, or add `airport_1`, `airport_2`, ... columns. Both are slow and error-prone, cannot be indexed or protected by foreign keys properly, and break as soon as a flight gets more routes than there are columns.

---

## Task 5.2 Write-up: Find Records That Joins May Exclude

### Results summary

| Check | Result |
|---|---|
| LEFT JOIN: distinct flights returned | 15 |
| INNER JOIN: distinct flights returned | 13 |
| **Flights excluded by the INNER JOIN** | **2** |
| RIGHT JOIN rows vs LEFT JOIN rows | 15 vs 15, 0 differences in either direction (identical) |
| FULL OUTER JOIN flights ↔ bookings | 200 matched rows, 2 flights with no booking, 0 bookings with no flight |
| NOT EXISTS vs EXCEPT | 2 rows each, 0 differences: same flights (14 and 15) |

### Which producers were excluded by the inner join?

**Flight 14 (VN214, Vietnam)** and **Flight 15 (VN215, Thailand)**. Neither has a single row in `bookings`. An INNER JOIN keeps only rows that match on both sides, so a flight with no bookings has nothing to pair with and disappears. The LEFT JOIN keeps every flight and fills the booking columns with NULL, which is how they show up with `booking_count = 0`.

### What does it mean when a producer has no events?

Both flights have existed in the catalog since early-to-mid 2022 and are **marked active**, yet they had zero bookings across the whole booking period (January to December 2023). The data adds one more clue: **neither flight has any route on file in `flight_routes`**. A flight with no origin or destination airport cannot really be sold, which may be why no one booked it. Possible explanations:

- The flight was set up in the system but never fully configured (no route attached), so it never appeared in search.
- It was a planned or seasonal flight that never launched, and nobody switched off its `is_active` flag.
- It operates through a channel this table doesn't record (e.g. charter or partner bookings).
- It is a data-entry or migration error.

### What a FULL OUTER JOIN can reveal that a LEFT or RIGHT join alone may not

A LEFT JOIN shows gaps on one side only (flights without bookings), and a RIGHT JOIN shows the other side only. A FULL OUTER JOIN shows **both kinds of gap in one result**. Between `flights` and `bookings`, the bookings side is empty, because the foreign key prevents a booking for a non-existent flight. Confirming that is useful in itself. The second FULL OUTER JOIN, comparing "flights with a route" against "flights with bookings", finds a gap that a LEFT JOIN from routes would have missed: **Flight 13 has 11 bookings but no route on file.** So passengers are booking a flight whose airports the system doesn't record, which is the opposite problem to Flights 14 and 15.

### NOT EXISTS vs EXCEPT

`NOT EXISTS` checks, for each flight, whether any matching booking row exists, and can return any columns from `flights`. `EXCEPT` subtracts one set of IDs from another, so both sides must have the same columns and the result is de-duplicated automatically. Both returned exactly **Flights 14 and 15**, and the comparison query found 0 differences in either direction.

### How could an inner-join-only report mislead leadership?

A report built only on inner joins shows 13 flights and implies that is the whole network. Two active flights (13% of the fleet catalog) would be invisible. Leadership would see failure rates for the flights that operate but never learn that some listed capacity isn't producing any revenue at all. Platform averages ("bookings per flight") would also be overstated, because the zero-booking flights are left out of the denominator.

### Why identify producers who have never been active?

They are a cost with no return (catalog upkeep, possibly reserved aircraft or crew, slots), and they can signal broken setup processes. If two flights went live without routes, more could follow. They are also easy wins: a configuration fix could turn them into revenue.

### What action could leadership take?

Ask the network-planning team to review Flights 14 and 15 within a set deadline. Either attach their routes and relaunch them, or formally retire them (set `is_active = false`). In the same review, add Flight 13's missing route and put a rule in place that a flight cannot be marked active without at least one route.

### What the data shows vs. what needs further investigation

| The data shows | Needs further investigation |
|---|---|
| Flights 14 and 15 have zero bookings and no routes, and are flagged active | *Why* they have no routes, and whether they were ever meant to fly |
| Flight 13 has 11 bookings but no route | Whether its route was deleted, never entered, or lives elsewhere |
| Flight 9 is inactive yet has 14 bookings (4 cancelled) | Whether the cancellations happened *because* the flight was being withdrawn, and when its status changed (we have no status history) |
| Flight 11 cancels more than its same-country peers | Root cause: the cancellation reasons, the timing, or problems specific to its route |

---

## Task 5.3 Write-up: Join Performance and Execution Plans

### CROSS JOIN result

`airports` (5 rows) × `flights` (15 rows) = **75 rows**, and the CROSS JOIN returned exactly 75 (`expected_rows = cross_join_rows = 75`).

### When is a Cartesian product useful on this platform, and when is it an error?

**Useful:** building a grid of *every possible* flight-airport combination, then using a LEFT JOIN to `flight_routes` to find pairings that don't exist yet. Query A-3 does this. For example, 12 of 15 flights don't serve ICN and only 6 don't serve SGN, which gives network planning a ready list of possible route expansions. Other uses include generating a full calendar of dates × flights for a daily report, so that days with zero bookings still appear.

**Error signal:** if a join condition is forgotten (e.g. `FROM bookings, flights` with no `WHERE`), the result is 200 × 15 = 3,000 rows instead of 200. Totals become wildly inflated and the query slows down as tables grow. A row count far larger than the biggest source table is the warning sign.

### The execution plan (EXPLAIN ANALYZE, captured in `screenshots/task5_3_explain_analyze.png`)

```
Sort  (cost=35.95..36.45 rows=200 width=545) (actual time=0.343..0.356 rows=200.00 loops=1)
  Sort Key: b.booked_at
  Sort Method: quicksort  Memory: 40kB
  Buffers: shared hit=30
  ->  Nested Loop  (cost=12.40..28.30 rows=200 width=545) (actual time=0.090..0.234 rows=200.00 loops=1)
        Buffers: shared hit=30
        ->  Hash Join  (cost=12.25..17.80 rows=200 width=287) (actual time=0.054..0.117 rows=200.00 loops=1)
              Hash Cond: (b.passenger_id = p.passenger_id)
              Buffers: shared hit=4
              ->  Seq Scan on bookings b  (cost=0.00..5.00 rows=200 width=33) (actual time=0.024..0.041 rows=200.00 loops=1)
                    Buffers: shared hit=3
              ->  Hash  (cost=11.00..11.00 rows=100 width=262) (actual time=0.023..0.023 rows=30.00 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 10kB
                    Buffers: shared hit=1
                    ->  Seq Scan on passengers p  (cost=0.00..11.00 rows=100 width=262) (actual time=0.012..0.015 rows=30.00 loops=1)
                          Buffers: shared hit=1
        ->  Memoize  (cost=0.15..0.41 rows=1 width=262) (actual time=0.000..0.000 rows=1.00 loops=200)
              Cache Key: b.flight_id
              Cache Mode: logical
              Hits: 187  Misses: 13  Evictions: 0  Overflows: 0  Memory Usage: 2kB
              Buffers: shared hit=26
              ->  Index Scan using flights_pkey on flights f  (cost=0.14..0.40 rows=1 width=262) (actual time=0.003..0.003 rows=1.00 loops=13)
                    Index Cond: (flight_id = b.flight_id)
                    Index Searches: 13
                    Buffers: shared hit=26
Planning Time: 0.128 ms
Execution Time: 0.392 ms
```

*The plain `EXPLAIN` (screenshot `task5_3_explain.png`) shows the same plan shape and costs, without the actual timings.*

### Which join algorithms did PostgreSQL choose?

1. **Hash Join** between `bookings` and `passengers`, on `passenger_id`.
2. **Nested Loop** between that result and `flights`, using an **Index Scan on `flights_pkey`** with a **Memoize** cache in front of it.
3. A final **Sort** (quicksort, in memory) for `ORDER BY booked_at`.

### What in the plan explains those choices?

- **Seq Scan on both `bookings` and `passengers`:** both tables are tiny (200 and 30 rows) and the query needs every row, so reading the whole table is cheaper than using an index. There is also **no index on `bookings.passenger_id`**, only the primary key on `booking_id`.
- **Hash Join for passengers:** PostgreSQL builds an in-memory hash table from the smaller side (`passengers`, 10 kB, 1 batch) and probes it once for each booking. That is efficient when one side fits easily in memory and there is no useful index on the join column of the large side.
- **Nested Loop + Index Scan for flights:** `flights.flight_id` is the primary key, so each lookup is a cheap index probe that returns exactly one row (`rows=1`). **Memoize** shows `Hits: 187 Misses: 13`. There are only 13 distinct flight IDs across the 200 bookings, so the index was actually read just 13 times (`loops=13`, `Index Searches: 13`) and the other 187 lookups came from cache.
- **Everything stayed in memory:** `Buffers: shared hit=30` with no disk reads, a 40 kB in-memory quicksort, and a total execution time of 0.392 ms.
- **Estimate vs. actual:** the planner *estimated* 100 passenger rows but *found* 30. The tables have never been `ANALYZE`d, so PostgreSQL is relying on default size guesses. At this size it doesn't matter, but on a large table a bad estimate can lead to the wrong algorithm.

### Why is it useful to understand the selected join algorithms?

The plan shows where the time goes and why. If a report slows down, the plan tells you whether the fix is an index, fresh statistics (`ANALYZE`), more memory (`work_mem`), or rewriting the query. Without it, tuning is guesswork. It also exposes risky patterns early, such as full scans on tables that will grow quickly.

### What would make a different algorithm more appropriate, and what might degrade as data grows?

`bookings` is the fact table and the one that will grow. Its **Seq Scan** and the **Hash Join** built on top of it are what will slow down first, together with the final **Sort** on `booked_at`. At millions of rows the sort would spill from memory to disk (`Sort Method: external merge`). Adding a `WHERE` filter (one passenger, one date range) without matching indexes on `bookings(passenger_id)` or `bookings(booked_at)` would still force a full scan. See the reflection below for how specific changes would shift the algorithm.

---

## Reflection: What Could Make PostgreSQL Choose a Different Join Algorithm? (≈220 words)

PostgreSQL picks the join algorithm it estimates to be cheapest, so anything that changes table sizes, indexes, or the number of matching rows can change the plan. Right now `passengers` (30 rows) is hashed and probed by `bookings` (200 rows), while `flights` is reached through a Nested Loop that probes its primary-key index.

If a query filtered to a single passenger and we added an index on `bookings(passenger_id)`, the planner would probably switch to a **Nested Loop with an Index Scan**, touching a handful of rows instead of hashing the whole table. In the other direction, if `passengers` grew to millions of rows and its hash table no longer fit in `work_mem`, the Hash Join would split into multiple batches written to disk. If both inputs were already sorted on the join key, for example through B-tree indexes on `bookings(passenger_id)` and `passengers(passenger_id)`, a **Merge Join** might become cheapest, particularly for large, full-table joins.

The number of distinct matching values matters too. Memoize works well here because 200 bookings share only 13 flights. If flights numbered in the thousands with few repeats, the cache would stop paying off and a Hash Join might win. Finally, stale statistics are a hidden risk: the planner guessed 100 passengers when there were 30. Running `ANALYZE` keeps these estimates accurate, so the planner's choice reflects reality as the data grows.
