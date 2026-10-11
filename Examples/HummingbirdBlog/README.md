# HummingbirdBlog

A small JSON API built with [Hummingbird](https://github.com/hummingbird-project/hummingbird),
[PostgresNIO](https://github.com/vapor/postgres-nio) and Squeal.

It shows the pieces you need in a real server:

- `Schema.swift`: the tables, described with `@Table`.
- `BlogRepository.swift`: what the routes need from storage, as a protocol.
- `PostgresBlogRepository.swift`: that protocol implemented with Squeal queries.
- `Routes.swift`: Hummingbird routes that only know about the protocol.
- `main.swift`: a `PostgresClient` running alongside the server.

## Run it

You need PostgreSQL running locally.

```bash
createdb hummingbird_blog
psql hummingbird_blog -f schema.sql
swift run
```

The server listens on `http://127.0.0.1:8080`. To use another database, set
`DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_USERNAME`, `DATABASE_PASSWORD` and
`DATABASE_NAME`.

## Try it

```bash
# Create a user
curl -X POST localhost:8080/api/users \
  -H 'Content-Type: application/json' \
  -d '{"email": "ada@example.com", "name": "Ada"}'

# Create a post (use the id from the previous response)
curl -X POST localhost:8080/api/posts \
  -H 'Content-Type: application/json' \
  -d '{"authorId": "<user id>", "title": "Hello, world"}'

# Read the feed
curl localhost:8080/api/posts

# Like a post
curl -X POST localhost:8080/api/posts/<post id>/like

# Delete a post
curl -X DELETE localhost:8080/api/posts/<post id>
```

This package depends on Squeal through a relative path, so it always builds against the
checkout it lives in. In your own app, depend on the released package instead:

```swift
.package(url: "https://github.com/s4cha/Squeal", from: "0.2.0"),
```
