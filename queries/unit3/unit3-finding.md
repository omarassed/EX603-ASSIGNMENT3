---
## 1. Executive Summary
This memo documents the findings from an audit of the airline booking dashboard dataset (`ex603_data`). The investigation focused on common SQL pitfalls—specifically three-valued logic (`NULL` handling), logical evaluation order (alias limitations), and query equivalence across multiple syntax patterns. All scripts have been structured, executed, and validated in the workspace under `queries/unit3/`.
---

## 2. Task 3.1: Data Exploration (`q3_1.sql`)

Initial exploration focused on identifying active, high-capacity flights to support dashboard metrics.

- **Filter Criteria:** `is_active = TRUE AND seat_capacity >= 180`
- **Finding:** The query successfully isolated high-capacity commercial flights (such as models with capacities ranging from 193 up to 320 seats), providing a clean foundational subset for subsequent operational queries.

---

## 3. Task 3.2: Bug Identification & Repair (`q3_2.sql`)

### Part A: The Vanishing Rows (Three-Valued Logic)

- **The Problem:** SQL evaluation relies on three-valued logic (`TRUE`, `FALSE`, `UNKNOWN`). Comparisons against `NULL` (`gate != 'Gate A'`) evaluate to `UNKNOWN` rather than `TRUE` or `FALSE`. The `WHERE` clause silently drops these rows without throwing an error or some kind of warning.
- **Demonstration:** Introducing a nullable column (`gate`) with unassigned flights resulted in inequality checks omitting rows silently. Counting omitted records revealed a mismatch against total table rows.
- **The Fix:** Explicitly handling `NULL` values using an inclusive condition (e.g., `OR gate IS NULL`) prevents silent data loss.

### Part B: The Alias Evaluation Order Error

- **The Problem:** Developers often attempt to reference column aliases defined in the `SELECT` clause directly within the `WHERE` clause.
- **Error Encountered:** `ERROR: column "capped_seats" does not exist`
- **Root Cause:** SQL logical processing order evaluates clauses from `FROM` $\rightarrow$ `WHERE` $\rightarrow$ `SELECT`. Because `SELECT` executes _after_ `WHERE`, the alias does not yet exist when the filter is applied.
- **The Fixes:**
  1. Repeat the scalar expression directly inside the `WHERE` clause.
  2. Wrap the query in a Common Table Expression (CTE) or subquery, allowing the outer query to consume the alias as a bona fide column.

---

## 4. Task 3.3: Query Variants & Equivalence Audit (`q3_3.sql`)

To give the dashboard team a reliable query pattern, a two-step question (_"Find all flights that have at least one passenger booking"_) was implemented and audited across three distinct paradigms:

1. **Subquery using `IN`**
2. **Common Table Expression (`WITH`) combined with an inner join**
3. **Correlated Subquery using `EXISTS`**

### Equivalence Validation

Using a set-difference validation pattern (`EXCEPT` combined with `UNION ALL`), the audit proved that all three query structures return **identical result sets** (13 matching records with zero difference rows returned).

### Vulnerability / Equivalence Break Condition

While functionally equivalent under current data conditions, these queries diverge under specific edge cases:

- **The `NULL` Trap with `NOT IN`:** If the query used `NOT IN` instead of `IN` or `EXISTS`, and the subquery returned even a single `NULL` value, the entire predicate evaluates to `UNKNOWN` under three-valued logic, causing the query to return zero rows silently.

---

## 5. Conclusion & Recommendations

1. **Enforce Explicit `NULL` Handling:** Dashboard filters must account for optional fields explicitly to avoid silent under-reporting.
2. **Respect Evaluation Order:** Avoid referencing `SELECT` aliases in `WHERE`; use CTEs for clean, maintainable intermediate states.
3. **Standardize on `EXISTS` / CTEs:** For complex multi-table checks, parameterized CTEs and `EXISTS` clauses offer superior safety against `NULL`-induced logic failures.
