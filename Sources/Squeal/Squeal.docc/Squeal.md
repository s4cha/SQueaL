# ``Squeal``

Type-safe SQL for Swift that still reads like SQL.

## Overview

Squeal lets you write PostgreSQL queries in Swift with the same keywords, in the same order,
as the SQL you already know. The compiler checks your column names, your value types and
your clause order. You also get autocompletion that only offers clauses that are valid at
that point in the query.

```swift
let query = SQL
    .SELECT(\.id, \.name, \.email)
    .FROM(users)
    .WHERE(\.age >= 18)
    .AND(\.name == "Ada")
    .ORDER_BY(\.name, .ASC)
    .LIMIT(10)
```

```sql
SELECT id, name, email FROM users WHERE age >= $1 AND name = $2 ORDER BY name ASC LIMIT $3
```

Every value becomes a bound parameter (`$1`, `$2`, …) and is never pasted into the SQL
string, so queries are safe from SQL injection by construction.

Squeal isn't an ORM. It doesn't track objects, generate migrations or hide what runs on your
database. It builds a SQL string and a list of parameters, and you can always see both.
Run them with the companion `SquealPostgresNIO` module or with any Postgres driver.

### Why Squeal?

|                                       | Raw SQL strings | ORMs | Squeal |
|---------------------------------------|:---------------:|:----:|:------:|
| Type-safe columns and values          | ❌              | ✅   | ✅     |
| Autocompletion                        | ❌              | ✅   | ✅     |
| Clause order checked at compile time  | ❌              | ❌   | ✅     |
| No new query language to learn        | ✅              | ❌   | ✅     |
| You see the exact SQL that runs       | ✅              | ❌   | ✅     |

See <doc:WhatSquealChecks> for the full list of mistakes Squeal catches, and the ones it
doesn't catch yet.

## Topics

### Essentials

- <doc:tutorials/SquealTutorials>
- <doc:GettingStarted>
- <doc:DefiningTables>
- <doc:WhatSquealChecks>
- <doc:ParametersAndSafety>
- <doc:UsingWithHummingbird>

### Writing Queries

- <doc:SelectingData>
- <doc:Joins>
- <doc:Subqueries>
- <doc:InsertingData>
- <doc:UpdatingAndDeleting>
- <doc:EscapeHatches>

### Query Entry Points

- ``SQL``
- ``TSQL``

### Schema

- ``Table(schema:)``
- ``ColumnName(_:)``
- ``Table``
- ``TableColumn``
- ``TableColumnProperty``
- ``AnyField``

### Predicates

- ``SQLPredicate``
- ``TableColumnPredicate``
- ``JOINPredicate``
- ``AggregatePredicate``
- ``NOWPredicate``
- ``NOWComparable``

### Selectable Expressions

- ``SelectField``
- ``COUNT``
- ``SUM``
- ``AVG``
- ``MIN``
- ``MAX``
- ``NOW``
- ``INTERVAL``
- ``ShiftedNOW``
- ``DatabaseTimestamp``
- ``SQLAggregate``
- ``RawSQL``
- ``SQLExpr``

### Ordering and Conflicts

- ``OrderByOrder``
- ``ConflictAction``

### Built Queries

- ``SQLQuery``
- ``TableSQLQuery``
- ``SelectSQLQuery``
- ``TypedSelectSQLQuery``
- ``TypedFromSQLQuery``
- ``TypedJOINSQLQuery``
- ``TypedWhereSQLQuery``
- ``PartialTypedWhereSQLQuery``
- ``TypedGroupBySQLQuery``
- ``TypedHavingSQLQuery``
- ``TypedOrderBySQLQuery``
- ``TypedLimitSQLQuery``
- ``TypedOffsetSQLQuery``
- ``TypedInsertSQLQuery``
- ``TypedLoneInsertSQLQuery``
- ``OnConflictInsertQuery``
- ``TypedUpdateSQLQuery``
- ``DeleteSQLQuery``
- ``TypedSQLQuery``

### Clause Capabilities

These protocols decide which clause can follow which, so autocompletion only offers
valid SQL.

- ``FROMableQuery``
- ``FROMableSQLQuery``
- ``JoinableQuery``
- ``WHEREableQuery``
- ``ANDableQuery``
- ``ORableQuery``
- ``GroupByableQuery``
- ``HavingableQuery``
- ``OrderByableQuery``
- ``LimitableQuery``
- ``OffsetableQuery``
- ``WHEREClause``
- ``ANDClause``
- ``ORClause``
- ``OrderByClause``
