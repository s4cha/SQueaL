# Escape Hatches

Drop down to SQL when Squeal doesn't cover what you need.

## Overview

Squeal covers the queries you write most often, and SQL is much bigger than that. You
shouldn't have to abandon a query, or the library, because one piece of it isn't modeled.
These tools let you write that piece in SQL and keep the rest typed.

### RawSQL

``RawSQL`` inserts a SQL expression verbatim. Use it in `SELECT`, in `RETURNING`, and as a
value in `INSERT` or `UPDATE`:

```swift
SQL.SELECT(users.id, RawSQL("upper(name) AS shout")).FROM(users)
// SELECT users.id, upper(name) AS shout FROM users

SQL.UPDATE(posts, SET: (\.published_at, RawSQL("now()")))
```

### SQLExpr

When an expression needs values, use ``SQLExpr``. Write `?` wherever a value goes. Squeal
replaces each `?` with the next numbered placeholder and binds the value:

```swift
SQLExpr("COALESCE(?, name)", newName)
SQLExpr("ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography", longitude, latitude)
```

`SQLExpr` works anywhere a value does in `INSERT … VALUES` and `UPDATE … SET`.

### Conditions in SQL

`WHERE`, `AND`, `OR` and `HAVING` also accept an ``SQLExpr``, for conditions the typed
comparisons can't express. The most common case is grouping conditions with parentheses:

```swift
SQL.SELECT(\.id)
    .FROM(users)
    .WHERE(\.age >= 18)
    .AND(SQLExpr("(name != ? OR bio IS NULL)", "admin"))
// SELECT id FROM users WHERE age >= $1 AND (name != $2 OR bio IS NULL)
```

The values are bound like any other, and the placeholders are numbered after the ones
already in the query.

### Reading and running the generated SQL

Every query exposes its SQL text and parameters, so you can always hand them to something
else, such as another driver, `EXPLAIN`, or a log line:

```swift
let sql: String = query.query
let values: [(any Encodable)?] = query.parameters
```

`SquealPostgresNIO` does exactly this for PostgresNIO. For another driver, bind
`query.parameters` in order to the placeholders `$1…$n`.

### TSQL

``TSQL`` is the same query builder with the table type fixed up front. It's useful when you
want key paths to resolve before you reach `FROM`:

```swift
TSQL<UserTable>.SELECT(\.id, \.name).FROM(users)
// SELECT id, name FROM users
```
