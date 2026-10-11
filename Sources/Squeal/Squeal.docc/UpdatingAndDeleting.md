# Updating and Deleting

Change and remove rows, and get back the rows you changed.

## Overview

### UPDATE

Pass `(column, value)` pairs to `SET`. Each value must match its column's type, and each is
bound as a parameter:

```swift
SQL.UPDATE(users, SET: (\.name, "Ada Lovelace"), (\.age, 37))
    .WHERE(\.id == id)
    .RETURNING(\.id, \.name)
// UPDATE users SET name = $1, age = $2 WHERE id = $3 RETURNING id, name
```

`WHERE` accepts the same conditions as in a `SELECT`, and you can follow it with `AND` and
`OR`. See <doc:SelectingData>.

> Warning: An `UPDATE` without a `WHERE` changes every row in the table. Squeal lets you
> write that, just like SQL does.

#### Computed values

To set a column from its current value or from a database function, use ``SQLExpr`` (with
`?` placeholders for bound values) or ``RawSQL``:

```swift
SQL.UPDATE(posts, SET: (\.likes, SQLExpr("likes + ?", 1)), (\.published_at, RawSQL("now()")))
    .WHERE(\.id == postId)
// UPDATE posts SET likes = likes + $1, published_at = now() WHERE id = $2
```

A common pattern is a partial update that keeps the current value when the new one is
`nil`:

```swift
SQL.UPDATE(users, SET: (\.name, SQLExpr("COALESCE(?, name)", newName)))
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
- ``TypedSQLQuery``
