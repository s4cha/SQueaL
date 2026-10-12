# Subqueries

Nest one query inside another, with the selected column's type checked against the column
you filter.

## Overview

A `SELECT` of a single key path, such as `SQL.SELECT(\.author_id).FROM(posts)`, records the
column's type (here `UUID`). When you filter with `IN`, Squeal checks that type against the
filtered column, so a subquery that returns names can't filter a column of IDs.

Subqueries also keep their own parameters. Squeal renumbers their placeholders to follow
the outer query's placeholders, so you can build a subquery once and reuse it anywhere.

### IN (subquery)

```swift
let popularAuthors = SQL
    .SELECT(\.author_id)
    .FROM(posts)
    .WHERE(\.likes > 1000)

SQL.SELECT(\.name)
    .FROM(users)
    .WHERE(\.age >= 18)
    .AND(\.id, IN: popularAuthors)
// SELECT name FROM users WHERE age >= $1 AND id IN (SELECT author_id FROM posts WHERE likes > $2)
// parameters: [18, 1000]
```

`WHERE(_:IN:)` and `AND(_:IN:)` accept a subquery wherever they accept a list. The
subquery's column type must match the filtered column's type, or that type's non-optional
version for nullable columns.

Subqueries are most useful for conditions a join can't express row by row, such as
aggregates. For example, this query lists posts by authors who have written at least five
posts. To filter on a column of a joined table, pass the column itself:

```swift
let prolificAuthors = SQL
    .SELECT(\.author_id)
    .FROM(posts)
    .GROUP_BY(\.author_id)
    .HAVING(COUNT(*) >= 5)

SQL.SELECT(posts.title, users.name)
    .FROM(posts)
    .JOIN(users, ON: posts.author_id == users.id)
    .WHERE(users.id, IN: prolificAuthors)
// SELECT posts.title, users.name FROM posts JOIN users ON posts.author_id = users.id
//     WHERE users.id IN (SELECT author_id FROM posts GROUP BY author_id HAVING COUNT(*) >= $1)
```

### Subqueries as values

A subquery can provide the value of a column in `UPDATE … SET`:

```swift
SQL.UPDATE(posts, SET: (\.author_id, SQL.SELECT(\.id).FROM(users).WHERE(\.email == "ada@example.com").LIMIT(1)))
    .WHERE(\.id == postId)
// UPDATE posts SET author_id = (SELECT id FROM users WHERE email = $1 LIMIT $2) WHERE id = $3
```

It can also appear in `INSERT … VALUES`, next to plain values:

```swift
SQL.INSERT(INTO: posts,
           columns: \.id, \.author_id, \.title,
           VALUES: postId, SQL.SELECT(\.id).FROM(users).WHERE(\.email == "ada@example.com").LIMIT(1), "Hello")
// INSERT INTO posts (id, author_id, title) VALUES ($1, (SELECT id FROM users WHERE email = $2 LIMIT $3), $4)
```

> Note: A subquery used as a value must return at most one row. That's a Postgres rule, so
> add `LIMIT(1)` or filter on a unique column.

> Warning: Squeal doesn't check a subquery's type against the column it fills in
> `INSERT` or `UPDATE` yet. See <doc:WhatSquealChecks>.
