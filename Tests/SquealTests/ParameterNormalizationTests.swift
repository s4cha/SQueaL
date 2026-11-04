//
//  ParameterNormalizationTests.swift
//  Squeal
//
//  Optional values must reach `parameters` unwrapped: `nil`, or the plain value.
//  A value stored as `Optional(Optional(x))` made custom drivers drop it and shift the
//  following placeholders (UPDATE … SET with `Double?` values through the untyped overload).
//

import Foundation
import Testing
import Squeal

/// Whether `value` is an `Optional`, at any depth, rather than a plain value.
private func isWrappedOptional(_ value: (any Encodable)?) -> Bool {
    guard let value else { return false }
    return Mirror(reflecting: value).displayStyle == .optional
}

struct ParameterNormalizationTests {

    let posts = PostTable()
    let users = UserTable()

    @available(*, deprecated, message: "Exercises the deprecated untyped overloads on purpose.")
    @Test
    func UPDATE_SET_untypedOverload_unwrapsOptionalValues() {
        let likes: Int? = 3
        let publishedAt: Date? = nil
        let id = UUID()
        // Mixing in an SQLExpr routes every pair through the untyped `(column, Any)` overload.
        let query = SQL
            .UPDATE(posts, SET: (\.likes, likes as Any), (\.published_at, publishedAt as Any), (\.title, SQLExpr("trim(?)", "x")))
            .WHERE(\.id == id)
        #expect(query.query == "UPDATE posts SET likes = $1, published_at = $2, title = trim($3) WHERE id = $4")
        #expect(query.parameters.count == 4)
        #expect(!query.parameters.contains(where: isWrappedOptional))
        #expect(query.parameters[0] as? Int == 3)
        #expect(query.parameters[1] == nil)
        #expect(query.parameters[3] as? UUID == id)
    }

    @Test
    func UPDATE_SET_typedOverload_withOptionalValues() {
        let bio: String? = "Hello"
        let noBio: String? = nil
        let first = SQL.UPDATE(users, SET: (\.bio, bio)).WHERE(\.id == UUID())
        let second = SQL.UPDATE(users, SET: (\.bio, noBio)).WHERE(\.id == UUID())
        #expect(!first.parameters.contains(where: isWrappedOptional))
        #expect(first.parameters[0] as? String == "Hello")
        #expect(second.parameters[0] == nil)
    }

    @available(*, deprecated, message: "Exercises the deprecated untyped overloads on purpose.")
    @Test
    func INSERT_withOptionalValues() {
        let bio: String? = "Hello"
        let noDate: Date? = nil
        let single = SQL.INSERT(INTO: users, columns: \.name, \.bio, VALUES: "Ada", bio)
        #expect(!single.parameters.contains(where: isWrappedOptional))
        #expect(single.parameters[1] as? String == "Hello")

        let untyped = SQL.INSERT(INTO: posts, columns: \.title, \.published_at, VALUES: "Hi", noDate as Any)
        #expect(!untyped.parameters.contains(where: isWrappedOptional))
        #expect(untyped.parameters[1] == nil)

        var rows = SQL.INSERT(INTO: users, columns: \.name, \.bio).VALUES("Ada", bio)
        rows.ADDVALUES("Grace", Optional<String>.none)
        #expect(rows.query == "INSERT INTO users (name, bio) VALUES ($1, $2), ($3, $4)")
        #expect(!rows.parameters.contains(where: isWrappedOptional))
        #expect(rows.parameters[1] as? String == "Hello")
        #expect(rows.parameters[3] == nil)
    }

    @Test
    func WHERE_andSQLExpr_withOptionalValues() {
        let bio: String? = "Hello"
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.bio == bio)
            .AND(SQLExpr("coalesce(name, ?) != ?", bio, Optional<String>.none))
        #expect(!query.parameters.contains(where: isWrappedOptional))
        #expect(query.parameters[0] as? String == "Hello")
        #expect(query.parameters[2] == nil)
    }

    @available(*, deprecated, message: "Exercises the deprecated untyped overloads on purpose.")
    @Test
    func descriptionShowsPlainValues() {
        let likes: Int? = 3
        let query = SQL.UPDATE(posts, SET: (\.likes, likes as Any), (\.title, SQLExpr("?", "x"))).WHERE(\.id == UUID())
        #expect(query.description.hasPrefix("UPDATE posts SET likes = 3, title = 'x'"))
    }
}
