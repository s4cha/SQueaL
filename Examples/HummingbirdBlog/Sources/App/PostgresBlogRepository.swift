import Foundation
import Logging
import PostgresNIO
import Squeal
import SquealPostgresNIO

/// `BlogRepository` backed by Postgres. Each method builds a Squeal query and runs it with
/// SquealPostgresNIO's `rows`, `firstRow` or `execute`, which decode rows into tuples.
struct PostgresBlogRepository: BlogRepository {
    let client: PostgresClient
    let logger: Logger

    /// Returns `nil` if the email is already taken.
    func createUser(email: String, name: String) async throws -> User? {
        let query = INSERT(INTO: users,
                    columns: \.id, \.email, \.name,
                    VALUES: UUID(), email, name)
            .ON_CONFLICT(\.email, DO: .NOTHING)
            .RETURNING(\.id, \.email, \.name)
        let row = try await client.firstRow(query, as: (UUID, String, String).self, logger: logger)
        return row.map { User(id: $0.0, email: $0.1, name: $0.2) }
    }

    func createPost(authorId: UUID, title: String) async throws -> UUID {
        let id = UUID()
        let query = INSERT(INTO: posts,
                           columns: \.id, \.author_id, \.title,
                           VALUES: id, authorId, title)
        try await client.execute(query, logger: logger)
        return id
    }

    func feed(limit: Int, offset: Int) async throws -> [Post] {
        let query = SELECT(posts.id, posts.title, users.name, posts.likes, posts.created_at)
            .FROM(posts)
            .JOIN(users, ON: posts.author_id == users.id)
            .ORDER_BY(posts.created_at, .DESC)
            .LIMIT(limit)
            .OFFSET(offset)
        let rows = try await client.rows(query, as: (UUID, String, String, Int, Date).self, logger: logger)
        return rows.map { Post(id: $0.0, title: $0.1, authorName: $0.2, likes: $0.3, createdAt: $0.4) }
    }

    /// Returns the new like count, or `nil` if the post doesn't exist.
    func like(postId: UUID) async throws -> Int? {
        let query = UPDATE(posts, SET: (\.likes, SQLExpr("likes + ?", 1)))
            .WHERE(\.id == postId)
            .RETURNING(\.likes)
        return try await client.firstRow(query, as: Int.self, logger: logger)
    }

    func deletePost(id: UUID) async throws -> Bool {
        let query = DELETE(FROM: posts)
            .WHERE(\.id == id)
            .RETURNING(\.id)
        return try await client.firstRow(query, as: UUID.self, logger: logger) != nil
    }
}
