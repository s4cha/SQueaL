# Getting Started

Add Squeal to your package, describe a table and run your first query.

## Overview

You'll do three things: describe a database table as a Swift struct, build a query from
it, and send that query to Postgres.

### Add the dependency

Add Squeal to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/s4cha/Squeal", from: "0.2.0"),
],
targets: [
    .executableTarget(
        name: "App",
        dependencies: [
            .product(name: "Squeal", package: "Squeal"),
            // Optional: run queries with PostgresNIO.
            .product(name: "SquealPostgresNIO", package: "Squeal"),
        ]
    ),
]
```

The `Squeal` module only builds SQL and has no database dependency. The
`SquealPostgresNIO` module adds a `query(_:)` method to `PostgresClient` that runs Squeal
queries.

### Describe a table

Mark a struct with the ``Table(schema:)`` macro. Pass the name of the database table, and
declare one stored property per column, using the column's name and Swift type:

```swift
import Squeal

@Table(schema: "users")
struct User {
    let id: UUID
    let email: String
    let name: String
    let age: Int
    let bio: String?
}
```

The macro generates a `UserTable` type next to your struct. That's the type you query:

```swift
let users = UserTable()
```

See <doc:DefiningTables> for what the macro generates and how to write a table by hand.

### Build a query

Start from ``SQL`` and chain clauses in the same order you'd write them in SQL. Columns are
key paths, so the compiler rejects a misspelled column or a value of the wrong type:

```swift
let query = SQL
    .SELECT(\.id, \.name, \.email)
    .FROM(users)
    .WHERE(\.age >= 18)
    .AND(\.name == "Ada")
    .ORDER_BY(\.name, .ASC)
    .LIMIT(10)
```

The query holds the SQL text and its parameters separately:

```swift
query.query
// SELECT id, name, email FROM users WHERE age >= $1 AND name = $2 ORDER BY name ASC LIMIT $3

query.parameters
// [18, "Ada", 10]
```

For logging and debugging, `description` inlines the parameters so you can read the query
or paste it into `psql`:

```swift
print(query)
// SELECT id, name, email FROM users WHERE age >= 18 AND name = 'Ada' ORDER BY name ASC LIMIT 10
```

> Important: Only send `query.query` together with `query.parameters` to the database.
> The inlined `description` is for humans, not for execution.

### Run it

With `SquealPostgresNIO`, pass the query straight to a `PostgresClient`. You get PostgresNIO's
usual row sequence back, and you decode rows with its typed `decode` API:

```swift
import PostgresNIO
import SquealPostgresNIO

let client = PostgresClient(configuration: config)

let rows = try await client.query(query)
for try await (id, name, email) in rows.decode((UUID, String, String).self) {
    print(id, name, email)
}
```

`PostgresClient` must be running before you query it. See PostgresNIO's documentation for
how to configure and run a client.

## Next steps

- <doc:SelectingData> covers filters, sorting, pagination and aggregates.
- <doc:Joins> and <doc:Subqueries> show how to combine tables.
- <doc:InsertingData> and <doc:UpdatingAndDeleting> cover writes, upserts and `RETURNING`.
