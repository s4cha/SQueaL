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

struct NOWComparisonTests {

    let posts = PostTable()
    let users = UserTable()
    let accounts = AccountTable()

    @Test
    func everyOperatorOnAnOptionalDateColumn() {
        let base = SQL.SELECT(\.id).FROM(posts)
        #expect(base.WHERE(\.published_at < NOW()).query == "SELECT id FROM posts WHERE published_at < now()")
        #expect(base.WHERE(\.published_at <= NOW()).query == "SELECT id FROM posts WHERE published_at <= now()")
        #expect(base.WHERE(\.published_at > NOW()).query == "SELECT id FROM posts WHERE published_at > now()")
        #expect(base.WHERE(\.published_at >= NOW()).query == "SELECT id FROM posts WHERE published_at >= now()")
        #expect(base.WHERE(\.published_at == NOW()).query == "SELECT id FROM posts WHERE published_at = now()")
        #expect(base.WHERE(\.published_at != NOW()).query == "SELECT id FROM posts WHERE published_at != now()")
    }

    @Test
    func nonOptionalDateColumn_withCustomColumnName() {
        let query = SQL.SELECT(\.id).FROM(accounts).WHERE(\.createdAt < NOW())
        #expect(query.query == "SELECT id FROM accounts WHERE created_at < now()")
    }

    @Test
    func ANDandOR_bindNothingAndKeepNumbering() {
        let query = SQL
            .SELECT(\.id)
            .FROM(posts)
            .WHERE(\.likes > 3)
            .AND(\.published_at <= NOW())
            .OR(\.title == "Pinned")
            .LIMIT(10)
        #expect(query.query == "SELECT id FROM posts WHERE likes > $1 AND published_at <= now() OR title = $2 LIMIT $3")
        #expect(query.parameters.count == 3)
    }

    @Test
    func qualifiedColumnOnAJoinedTable() {
        let query = SQL
            .SELECT(users.name, posts.title)
            .FROM(users)
            .JOIN(posts, ON: posts.author_id == users.id)
            .WHERE(posts.published_at <= NOW())
            .OR(posts.published_at > NOW())
        #expect(query.query == "SELECT users.name, posts.title FROM users JOIN posts ON posts.author_id = users.id WHERE posts.published_at <= now() OR posts.published_at > now()")
    }

    @Test
    func qualifiedColumnOnTheMainTableStaysQualified() {
        let query = SQL.SELECT(posts.id).FROM(posts).WHERE(posts.published_at <= NOW())
        #expect(query.query == "SELECT posts.id FROM posts WHERE posts.published_at <= now()")
    }

    @Test
    func inUPDATEandDELETE() {
        let update = SQL
            .UPDATE(posts, SET: (\.likes, 0))
            .WHERE(\.published_at > NOW())
            .RETURNING(\.id)
        #expect(update.query == "UPDATE posts SET likes = $1 WHERE published_at > now() RETURNING id")
        let delete = SQL
            .DELETE(FROM: posts)
            .WHERE(\.likes < 1)
            .AND(\.published_at < NOW())
        #expect(delete.query == "DELETE FROM posts WHERE likes < $1 AND published_at < now()")
    }
}

struct INTERVALTests {

    let posts = PostTable()
    let users = UserTable()

    @Test
    func unitsRenderAsPostgresIntervalText() {
        #expect(INTERVAL(1, .YEAR).text == "1 years")
        #expect(INTERVAL(2, .MONTH).text == "2 months")
        #expect(INTERVAL(3, .WEEK).text == "3 weeks")
        #expect(INTERVAL(30, .DAY).text == "30 days")
        #expect(INTERVAL(4, .HOUR).text == "4 hours")
        #expect(INTERVAL(5, .MINUTE).text == "5 minutes")
        #expect(INTERVAL(6, .SECOND).text == "6 seconds")
        #expect(INTERVAL(-7, .DAY).text == "-7 days")
    }

    @Test
    func comparisonBindsTheIntervalAfterExistingParameters() {
        let query = SQL
            .SELECT(\.id)
            .FROM(posts)
            .WHERE(\.likes > 10)
            .AND(\.published_at >= NOW() - INTERVAL(30, .DAY))
            .LIMIT(5)
        #expect(query.query == "SELECT id FROM posts WHERE likes > $1 AND published_at >= now() - $2::interval LIMIT $3")
        #expect(query.parameters.count == 3)
        #expect(query.parameters[1] as? String == "30 days")
        #expect("\(query)" == "SELECT id FROM posts WHERE likes > 10 AND published_at >= now() - '30 days'::interval LIMIT 5")
    }

    @Test
    func chainedIntervals() {
        let query = SQL
            .SELECT(\.id)
            .FROM(posts)
            .WHERE(\.published_at < NOW() - INTERVAL(2, .HOUR) + INTERVAL(30, .MINUTE))
        #expect(query.query == "SELECT id FROM posts WHERE published_at < now() - $1::interval + $2::interval")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? String == "2 hours")
        #expect(query.parameters[1] as? String == "30 minutes")
    }

    @Test
    func qualifiedColumnOnAJoinedTable() {
        let query = SQL
            .SELECT(users.name)
            .FROM(users)
            .JOIN(posts, ON: posts.author_id == users.id)
            .WHERE(posts.published_at > NOW() - INTERVAL(1, .WEEK))
        #expect(query.query == "SELECT users.name FROM users JOIN posts ON posts.author_id = users.id WHERE posts.published_at > now() - $1::interval")
    }

    @Test
    func asAValueInUPDATEandINSERT() {
        let id = UUID()
        let update = SQL
            .UPDATE(posts, SET: (\.title, "Scheduled"), (\.published_at, NOW() + INTERVAL(1, .DAY)))
            .WHERE(\.id == id)
        #expect(update.query == "UPDATE posts SET title = $1, published_at = now() + $2::interval WHERE id = $3")
        #expect(update.parameters.count == 3)
        #expect(update.parameters[1] as? String == "1 days")
        #expect(update.parameters[2] as? UUID == id)
        let insert = SQL.INSERT(INTO: posts, columns: \.id, \.published_at, VALUES: id, NOW() + INTERVAL(2, .HOUR))
        #expect(insert.query == "INSERT INTO posts (id, published_at) VALUES ($1, now() + $2::interval)")
    }
}
