## Unit 4 Query Catalogue

| Query File                        | Requirement / Technique                                                    | Business Question / Description                                                                                                 |
| :-------------------------------- | :------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------ |
| `queries/unit4/q4_1.sql` (Q1)     | Platform-wide Aggregates (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `DISTINCT`) | What are the count, total, average, minimum, and maximum of fares across all bookings, and how many distinct passengers appear? |
| `queries/unit4/q4_1.sql` (Q2)     | Per-Producer Grouping (`GROUP BY`, `ORDER BY DESC`)                        | What is the booking count and average fare for each flight (producer), sorted from most to least bookings?                      |
| `queries/unit4/q4_1.sql` (Q3)     | Volume Filtering (`HAVING`)                                                | Which flights have enough booking volume (at least 5 bookings) for their average fare to be representative?                     |
| `queries/unit4/q4_1.sql` (Q4)     | Two-Dimension Grouping (`GROUP BY` multiple columns)                       | How do booking counts and average fares vary across flights and booking countries (regions) combined?                           |
| `queries/unit4/q4_2.sql` (Part A) | Conditional Aggregation (`SUM(CASE WHEN ... THEN 1 ELSE 0 END)`)           | For each flight, what is the total event count and total failure count in a single pass without a global WHERE filter?          |
| `queries/unit4/q4_2.sql` (Part B) | Subtotals & Grand Totals (`GROUP BY ROLLUP`)                               | What are the regional and status subtotals and platform grand total of bookings without individual detail rows?                 |
| `queries/unit4/q4_2.sql` (Part C) | Two-Step Pipeline (`WITH` CTE + Aggregation)                               | What is the average booking count and fare baseline across established high-volume producers?                                   |

## Unit 5 Query Catalogue

| Query File | Requirement / Technique | Business Question / Description |
| :--- | :--- | :--- |
| `queries/unit5/q5_1.sql` (Q1) | Three-table `INNER JOIN` | For every booking, which passenger made it, on which flight, and when? |
| `queries/unit5/q5_1.sql` (Q2a/Q2b) | Junction-table traversal (`flights` → `flight_routes` → `airports`) | Which flights serve ICN, and which airports do flagged flights 9 and 11 serve? |
| `queries/unit5/q5_1.sql` (Q3) | Self join on `flights` | How do flagged flights compare with peers from the same origin country? |
| `queries/unit5/q5_2.sql` (Part A) | `LEFT JOIN` vs `INNER JOIN` | Which flights does an inner join silently drop, and how many? |
| `queries/unit5/q5_2.sql` (Part B) | `RIGHT JOIN`, `FULL OUTER JOIN` | Do LEFT/RIGHT results match? What gaps exist on both sides of a relationship? |
| `queries/unit5/q5_2.sql` (Part C) | `NOT EXISTS` vs `EXCEPT` | Which flights have never had a booking, and do both methods agree? |
| `queries/unit5/q5_3.sql` (Part A) | `CROSS JOIN` | Does airports × flights equal 5 × 15 = 75 rows? Which pairings are not yet routes? |
| `queries/unit5/q5_3.sql` (Part B) | `EXPLAIN` / `EXPLAIN ANALYZE` | How does PostgreSQL execute the three-table join? |
