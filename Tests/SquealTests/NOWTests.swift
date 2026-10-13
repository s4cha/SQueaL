//
//  NOWTests.swift
//  Squeal
//

import Foundation
import Testing
import Squeal

struct NOWTests {

    let posts = PostTable()

    @Test
    func inSELECT() {
        let query = SQL.SELECT(posts.id, NOW()).FROM(posts)
        #expect(query.query == "SELECT posts.id, now() FROM posts")
        #expect(query.parameters.isEmpty)
    }

    @Test
    func inUPDATE_SET_betweenBoundValues() {
        let id = UUID()
        let query = SQL
            .UPDATE(posts, SET: (\.title, "Hello"), (\.published_at, NOW()), (\.likes, 0))
            .WHERE(\.id == id)
        #expect(query.query == "UPDATE posts SET title = $1, published_at = now(), likes = $2 WHERE id = $3")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[1] as? Int == 0)
        #expect(query.parameters[2] as? UUID == id)
    }

    @Test
    func inINSERT_VALUES() {
        let query = SQL
            .INSERT(INTO: posts, columns: \.id, \.title, \.published_at, VALUES: UUID(), "Hello", NOW())
            .RETURNING(\.id)
        #expect(query.query == "INSERT INTO posts (id, title, published_at) VALUES ($1, $2, now()) RETURNING id")
        #expect(query.parameters.count == 2)
    }

    @Test
    func inMultiRowINSERT() {
        var query = SQL
            .INSERT(INTO: posts, columns: \.title, \.published_at)
            .VALUES("First", NOW())
        query.ADDVALUES("Second", NOW())
        #expect(query.query == "INSERT INTO posts (title, published_at) VALUES ($1, now()), ($2, now())")
        #expect(query.parameters.count == 2)
    }

    @Test
    func inRETURNING() {
        let id = UUID()
        let update = SQL
            .UPDATE(posts, SET: (\.title, "Hello"))
            .WHERE(\.id == id)
            .RETURNING(posts.id, NOW())
        #expect(update.query == "UPDATE posts SET title = $1 WHERE id = $2 RETURNING posts.id, now()")
        let insert = SQL
            .INSERT(INTO: posts, columns: \.id, VALUES: id)
            .RETURNING(posts.id, NOW())
        #expect(insert.query == "INSERT INTO posts (id) VALUES ($1) RETURNING posts.id, now()")
    }
}
