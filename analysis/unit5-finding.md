# Leadership Memo: Two Different Problems, Two Different Fixes

**To:** Executive Leadership  
**From:** Trust and Data Team  
**Subject:** What to do about flights that fail often, and flights that never started

---

## The short version

Our last report identified the flights with the highest cancellation rates. This time we linked those flights to their passengers, routes and airports. We also looked for flights that never appeared in the earlier report at all, because they have **no bookings whatsoever**.

There are two separate groups, and they need different responses:

| Group | Flights | What's wrong | Recommended response |
|---|---|---|---|
| **Fails often** | Flight 11 (VN211), Flight 9 (VN209) | People book them, but too many bookings end up cancelled | **Investigate and fix** how the flight is operated |
| **Never started** | Flight 14 (VN214), Flight 15 (VN215) | Listed as active, but no one has ever booked them | **Decide: launch properly or retire** |

## Group 1: Flights that fail often

**What we found**

- **Flight 11** cancels about **1 in 3 bookings** (5 of 16). The other two flights from Japan cancel fewer (25% and 19%), including one that is busier, so the problem isn't simply that Flight 11 is overloaded. It flies to Incheon (ICN), which has the highest cancellation rate of our five airports.
- **Flight 9** cancels **4 of its 14 bookings**. It is **already marked inactive in our system, but people were still booking it.** Customers may be buying seats on a flight that is being phased out and then getting cancelled.

**Recommendation: investigate and fix.** There is real customer demand for these flights, so the goal is to stop losing it.

1. **Flight 9:** stop selling seats on it immediately, or reactivate it on purpose. Rebook affected customers onto another flight serving the same airport (Ho Chi Minh City, SGN, has 8 alternatives).
2. **Flight 11:** have the route manager review the five cancelled bookings and the Incheon operation to find the common cause, and report back within 30 days.

## Group 2: Flights that never started

**What we found**

- **Flights 14 and 15** have been in our catalog since 2022 and are marked **active**, yet received **zero bookings** in 2023.
- **Neither has any route (airport) assigned.** A flight with no destination can't realistically be sold, which is the most likely reason no one booked it.
- These flights were invisible in every earlier report, because those reports only counted flights that had bookings.

**Recommendation: decide to launch properly or retire.** There is no service problem to fix here, because the flights never operated. The question is whether they should exist.

1. Ask network planning to decide for each flight, within 2 weeks: **attach a route and launch it**, or **retire it** and mark it inactive.
2. Add a simple rule: **a flight cannot be listed as active until it has at least one route.** We also found a related gap. **Flight 13** has 11 bookings but no route on record, so the same check should catch that case too.

## What we know vs. what we don't

- **We know** which flights cancel often, which have never been booked, and which have missing route records.
- **We don't yet know *why*.** The data doesn't record why a flight was set up without a route, or why Flight 11's bookings were cancelled. Those answers need conversations with the operations and planning teams.
- **Note on definitions:** this memo counts **cancellations** as failures, matching our previous report. If **disputed** bookings are counted as well, Flights 3 and 1 also exceed 35% and should be added to the review.
