import Foundation
import Hummingbird

func addRoutes(to router: Router<BasicRequestContext>, repository: some BlogRepository) {
    let api = router.group("api")

    // POST /api/users
    api.post("users") { request, context -> User in
        let body = try await request.decode(as: CreateUserRequest.self, context: context)
        guard let user = try await repository.createUser(email: body.email, name: body.name) else {
            throw HTTPError(.conflict, message: "Email already taken")
        }
        return user
    }

    // GET /api/posts?page=0
    api.get("posts") { request, context -> [Post] in
        let page = request.uri.queryParameters.get("page", as: Int.self) ?? 0
        return try await repository.feed(limit: 20, offset: max(page, 0) * 20)
    }

    // POST /api/posts
    api.post("posts") { request, context -> [String: UUID] in
        let body = try await request.decode(as: CreatePostRequest.self, context: context)
        let id = try await repository.createPost(authorId: body.authorId, title: body.title)
        return ["id": id]
    }

    // POST /api/posts/:id/like
    api.post("posts/:id/like") { request, context -> [String: Int] in
        let id = try context.parameters.require("id", as: UUID.self)
        guard let likes = try await repository.like(postId: id) else {
            throw HTTPError(.notFound)
        }
        return ["likes": likes]
    }

    // DELETE /api/posts/:id
    api.delete("posts/:id") { request, context -> HTTPResponse.Status in
        let id = try context.parameters.require("id", as: UUID.self)
        return try await repository.deletePost(id: id) ? .noContent : .notFound
    }
}
