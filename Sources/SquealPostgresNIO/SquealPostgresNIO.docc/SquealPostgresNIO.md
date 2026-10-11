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

let rows = try await client.query(
    SQL.SELECT(\.id, \.name)
        .FROM(users)
        .WHERE(\.age >= 18)
        .LIMIT(20)
)

for try await (id, name) in rows.decode((UUID, String).self) {
    print(id, name)
}
```

The query runs as a prepared statement with bound parameters, and its values are never
interpolated into the SQL. See Squeal's Parameters and Safety article for details.

### Binding rules

Each value in the query's `parameters` is bound as follows:

- `nil`, including a `nil` optional such as `Int?.none`, binds as `NULL`.
- Types PostgresNIO can encode (`String`, `Int`, `Double`, `Bool`, `UUID`, `Date`, arrays of
  these, and so on) bind natively.
- A `RawRepresentable` type with a `String` raw value, such as a Swift `enum` backed by a
  Postgres text or enum column, binds its `rawValue`.

Any other type throws ``SquealBindingError`` before the query is sent.

### Using it in a server

In Hummingbird or Vapor, create a single `PostgresClient` at startup, run it alongside your
server, and call `query(_:)` from your route handlers. The `Examples/HummingbirdBlog`
package in the Squeal repository is a complete, runnable app that does this. Squeal's
"Using Squeal with Hummingbird" article walks through it.

## Topics

### Running Queries

- ``PostgresNIO/PostgresClient/query(_:logger:file:line:)``

### Errors

- ``SquealBindingError``
