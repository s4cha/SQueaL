# Joins

Combine rows from several tables, with join conditions checked at compile time.

## Overview

Join conditions compare two columns with `==`. Both columns must have the same Swift type,
so joining a `UUID` foreign key to an `Int` primary key won't compile.

```swift
SQL.SELECT(posts.title, users.name)
    .FROM(posts)
    .JOIN(users, ON: posts.author_id == users.id)
    .WHERE(users.age >= 18)
    .ORDER_BY(users.name, .ASC)
// SELECT posts.title, users.name FROM posts JOIN users ON posts.author_id = users.id WHERE users.age >= $1 ORDER BY users.name ASC
```

In a join, refer to columns through table values (`users.name`) rather than key paths
(`\.name`). Table values render qualified with their table, so they work for every joined
table and are never ambiguous.

### Join kinds

```swift
.JOIN(users, ON: …)             // JOIN
.INNER_JOIN(users, ON: …)       // INNER JOIN
.LEFT_JOIN(users, ON: …)        // LEFT JOIN
.RIGHT_JOIN(users, ON: …)       // RIGHT JOIN
.FULL_OUTER_JOIN(users, ON: …)  // FULL OUTER JOIN
```

Every join kind accepts the condition's columns in either order:

```swift
SQL.SELECT(users.name, COUNT(posts.id))
    .FROM(users)
    .LEFT_JOIN(posts, ON: posts.author_id == users.id)
    .GROUP_BY(\.name)
// SELECT users.name, COUNT(posts.id) FROM users LEFT JOIN posts ON posts.author_id = users.id GROUP BY name
```

### Joining several tables

Joins chain, and each condition can refer to the `FROM` table or to any table joined before
it. For example, you can follow a many-to-many relationship through a link table:

```swift
SQL.SELECT(users.name, departments.name)
    .FROM(users)
    .JOIN(users_departments, ON: users_departments.user_id == users.id)
    .JOIN(departments, ON: departments.id == users_departments.department_id)
// SELECT users.name, departments.name FROM users
//     JOIN users_departments ON users_departments.user_id = users.id
//     JOIN departments ON departments.id = users_departments.department_id
```

A join's condition must use a column of the table being joined, and both columns must have
the same type. Squeal doesn't check that the condition's other table is already part of
the query. If it isn't, Postgres reports a missing `FROM`-clause entry when the query runs.

### Filtering and sorting on joined tables

`WHERE`, `AND` and `ORDER_BY` accept columns from any table in the query. These columns
are written qualified:

```swift
.WHERE(users.age >= 18)          // WHERE users.age >= $1
.AND(users.name != "admin")      // AND users.name != $2
.ORDER_BY(users.name, .DESC)     // ORDER BY users.name DESC
.WHERE(users.id, IN: subquery)   // WHERE users.id IN (…)
```

## Topics

### Join Conditions

- ``JOINPredicate``
- ``TableColumnPredicate``
- ``JoinableQuery``
