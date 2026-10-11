# Inserting Data

Insert one or many rows, handle conflicts and return generated values.

## Overview

`INSERT` takes the table, the columns, and then the values in the same order. Each value
is bound as a parameter.

```swift
SQL.INSERT(INTO: users,
           columns: \.id, \.email, \.name, \.age,
           VALUES: id, "ada@example.com", "Ada", 36)
    .RETURNING(\.id)
// INSERT INTO users (id, email, name, age) VALUES ($1, $2, $3, $4) RETURNING id
```

> Warning: Squeal doesn't yet reject values of the wrong type, or a different number of
> values than columns. Postgres reports these when the query runs. See <doc:WhatSquealChecks>.

### Inserting several rows

Leave out `VALUES:`, then chain one `VALUES` per row:

```swift
SQL.INSERT(INTO: users, columns: \.name, \.age)
    .VALUES("Ada", 36)
    .VALUES("Grace", 45)
// INSERT INTO users (name, age) VALUES ($1, $2), ($3, $4)
```

To add rows in a loop, use the mutating `ADDVALUES`:

```swift
var insert = SQL.INSERT(INTO: users, columns: \.name, \.age)
for user in newUsers {
    insert.ADDVALUES(user.name, user.age)
}
```

To build the rows from a sequence, pass the sequence and a closure that maps each element
to a row:

```swift
SQL.INSERT(INTO: users,
           columns: \.name, \.age,
           addValuesFrom: newUsers,
           mapValues: { ($0.name, $0.age) })
// INSERT INTO users (name, age) VALUES ($1, $2), ($3, $4)
```

### Handling conflicts

`ON_CONFLICT` adds Postgres's `ON CONFLICT … DO NOTHING` clause. It's useful for
idempotent inserts:

```swift
SQL.INSERT(INTO: users, columns: \.id, \.email, VALUES: id, "ada@example.com")
    .ON_CONFLICT(\.email, DO: .NOTHING)
    .RETURNING(\.id)
// INSERT INTO users (id, email) VALUES ($1, $2) ON CONFLICT (email) DO NOTHING RETURNING id
```

The conflict target can be:

- One or more columns: `.ON_CONFLICT(\.email, DO: .NOTHING)`
- None, which matches any constraint: `.ON_CONFLICT(DO: .NOTHING)`
- A named constraint: `.ON_CONFLICT(ON_CONSTRAINT: "users_email_key", DO: .NOTHING)`
- A partial unique index:
  `.ON_CONFLICT(\.email, WHERE: RawSQL("email IS NOT NULL"), DO: .NOTHING)`

> Note: `DO UPDATE` (upsert) isn't supported yet.

### Using SQL expressions as values

To let the database compute a value, mix ``RawSQL`` and ``SQLExpr`` in with plain values.
`SQLExpr` binds its arguments through `?` placeholders:

```swift
SQL.INSERT(INTO: posts,
           columns: \.id, \.title, \.published_at,
           VALUES: RawSQL("gen_random_uuid()"), SQLExpr("trim(?)", title), RawSQL("now()"))
// INSERT INTO posts (id, title, published_at) VALUES (gen_random_uuid(), trim($1), now())
```

This works well for extension functions such as PostGIS:

```swift
SQLExpr("ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography", longitude, latitude)
```

Values can also come from a subquery. See <doc:Subqueries>.

### Returning values

`RETURNING` accepts key paths, `*`, or a mix of table columns and ``RawSQL`` expressions:

```swift
.RETURNING(\.id)
.RETURNING(\.id, \.email)
.RETURNING(*)
.RETURNING(users.id, RawSQL("upper(name)"))
```

## Topics

### Insert Queries

- ``TypedInsertSQLQuery``
- ``TypedLoneInsertSQLQuery``
- ``OnConflictInsertQuery``
- ``ConflictAction``
