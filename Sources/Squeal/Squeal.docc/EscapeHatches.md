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

### WHERE with a string

`WHERE(_:)` also accepts a string, for conditions Squeal can't express yet:

```swift
SQL.SELECT(\.id).FROM(users).WHERE("bio IS NULL OR email LIKE '%@example.com'")
// SELECT id FROM users WHERE bio IS NULL OR email LIKE '%@example.com'
```

If the string has the form `column <operator> value`, where the operator is `=`, `!=`,
`<`, `<=`, `>` or `>=` with a space on each side, Squeal binds the value as a parameter:

```swift
SQL.SELECT(\.id).FROM(users).WHERE("age >= 18")
// SELECT id FROM users WHERE age >= $1
```

> Warning: Squeal splits the string at the first spaced comparison operator it finds. A
> compound condition that contains one, such as `"(age >= 18 OR bio IS NULL)"`, won't
> produce the SQL you expect. Strings without a spaced comparison operator are inserted
> verbatim and are never parameterized, so don't build them from user input.

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
