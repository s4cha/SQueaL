import Foundation
import Logging
import PostgresNIO
import Squeal
import SquealPostgresNIO

/// `BlogRepository` backed by Postgres. Each method builds a Squeal query, runs it with
/// `client.query(_:)` and decodes the rows into tuples of the selected columns' types.
struct PostgresBlogRepository: BlogRepository {
    let client: PostgresClient
    let logger: Logger

    /// Returns `nil` if the email is already taken.
    func createUser(email: String, name: String) async throws -> User? {
        let query = SQL
            .INSERT(INTO: users,
                    columns: \.id, \.email, \.name,
                    VALUES: UUID(), email, name)
            .ON_CONFLICT(\.email, DO: .NOTHING)
            .RETURNING(\.id, \.email, \.name)
        let rows = try await client.query(query, logger: logger)
        for try await (id, email, name) in rows.decode((UUID, String, String).self) {
            return User(id: id, email: email, name: name)
        }
        return nil
    }

    func createPost(authorId: UUID, title: String) async throws -> UUID {
        let id = UUID()
        let query = SQL.INSERT(INTO: posts,
                               columns: \.id, \.author_id, \.title,
                               VALUES: id, authorId, title)
        try await client.query(query, logger: logger)
        return id
    }

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

    func deletePost(id: UUID) async throws -> Bool {
        let query = SQL
            .DELETE(FROM: posts)
            .WHERE(\.id == id)
            .RETURNING(\.id)
        let rows = try await client.query(query, logger: logger)
        for try await _ in rows.decode(UUID.self) {
            return true
        }
        return false
    }
}
