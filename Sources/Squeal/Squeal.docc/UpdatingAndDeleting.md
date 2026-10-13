# Updating and Deleting

Change and remove rows, and get back the rows you changed.

## Overview

### UPDATE

Pass `(column, value)` pairs to `SET`. Each value is bound as a parameter:

```swift
SQL.UPDATE(users, SET: (\.name, "Ada Lovelace"), (\.age, 37))
    .WHERE(\.id == id)
    .RETURNING(\.id, \.name)
// UPDATE users SET name = $1, age = $2 WHERE id = $3 RETURNING id, name
```

`WHERE` accepts the same conditions as in a `SELECT`, and you can follow it with `AND` and
`OR`. See <doc:SelectingData>.

> Warning: Squeal doesn't yet reject a `SET` value of the wrong type. Postgres reports it when
> the query runs. See <doc:WhatSquealChecks>.

An `UPDATE` must have a `WHERE`. Until you add one, `SQL.UPDATE(…, SET: …)` isn't a query
you can run, so an `UPDATE` that would change every row doesn't compile:

```swift
try await client.query(SQL.UPDATE(users, SET: (\.name, "Ada")))
// error: 'query(_:logger:file:line:)' is unavailable: Add a WHERE clause:
//        this UPDATE would change every row. …
```

To update every row on purpose, say so with `.WHERE(SQLExpr("true"))`.

#### Computed values

To set a column from its current value or from a database function, use ``SQLExpr`` (with
`?` placeholders for bound values), ``NOW`` for the current time, or ``RawSQL``:

```swift
SQL.UPDATE(posts, SET: (\.likes, SQLExpr("likes + ?", 1)), (\.published_at, NOW()))
    .WHERE(\.id == postId)
// UPDATE posts SET likes = likes + $1, published_at = now() WHERE id = $2
```

A common pattern is a partial update that keeps the current value when the new one is
`nil`:

```swift
SQL.UPDATE(users, SET: (\.name, SQLExpr("COALESCE(?, name)", newName)))
    .WHERE(\.id == id)
// UPDATE users SET name = COALESCE($1, name) WHERE id = $2
```

You can also set a column from a subquery. See <doc:Subqueries>.

### DELETE

```swift
SQL.DELETE(FROM: posts)
    .WHERE(\.likes < 1)
    .RETURNING(\.id)
// DELETE FROM posts WHERE likes < $1 RETURNING id
```

`SQL.DELETE_FROM(posts)` is equivalent if you prefer a single word.

A `DELETE` must have a `WHERE`. Until you add one, `SQL.DELETE(FROM: posts)` isn't a query
you can run, so a `DELETE` that would remove every row doesn't compile:

```swift
try await client.query(SQL.DELETE(FROM: posts))
// error: 'query(_:logger:file:line:)' is unavailable: Add a WHERE clause:
//        this DELETE would remove every row. …
```

To delete every row on purpose, say so with a condition that's always true:

```swift
SQL.DELETE(FROM: posts).WHERE(SQLExpr("true"))
// DELETE FROM posts WHERE true
```

### RETURNING

After a `WHERE`, `UPDATE` and `DELETE` both accept `RETURNING`, the same way `INSERT` does:
key paths, `*`, or table columns mixed with ``RawSQL``:

```swift
SQL.UPDATE(users, SET: (\.name, "Ada"))
    .WHERE(\.id == id)
    .RETURNING(users.id, RawSQL("length(name)"))
// UPDATE users SET name = $1 WHERE id = $2 RETURNING users.id, length(name)
```

## Topics

### Write Queries

- ``TypedUpdateSQLQuery``
- ``DeleteSQLQuery``
- ``TypedDeleteSQLQuery``
- ``TypedSQLQuery``
