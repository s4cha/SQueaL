//
//  PostgresClient+Rows.swift
//  Squeal
//

import PostgresNIO
import Squeal
import Logging

extension PostgresClient {

    // MARK: - Rows typed by the query

    /// Runs a query and decodes every row into the types of the columns it selects.
    ///
    /// The row type comes from the query, so decoding can't go out of sync with the `SELECT`:
    ///
    /// ```swift
    /// let users = try await client.rows(SELECT(\.id, \.name).FROM(users).WHERE(\.age >= 18))
    /// // [(UUID, String)]
    /// ```
    ///
    /// This works for `SELECT`s of key paths. For other queries, such as qualified columns,
    /// expressions or `RETURNING`, pass the type with ``rows(_:as:logger:file:line:)``.
    public func rows<Q: TableSQLQuery, First: PostgresDecodable & Sendable, each Rest: PostgresDecodable & Sendable>(
        _ query: Q,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws -> [(First, repeat each Rest)] where Q.Row == (First, repeat each Rest) {
        return try await rows(query, as: (First, repeat each Rest).self, logger: logger, file: file, line: line)
    }

    /// Runs a query and decodes its first row into the types of the columns it selects, or
    /// returns `nil` when there's no row.
    ///
    /// ```swift
    /// let user = try await client.firstRow(SELECT(\.id, \.name).FROM(users).WHERE(\.email == email))
    /// // (UUID, String)?
    /// ```
    public func firstRow<Q: TableSQLQuery, First: PostgresDecodable & Sendable, each Rest: PostgresDecodable & Sendable>(
        _ query: Q,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws -> (First, repeat each Rest)? where Q.Row == (First, repeat each Rest) {
        return try await firstRow(query, as: (First, repeat each Rest).self, logger: logger, file: file, line: line)
    }

    /// This query doesn't carry a row type: it selects qualified columns, expressions or `*`.
    @available(*, unavailable, message: "This query has no row type (qualified columns, expressions or *). Pass the column types: rows(query, as: (UUID, String).self).")
    public func rows<Q: TableSQLQuery>(
        _ query: Q,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws -> [Void] where Q.Row == Void {
        fatalError("unavailable")
    }

    /// This query doesn't carry a row type: it selects qualified columns, expressions or `*`.
    @available(*, unavailable, message: "This query has no row type (qualified columns, expressions or *). Pass the column types: firstRow(query, as: (UUID, String).self).")
    public func firstRow<Q: TableSQLQuery>(
        _ query: Q,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws -> Void? where Q.Row == Void {
        fatalError("unavailable")
    }

    // MARK: - Rows with an explicit type

    /// Runs a query and decodes every row into the given column types, in order.
    ///
    /// Use it for queries whose row type Squeal doesn't know, such as qualified columns,
    /// `RawSQL` expressions, or `RETURNING`:
    ///
    /// ```swift
    /// let rows = try await client.rows(
    ///     SELECT(posts.title, users.name).FROM(posts).JOIN(users, ON: posts.author_id == users.id),
    ///     as: (String, String).self
    /// )
    /// ```
    public func rows<First: PostgresDecodable & Sendable, each Rest: PostgresDecodable & Sendable>(
        _ query: SQLQuery,
        as type: (First, repeat each Rest).Type,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws -> [(First, repeat each Rest)] {
        var rows: [(First, repeat each Rest)] = []
        for try await row in try await self.query(query, logger: logger, file: file, line: line).decode(type) {
            rows.append(row)
        }
        return rows
    }

    /// Runs a query and decodes its first row into the given column types, or returns `nil`
    /// when there's no row.
    ///
    /// ```swift
    /// let id = try await client.firstRow(
    ///     INSERT(INTO: users, columns: \.email, VALUES: email).RETURNING(\.id),
    ///     as: UUID.self
    /// )
    /// ```
    public func firstRow<First: PostgresDecodable & Sendable, each Rest: PostgresDecodable & Sendable>(
        _ query: SQLQuery,
        as type: (First, repeat each Rest).Type,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws -> (First, repeat each Rest)? {
        for try await row in try await self.query(query, logger: logger, file: file, line: line).decode(type) {
            return row
        }
        return nil
    }

    // MARK: - Statements without rows

    /// Runs a query whose rows you don't need, such as an `INSERT`, `UPDATE` or `DELETE`.
    ///
    /// ```swift
    /// try await client.execute(DELETE(FROM: sessions).WHERE(\.expires_at < NOW()))
    /// ```
    public func execute(
        _ query: SQLQuery,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws {
        try await self.query(query, logger: logger, file: file, line: line)
    }

    /// A `DELETE` without `WHERE` can't be run: it would remove every row in the table.
    @available(*, unavailable, message: "Add a WHERE clause: this DELETE would remove every row. To delete all rows on purpose, use .WHERE(SQLExpr(\"true\")).")
    public func execute<T>(
        _ query: TypedDeleteSQLQuery<T>,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws {
        fatalError("unavailable")
    }

    /// An `UPDATE` without `WHERE` can't be run: it would change every row in the table.
    @available(*, unavailable, message: "Add a WHERE clause: this UPDATE would change every row. To update all rows on purpose, use .WHERE(SQLExpr(\"true\")).")
    public func execute<T, Row>(
        _ query: TypedUpdateSQLQuery<T, Row>,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws {
        fatalError("unavailable")
    }
}
