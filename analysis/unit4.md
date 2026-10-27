# Unit 4 Analysis & Written Deliverables

## Task 4.1 Write-up: Per-Producer Breakdown & Aggregates

### Who Acts on the Per-Producer Breakdown?

The **Route Operations Manager** or **Fleet Performance Director** is the stakeholder who would act on the per-producer (flight-by-flight) breakdown. They are responsible for monitoring individual flight performance, assessing seating or route profitability, and deciding whether certain underperforming or high-failure routes need operational intervention, rescheduling, or investigation.

### What the Aggregates Hide

- **An average conceals its distribution:** Looking only at the average fare or average performance metric hides the underlying spread. For instance, an average fare of $18.14 can be driven by a uniform distribution of moderate ticket prices or a polarized split of heavily discounted seats and very expensive last-minute bookings.
- **A count conceals who is counted:** A total booking or event count tells us _how much_ volume occurred, but it completely obscures _who_ was involved (i.e., whether the volume is driven by a small handful of frequent flyers/passengers or a wide, diverse base of distinct individuals).

### What We Need to See Next

To move from high-level summaries to actionable decision-making, we need to inspect the **distribution and outliers**—specifically, examining individual failure events, isolating high-volume producers versus low-volume noise, and performing conditional breakdowns (such as separating completed bookings from cancellations or failures) to understand the root causes behind problematic routes.

---

## Task 4.2 Write-up: Advanced Analytical Summaries

### Part A: Two Numbers in One Pass

Our conditional aggregation query answers two side-by-side questions simultaneously for each flight producer:

1. _What is the total event/booking volume handled by this producer?_
2. _How many of those total events resulted in a failure or cancellation state?_
   By computing both columns in a single table scan using `SUM(CASE WHEN ... THEN 1 ELSE 0 END)`, we avoid needing separate filtered queries.

### Part B: Subtotals and a Grand Total

- **Target Reader:** The **Regional Operations Director** needs subtotals per region (`booking_country`) rather than granular detail rows so they can evaluate regional performance without getting bogged down in individual booking records.
- **Decision Supported by the Grand Total:** The platform-wide grand total row provides an absolute baseline benchmark against which individual regional performance and failure rates can be evaluated, supporting executive capital allocation and platform health decisions that regional group rows alone cannot provide.

### Part C: A Two-Step Pipeline

The two-step CTE pipeline answers the following question:
_What is the baseline average booking volume and average fare across established, high-volume producers (flights with at least 5 bookings)?_

---

## Reflection: Conditional Aggregation at Scale (150–250 words)

Conditional aggregation is a powerful technique because it computes multiple metrics across disparate subsets of data in a single pass over the table. By leveraging `CASE` statements inside aggregate functions like `SUM` or `COUNT`, a query can categorize and tally metrics simultaneously without requiring multiple `WHERE` clauses or costly table joins.

At a scale of one million rows, the performance difference between conditional aggregation and running separate filtered queries is profound. Running separate queries forces the database engine to perform multiple full-table scans (or repeated index scans), parsing and filtering millions of records over and over again. In contrast, conditional aggregation evaluates the row conditions on the fly during a single traversal of the dataset, drastically reducing CPU overhead, disk I/O, and memory consumption.

Furthermore, single-pass conditional aggregation guarantees data consistency. When running separate queries against a live, high-volume transactional system, underlying data can change between query executions, leading to race conditions or mismatched totals. Conditional aggregation evaluates all metrics against an identical, point-in-time data snapshot, ensuring logical integrity while optimizing database performance.
