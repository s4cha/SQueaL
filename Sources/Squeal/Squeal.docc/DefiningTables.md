# Defining Tables

Describe your database schema in Swift so the compiler can check every query.

## Overview

Squeal queries take a ``Table``: a type that knows its database table name (its
``Table/schema``) and exposes one ``TableColumn`` per column. Each column carries its Swift
type, so `\.age >= 18` compiles and `\.age >= "eighteen"` doesn't.

### Using the macro

The ``Table(schema:)`` macro is the quickest way to declare a table. Apply it to a struct
whose stored properties match the table's columns:

```swift
@Table(schema: "posts")
struct Post {
    let id: UUID
    let author_id: UUID
    let title: String
    let likes: Int
    let published_at: Date?
}
```

The macro generates a peer type named after the struct with a `Table` suffix:

```swift
struct PostTable: Table {
    static let schema = "posts"
    @Column<UUID>(name: "id") var id
    @Column<UUID>(name: "author_id") var author_id
    @Column<String>(name: "title") var title
    @Column<Int>(name: "likes") var likes
    @Column<Date?>(name: "published_at") var published_at
}
```

The macro's rules:

- Each stored `let` or `var` becomes a column with the same name and type, unless you set
  a different name with ``ColumnName(_:)``.
- Computed properties are skipped.
- Optional properties become nullable columns. You can compare them with `IS_NULL` and
  `IS_NOT_NULL`, and use them in subqueries that return the non-optional type.

The original struct is left as is, so you can also use it as your row model. For example,
make it `Decodable` or decode rows into it.

### Naming columns differently from properties

By default, a property's name is its column's name. When they differ, for example with a
`camelCase` property for a `snake_case` column, mark the property with ``ColumnName(_:)``:

```swift
@Table(schema: "users")
struct User {
    let id: UUID
    @ColumnName("email_address") let email: String
    @ColumnName("created_at") let createdAt: Date
}

SQL.SELECT(\.id, \.email).FROM(users).ORDER_BY(\.createdAt, .DESC)
// SELECT id, email_address FROM users ORDER BY created_at DESC
```

In Swift you keep using the property name, as in `\.email` or `users.email`. Every clause
writes the column name into the SQL.

### Writing a table by hand

The macro is optional. Any type that conforms to ``Table`` works, which is useful if you'd
rather not depend on macros. Pass each column's database name to `Column`:

```swift
struct UsersTable: Table {
    static let schema = "users"
    @Column<UUID>(name: "id") var id
    @Column<String>(name: "email_address") var email
}

SQL.SELECT(\.id, \.email).FROM(UsersTable())
// SELECT id, email_address FROM users
```

`Column` is a typealias for ``TableColumnProperty`` that's available inside any ``Table``.
It wraps a ``TableColumn``.

### Referring to columns

There are two ways to refer to a column, and you can mix them in the same query.

**Key paths** such as `\.name` resolve against the query's main table, the one passed to
`FROM`, `UPDATE`, `INSERT INTO` or `DELETE FROM`. They render unqualified (`name`):

```swift
SQL.SELECT(\.id).FROM(users).WHERE(\.name == "Ada")
// SELECT id FROM users WHERE name = $1
```

**Column values** such as `users.name` render qualified with their table (`users.name`).
Use them for columns from other tables in a join, and anywhere the column could be
ambiguous:

```swift
SQL.SELECT(posts.title, users.name)
    .FROM(posts)
    .JOIN(users, ON: posts.author_id == users.id)
// SELECT posts.title, users.name FROM posts JOIN users ON posts.author_id = users.id
```
