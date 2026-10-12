# Selecting Data

Read rows with `SELECT`, filter them, then sort, paginate and aggregate.

## Overview

A `SELECT` query is built the same way you'd write it in SQL: `SQL.SELECT`
first, then `FROM`, then optional clauses in SQL order. Each step returns a type that only
offers the clauses allowed next. Once you've written `LIMIT`, autocompletion won't suggest
`WHERE`.

```
SELECT … FROM … [JOIN …] [WHERE … [AND | OR …]] [GROUP BY … [HAVING …]] [ORDER BY …] [LIMIT …] [OFFSET …]
```

The examples on this page use these tables:

```swift
@Table(schema: "users")
struct User {
    let id: UUID
    let email: String
    let name: String
    let age: Int
    let bio: String?
}

@Table(schema: "posts")
struct Post {
    let id: UUID
    let author_id: UUID
    let title: String
    let likes: Int
    let published_at: Date?
}

let users = UserTable()
let posts = PostTable()
```

### Choosing columns

```swift
SQL.SELECT(*).FROM(users)
// SELECT * FROM users

SQL.SELECT(\.id, \.name).FROM(users)
// SELECT id, name FROM users

SQL.SELECT(users.id, users.name).FROM(users)
// SELECT users.id, users.name FROM users

SQL.SELECT_DISTINCT(\.age).FROM(users)
// SELECT DISTINCT age FROM users
```

To rename a column with `AS`, pass `(column, AS: alias)` tuples. Spell out the table type
in the key path, because nothing earlier in the expression tells the compiler which table
you mean:

```swift
SQL.SELECT((\UserTable.id, AS: "user_id"), (\UserTable.name, AS: "username"))
    .FROM(users)
// SELECT id AS user_id, name AS username FROM users
```

Key paths render as bare column names. Columns accessed on a table value (`users.name`)
render qualified with their table, which you need in joins. See <doc:DefiningTables>.

### Filtering with WHERE, AND and OR

Comparisons use Swift operators on columns. The right-hand side must have the column's
type, and it's always bound as a parameter:

```swift
SQL.SELECT(\.id)
    .FROM(users)
    .WHERE(\.age > 17)
    .AND(\.name != "admin")
    .OR(\.email == "ada@example.com")
// SELECT id FROM users WHERE age > $1 AND name != $2 OR email = $3
```

The supported operators are `==`, `!=`, `<`, `<=`, `>` and `>=`. Other conditions have
dedicated labels:

```swift
.WHERE(\.name, IN: ["Ada", "Grace"])     // WHERE name IN ($1, $2)
.WHERE(\.name, NOT_IN: ["root"])         // WHERE name NOT IN ($1)
.WHERE(\.email, LIKE: "%@example.com")   // WHERE email like $1
.WHERE(\.email, NOT_LIKE: "%@test.com")  // WHERE email NOT LIKE $1
.WHERE(\.age, BETWEEN: 18, AND: 65)      // WHERE age BETWEEN $1 AND $2
.WHERE(\.bio).IS_NULL                    // WHERE bio IS NULL
.WHERE(\.bio).IS_NOT_NULL                // WHERE bio IS NOT NULL
```

`AND` and `OR` take a comparison, an `IN:` list or a `LIKE:` pattern. `AND` also accepts an
`IN:` subquery (see <doc:Subqueries>).

> Note: Conditions are appended in the order you write them, without parentheses, so
> Postgres's precedence applies: `AND` binds tighter than `OR`. Squeal can't group
> conditions with parentheses yet.

### Building filters dynamically

Every step is a value, so you can add conditions conditionally. Start with a `WHERE`, then
reassign as you go:

```swift
var query = SQL.SELECT(\.id, \.title).FROM(posts).WHERE(\.title, LIKE: "%swift%")
if let minLikes { query = query.AND(\.likes >= minLikes) }
if let authorId { query = query.AND(\.author_id == authorId) }
// SELECT id, title FROM posts WHERE title like $1 AND likes >= $2   (when only minLikes is set)
```

### Sorting and paginating

```swift
SQL.SELECT(\.id, \.title)
    .FROM(posts)
    .ORDER_BY((\.likes, .DESC), (\.title, .ASC))
    .LIMIT(20)
    .OFFSET(40)
// SELECT id, title FROM posts ORDER BY likes DESC, title ASC LIMIT 20 OFFSET 40
```

`ORDER_BY` also accepts a single column, with or without a direction
(`.ORDER_BY(\.name)` or `.ORDER_BY(\.name, .DESC)`). You can also chain `.ASC` or `.DESC`
after it.

### Aggregating

Use ``COUNT``, ``SUM``, ``AVG``, ``MIN`` and ``MAX`` in `SELECT`, together with
`GROUP_BY` and `HAVING`:

```swift
SQL.SELECT(posts.author_id, COUNT(*), SUM(posts.likes))
    .FROM(posts)
    .GROUP_BY(\.author_id)
    .HAVING("COUNT(*) > 5")
// SELECT posts.author_id, COUNT(*), SUM(posts.likes) FROM posts GROUP BY author_id HAVING COUNT(*) > 5
```

> Warning: `HAVING` takes raw SQL and doesn't bind parameters. Don't build its text from
> user input.

## Topics

### Starting a Query

- ``SQL``
- ``TSQL``

### Expressions

- ``COUNT``
- ``SUM``
- ``AVG``
- ``MIN``
- ``MAX``
- ``OrderByOrder``
