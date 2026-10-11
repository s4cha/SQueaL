import Foundation
import Squeal

@Table(schema: "users")
struct User {
    let id: UUID
    let email: String
    let name: String
    let age: Int
    let bio: String?
}

@Table(schema: "posts")
struct Post {
    let id: UUID
    let author_id: UUID
    let title: String
    let likes: Int
    let published_at: Date?
}

let users = UserTable()
let posts = PostTable()
