# Updating and Deleting

Change and remove rows, and get back the rows you changed.

## Overview

### UPDATE

Pass `(column, value)` pairs to `SET`. Each value is bound as a parameter:

```swift
UPDATE(users, SET: (\.name, "Ada Lovelace"), (\.age, 37))
    .WHERE(\.id == id)
    .RETURNING(\.id, \.name)
// UPDATE users SET name = $1, age = $2 WHERE id = $3 RETURNING id, name
```

`WHERE` accepts the same conditions as in a `SELECT`, and you can follow it with `AND` and
`OR`. See <doc:SelectingData>.

> Warning: Squeal doesn't yet reject a `SET` value of the wrong type. Postgres reports it when
> the query runs. See <doc:WhatSquealChecks>.

An `UPDATE` must have a `WHERE`. Until you add one, `UPDATE(…, SET: …)` isn't a query
you can run, so an `UPDATE` that would change every row doesn't compile:

```swift
try await client.query(UPDATE(users, SET: (\.name, "Ada")))
// error: 'query(_:logger:file:line:)' is unavailable: Add a WHERE clause:
//        this UPDATE would change every row. …
```

To update every row on purpose, say so with `.WHERE(SQLExpr("true"))`.

#### Computed values

To set a column from its current value or from a database function, use ``SQLExpr`` (with
`?` placeholders for bound values), ``NOW`` for the current time, or ``RawSQL``:

```swift
UPDATE(posts, SET: (\.likes, SQLExpr("likes + ?", 1)), (\.published_at, NOW()))
    .WHERE(\.id == postId)
// UPDATE posts SET likes = likes + $1, published_at = now() WHERE id = $2
```

#### Partial updates

A common pattern is a partial update, where `nil` means "keep the current value". Use
``COALESCE``, with the new value and the column to fall back to:

```swift
UPDATE(users, SET:
        (\.name, COALESCE(newName, users.name)),
        (\.bio, COALESCE(newBio, users.bio)))
    .WHERE(\.id == id)
// UPDATE users SET name = COALESCE($1, users.name), bio = COALESCE($2, users.bio) WHERE id = $3
```

The new value must have the column's type, and it's bound as a parameter. Write the column
as a table column (`users.name`), because a key path inside a `SET` pair can't tell which
table it belongs to.

If every field of a patch can be `nil`, return early when they all are: an `UPDATE` that
changes nothing still writes a new version of the row.

You can also set a column from a subquery. See <doc:Subqueries>.

### DELETE

```swift
DELETE(FROM: posts)
    .WHERE(\.likes < 1)
    .RETURNING(\.id)
// DELETE FROM posts WHERE likes < $1 RETURNING id
```

`DELETE_FROM(posts)` is equivalent if you prefer a single word.

A `DELETE` must have a `WHERE`. Until you add one, `DELETE(FROM: posts)` isn't a query
you can run, so a `DELETE` that would remove every row doesn't compile:

```swift
try await client.query(DELETE(FROM: posts))
// error: 'query(_:logger:file:line:)' is unavailable: Add a WHERE clause:
//        this DELETE would remove every row. …
```

To delete every row on purpose, say so with a condition that's always true:

```swift
DELETE(FROM: posts).WHERE(SQLExpr("true"))
// DELETE FROM posts WHERE true
```

### RETURNING

After a `WHERE`, `UPDATE` and `DELETE` both accept `RETURNING`, the same way `INSERT` does:
key paths, `*`, or table columns mixed with ``RawSQL``:

```swift
UPDATE(users, SET: (\.name, "Ada"))
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
