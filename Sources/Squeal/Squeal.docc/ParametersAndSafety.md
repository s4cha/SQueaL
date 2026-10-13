# Parameters and Safety

How Squeal keeps your values out of the SQL text.

## Overview

Every ``SQLQuery`` has two parts:

- ``SQLFragment/query``: the SQL text, with numbered placeholders (`$1`, `$2`, …) where values go.
- ``SQLFragment/parameters``: the values, in placeholder order.

The database receives them separately and never parses a value as SQL. That's what makes
SQL injection impossible, rather than just unlikely:

```swift
let name = "Robert'); DROP TABLE users;--"

let query = SQL.SELECT(\.id).FROM(users).WHERE(\.name == name)

query.query       // SELECT id FROM users WHERE name = $1
query.parameters  // ["Robert'); DROP TABLE users;--"]
```

Values passed to `WHERE`, `AND`, `OR`, `IN`, `LIKE`, `BETWEEN`, `HAVING`, `LIMIT`, `OFFSET`,
`INSERT … VALUES` and `UPDATE … SET` are all bound this way. `nil` becomes `NULL`.

### Placeholders compose

When one query is nested in another, for example a subquery in `IN` or in `SET`, Squeal
renumbers its placeholders so that they follow the outer query's placeholders. You can
build subqueries separately, reuse them, and never count `$n` by hand:

```swift
let popularAuthors = SQL.SELECT(\.author_id).FROM(posts).WHERE(\.likes > 1000)

SQL.SELECT(\.name)
    .FROM(users)
    .WHERE(\.age >= 18)
    .AND(\.id, IN: popularAuthors)
// SELECT name FROM users WHERE age >= $1 AND id IN (SELECT author_id FROM posts WHERE likes > $2)
// parameters: [18, 1000]
```

### Reading queries in logs

A query's `description` (what `print` and string interpolation show) replaces each
placeholder with its value, so you can read the query or paste it into `psql`:

```swift
print(query)
// SELECT id FROM users WHERE name = 'Robert'); DROP TABLE users;--'
```

> Warning: `description` is for humans only. It doesn't escape anything. Always run a
> query with ``SQLFragment/query`` and ``SQLFragment/parameters`` together, which is what
> `SquealPostgresNIO` does.

### What is *not* parameterized

A few APIs take SQL text as is, as escape hatches. Never build their text from user input:

- ``RawSQL``. Use ``SQLExpr`` and its `?` placeholders when an expression needs values.
- The SQL text of an ``SQLExpr``. Its values are bound, so put every value behind a `?`.
- The constraint name in `ON_CONFLICT(ON_CONSTRAINT:)`.
- Table and column names, which come from your ``Table`` definitions.

See <doc:EscapeHatches> for how to use these safely.
