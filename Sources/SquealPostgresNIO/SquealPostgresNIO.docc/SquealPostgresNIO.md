# ``SquealPostgresNIO``

Run Squeal queries with PostgresNIO.

## Overview

This module adds one method to `PostgresClient`, `query(_:logger:file:line:)`. It takes any
Squeal query, binds its parameters and returns PostgresNIO's `PostgresRowSequence`:

```swift
import PostgresNIO
import Squeal
import SquealPostgresNIO

let users = UserTable()

let adults = try await client.rows(
    SELECT(\.id, \.name)
        .FROM(users)
        .WHERE(\.age >= 18)
        .LIMIT(20)
)
// [(UUID, String)]
```

The query runs as a prepared statement with bound parameters, and its values are never
interpolated into the SQL. See Squeal's Parameters and Safety article for details.

### Decoding rows

For a `SELECT` of key paths, the query knows its row type, so `rows(_:)` and `firstRow(_:)`
decode into it. Decoding can't go out of sync with the `SELECT`: a wrong type doesn't compile.

```swift
let names: [String] = try await client.rows(SELECT(\.name).FROM(users))
let user = try await client.firstRow(SELECT(\.id, \.name).FROM(users).WHERE(\.email == email))
// (UUID, String)?, nil when no row matches
```

Other queries don't carry a row type: qualified columns, expressions, `*` and `RETURNING`.
Pass the column types instead:

```swift
let feed = try await client.rows(
    SELECT(posts.title, users.name).FROM(posts).JOIN(users, ON: posts.author_id == users.id),
    as: (String, String).self
)
let likes = try await client.firstRow(
    UPDATE(posts, SET: (\.likes, SQLExpr("likes + ?", 1))).WHERE(\.id == postId).RETURNING(\.likes),
    as: Int.self
)
```

Use `execute(_:)` for statements whose rows you don't need, and `query(_:)` for PostgresNIO's
row sequence, for example to stream a large result.

### Binding rules

Each value in the query's `parameters` is bound as follows:

- `nil`, including a `nil` optional such as `Int?.none`, binds as `NULL`.
- Types PostgresNIO can encode (`String`, `Int`, `Double`, `Bool`, `UUID`, `Date`, arrays of
  these, and so on) bind natively.
- A `RawRepresentable` type with a `String` raw value, such as a Swift `enum`, binds its
  `rawValue` without a declared type. Postgres infers the type from where the value is used,
  so the same Swift enum works with a `text` column and with a Postgres enum column, such as
  `CREATE TYPE trade_type AS ENUM ('buy', 'sell')`, without any cast.

Any other type throws ``SquealBindingError`` before the query is sent.

### Using it in a server

In Hummingbird or Vapor, create a single `PostgresClient` at startup, run it alongside your
server, and call `query(_:)` from your route handlers. The `Examples/HummingbirdBlog`
package in the Squeal repository is a complete, runnable app that does this. Squeal's
"Using Squeal with Hummingbird" article walks through it.

## Topics

### Running Queries

- ``PostgresNIO/PostgresClient/rows(_:logger:file:line:)``
- ``PostgresNIO/PostgresClient/firstRow(_:logger:file:line:)``
- ``PostgresNIO/PostgresClient/rows(_:as:logger:file:line:)``
- ``PostgresNIO/PostgresClient/firstRow(_:as:logger:file:line:)``
- ``PostgresNIO/PostgresClient/execute(_:logger:file:line:)``
- ``PostgresNIO/PostgresClient/query(_:logger:file:line:)``

### Errors

- ``SquealBindingError``
