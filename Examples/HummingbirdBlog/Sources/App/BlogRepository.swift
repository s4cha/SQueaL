import Foundation

/// What the routes need from storage. Routes depend on this protocol, not on Postgres,
/// so tests can swap in an in-memory fake.
protocol BlogRepository: Sendable {
    func createUser(email: String, name: String) async throws -> User?
    func createPost(authorId: UUID, title: String) async throws -> UUID
    func feed(limit: Int, offset: Int) async throws -> [Post]
    func like(postId: UUID) async throws -> Int?
    func deletePost(id: UUID) async throws -> Bool
}
