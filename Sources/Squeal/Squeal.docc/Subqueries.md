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

### EXISTS and NOT EXISTS

`EXISTS` filters on whether a subquery returns any row, and `NOT_EXISTS` on whether it
returns none. The subquery usually refers to the outer query's table with a column
comparison, so it runs once per outer row:

```swift
let popularPosts = SQL
    .SELECT(\.id)
    .FROM(posts)
    .WHERE(posts.author_id == users.id)
    .AND(\.likes > 1000)

SQL.SELECT(\.name)
    .FROM(users)
    .WHERE(\.age >= 18)
    .AND(EXISTS(popularPosts))
// SELECT name FROM users WHERE age >= $1
//     AND EXISTS (SELECT id FROM posts WHERE posts.author_id = users.id AND likes > $2)
```

`NOT_EXISTS` finds rows with nothing related, such as users who haven't posted:

```swift
SQL.SELECT(\.name)
    .FROM(users)
    .WHERE(NOT_EXISTS(SQL.SELECT(1).FROM(posts).WHERE(posts.author_id == users.id)))
// SELECT name FROM users WHERE NOT EXISTS (SELECT 1 FROM posts WHERE posts.author_id = users.id)
```

Both work in `WHERE`, `AND` and `OR`, including in `UPDATE` and `DELETE`.

### Subqueries in the SELECT list

Wrap a subquery in ``SUBQUERY`` to select its value as a column. It's usually correlated
with the outer row through a column comparison, for example each user's latest post title:

```swift
let latestTitle = SQL
    .SELECT(\.title)
    .FROM(posts)
    .WHERE(posts.author_id == users.id)
    .ORDER_BY(\.published_at, .DESC)
    .LIMIT(1)

SQL.SELECT(users.name, SUBQUERY(latestTitle)).FROM(users)
// SELECT users.name, (SELECT title FROM posts WHERE posts.author_id = users.id
//     ORDER BY published_at DESC LIMIT $1) FROM users
```

The subquery must return one column and at most one row, and its value is `NULL` when it
returns no row, so decode it as an optional. ``SUBQUERY`` also works in `RETURNING`.

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

The subquery's column type must match the column it fills, so selecting names into an ID
column doesn't compile. A subquery of a nullable column only fits a column of the same
optional type. See <doc:WhatSquealChecks>.
