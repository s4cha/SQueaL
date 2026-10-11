# Using Squeal with Hummingbird

Structure a Hummingbird server around Squeal queries and a shared Postgres client.

## Overview

A typical server setup has three parts:

- A single `PostgresClient` that runs for the lifetime of the app.
- A repository type that builds Squeal queries and decodes their rows.
- Routes that call the repository.

The snippets on this page come from `Examples/HummingbirdBlog` in the Squeal repository,
a complete app you can run locally. It's a small JSON API for users and posts.

### Add the dependencies

```swift
dependencies: [
    .package(url: "https://github.com/s4cha/Squeal", from: "0.2.0"),
    .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.25.0"),
    .package(url: "https://github.com/vapor/postgres-nio", from: "1.21.0"),
],
targets: [
    .executableTarget(
        name: "App",
        dependencies: [
            .product(name: "Squeal", package: "Squeal"),
            .product(name: "SquealPostgresNIO", package: "Squeal"),
            .product(name: "Hummingbird", package: "hummingbird"),
            .product(name: "PostgresNIO", package: "postgres-nio"),
        ]
    ),
]
```

### Run the client alongside the server

Create one `PostgresClient` for the whole app. It manages a pool of connections, and it has
to be running before you send it queries. `PostgresClient` is a `Service`, so you can hand it
to Hummingbird with `addServices(_:)`. The client then starts with the server and shuts down
with it:

```swift
let client = PostgresClient(
    configuration: .init(
        host: env["DATABASE_HOST"] ?? "localhost",
        port: env["DATABASE_PORT"].flatMap(Int.init) ?? 5432,
        username: env["DATABASE_USERNAME"] ?? "postgres",
        password: env["DATABASE_PASSWORD"],
        database: env["DATABASE_NAME"] ?? "hummingbird_blog",
        tls: .disable
    ),
    backgroundLogger: logger
)

let router = Router()
addRoutes(to: router, repository: PostgresBlogRepository(client: client, logger: logger))

var app = Application(router: router, configuration: .init(address: .hostname("127.0.0.1", port: 8080)))
app.addServices(client)
try await app.runService()
```

If your app runs several services, such as background workers or metrics, add the client
to a `ServiceGroup` with the others instead.

> Note: Use `tls: .require(…)` for hosted databases. `.disable` is only for a local server.

### Put queries in a repository

Describe what your routes need as a protocol:

```swift
protocol BlogRepository: Sendable {
    func createUser(email: String, name: String) async throws -> User?
    func feed(limit: Int, offset: Int) async throws -> [Post]
    func like(postId: UUID) async throws -> Int?
}
```

Then implement it with Squeal. Each method builds its query, runs it with
`client.query(_:)`, and decodes the rows into a tuple of the selected columns' types:

```swift
struct PostgresBlogRepository: BlogRepository {
    let client: PostgresClient
    let logger: Logger

    func feed(limit: Int, offset: Int) async throws -> [Post] {
        let query = SQL
            .SELECT(posts.id, posts.title, users.name, posts.likes, posts.created_at)
            .FROM(posts)
            .JOIN(users, ON: posts.author_id == users.id)
            .ORDER_BY(posts.created_at, .DESC)
            .LIMIT(limit)
            .OFFSET(offset)
        let rows = try await client.query(query, logger: logger)
        var feed: [Post] = []
        for try await (id, title, authorName, likes, createdAt) in rows.decode((UUID, String, String, Int, Date).self) {
            feed.append(Post(id: id, title: title, authorName: authorName, likes: likes, createdAt: createdAt))
        }
        return feed
    }
}
```

`RETURNING` returns no rows when nothing matched. That gives you a natural way to report a
missing row or a conflict:

```swift
/// Returns the new like count, or `nil` if the post doesn't exist.
func like(postId: UUID) async throws -> Int? {
    let query = SQL
        .UPDATE(posts, SET: (\.likes, SQLExpr("likes + ?", 1)))
        .WHERE(\.id == postId)
        .RETURNING(\.likes)
    let rows = try await client.query(query, logger: logger)
    for try await likes in rows.decode(Int.self) {
        return likes
    }
    return nil
}
```

> Tip: Build queries as local values inside your methods, as shown here. Squeal's query
> types aren't `Sendable`, so a query stored in a global or static constant doesn't compile
> in Swift 6 language mode. Building a query is cheap, so there's nothing to gain from
> caching it.

### Call the repository from routes

Routes only see the protocol, so they stay free of SQL. To test them without a database,
pass in an in-memory fake that conforms to `BlogRepository`.

```swift
func addRoutes(to router: Router<BasicRequestContext>, repository: some BlogRepository) {
    let api = router.group("api")

    api.get("posts") { request, context -> [Post] in
        let page = request.uri.queryParameters.get("page", as: Int.self) ?? 0
        return try await repository.feed(limit: 20, offset: max(page, 0) * 20)
    }

    api.post("posts/:id/like") { request, context -> [String: Int] in
        let id = try context.parameters.require("id", as: UUID.self)
        guard let likes = try await repository.like(postId: id) else {
            throw HTTPError(.notFound)
        }
        return ["likes": likes]
    }
}
```

Every value from a request, such as a path parameter, a query string or a JSON body,
reaches Postgres as a bound parameter. You don't need to escape anything. See
<doc:ParametersAndSafety>.

### Vapor

The same structure works in Vapor. Squeal only needs a `PostgresClient`, which you can run
next to your Vapor application. Alternatively, run `query.query` with `query.parameters`
through the driver you already use. See <doc:EscapeHatches>.
