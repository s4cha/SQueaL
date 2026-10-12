import Foundation
import Squeal

// The database schema, as Squeal sees it. Mirrors schema.sql.

@Table(schema: "users")
struct Users {
    let id: UUID
    let email: String
    let name: String
}

@Table(schema: "posts")
struct Posts {
    let id: UUID
    let author_id: UUID
    let title: String
    let likes: Int
    let created_at: Date
}

let users = UsersTable()
let posts = PostsTable()
