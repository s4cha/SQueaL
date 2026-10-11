import Foundation
import Hummingbird

struct User: Codable, ResponseEncodable {
    let id: UUID
    let email: String
    let name: String
}

struct Post: Codable, ResponseEncodable {
    let id: UUID
    let title: String
    let authorName: String
    let likes: Int
    let createdAt: Date
}

struct CreateUserRequest: Decodable {
    let email: String
    let name: String
}

struct CreatePostRequest: Decodable {
    let authorId: UUID
    let title: String
}
