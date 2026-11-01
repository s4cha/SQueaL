//
//  COALESCETests.swift
//  Squeal
//

import Foundation
import Testing
import Squeal

struct COALESCETests {

    let users = UserTable()
    let posts = PostTable()

    @Test
    func valueOrCurrentColumn() {
        let id = UUID()
        let newName: String? = "Ada"
        let query = SQL
            .UPDATE(users, SET: (\.name, COALESCE(newName, users.name)))
            .WHERE(\.id == id)
        #expect(query.query == "UPDATE users SET name = COALESCE($1, users.name) WHERE id = $2")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? String == "Ada")
        #expect(query.parameters[1] as? UUID == id)
    }

    @Test
    func nilValueBindsNULL() {
        let noName: String? = nil
        let query = SQL
            .UPDATE(users, SET: (\.name, COALESCE(noName, users.name)))
            .WHERE(\.id == UUID())
        #expect(query.query == "UPDATE users SET name = COALESCE($1, users.name) WHERE id = $2")
        #expect(query.parameters[0] == nil)
        #expect(query.description.hasPrefix("UPDATE users SET name = COALESCE(NULL, users.name)"))
    }

    @Test
    func nullableColumn() {
        let bio: String? = "Hello"
        let query = SQL
            .UPDATE(users, SET: (\.bio, COALESCE(bio, users.bio)))
            .WHERE(\.id == UUID())
        #expect(query.query == "UPDATE users SET bio = COALESCE($1, users.bio) WHERE id = $2")
        #expect(query.parameters[0] as? String == "Hello")
    }

    @Test
    func mixedWithPlainValuesAndNOW_numbersPlaceholders() {
        let id = UUID()
        let likes: Int? = nil
        let query = SQL
            .UPDATE(posts, SET:
                (\.title, "Fixed"),
                (\.likes, COALESCE(likes, posts.likes)),
                (\.published_at, NOW()))
            .WHERE(\.id == id)
            .RETURNING(\.likes)
        #expect(query.query == "UPDATE posts SET title = $1, likes = COALESCE($2, posts.likes), published_at = now() WHERE id = $3 RETURNING likes")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[0] as? String == "Fixed")
        #expect(query.parameters[1] == nil)
        #expect(query.parameters[2] as? UUID == id)
    }

    @Test
    func partialUpdateOfSeveralColumns() {
        let name: String? = "Ada"
        let age: Int? = nil
        let query = SQL
            .UPDATE(users, SET:
                (\.name, COALESCE(name, users.name)),
                (\.age, COALESCE(age, users.age)))
            .WHERE(\.id == UUID())
        #expect(query.query == "UPDATE users SET name = COALESCE($1, users.name), age = COALESCE($2, users.age) WHERE id = $3")
        #expect(query.parameters.count == 3)
    }
}
