import PostgresNIO
import Squeal
import Logging

extension PostgresClient {
    /// Runs a Squeal query, binding its parameters.
    ///
    /// ```swift
    /// let rows = try await client.query(SQL.SELECT(\.id, \.name).FROM(users).WHERE(\.age >= 18))
    /// for try await (id, name) in rows.decode((UUID, String).self) { … }
    /// ```
    ///
    /// - Parameters:
    ///   - query: The query to run. Its `query` is sent as the statement, and
    ///     its `parameters` are bound to `$1…$n`.
    ///   - logger: The logger for this query. If you don't pass one, PostgresNIO uses the
    ///     client's background logger.
    ///   - file: The file that issued the query, for diagnostics.
    ///   - line: The line that issued the query, for diagnostics.
    /// - Returns: The rows the query produced.
    /// - Throws: ``SquealBindingError`` if a parameter can't be encoded for Postgres, or any
    ///   error PostgresNIO throws while running the query.
    @discardableResult
    public func query(
        _ query: SQLQuery,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws -> PostgresRowSequence {
        var bindings = PostgresBindings(capacity: query.parameters.count)
        for param in query.parameters {
            // Parameters are `(any Encodable)?`, so a nil Optional value (e.g. `Int?.none`)
            // arrives boxed as `.some(Optional<Int>.none)`. Unwrap it fully so it binds as NULL
            // instead of being skipped (which would shift every following bind).
            guard let value = param.flatMap(unwrapOptional) else {
                bindings.appendNull()
                continue
            }
            if let value = value as? any RawRepresentable<String> {
                bindings.append(value.rawValue)
            } else if let value = value as? PostgresThrowingDynamicTypeEncodable {
                try bindings.append(value)
            } else {
                throw SquealBindingError(type: String(describing: type(of: value)))
            }
        }
        let postgresQuery = PostgresQuery(unsafeSQL: query.query, binds: bindings)
        return try await self.query(postgresQuery, logger: logger)
    }
}

extension PostgresClient {
    /// A `DELETE` without `WHERE` can't be run: it would remove every row in the table.
    @available(*, unavailable, message: "Add a WHERE clause: this DELETE would remove every row. To delete all rows on purpose, use .WHERE(SQLExpr(\"true\")).")
    public func query<T>(
        _ query: TypedDeleteSQLQuery<T>,
        logger: Logger? = nil,
        file: String = #fileID,
        line: Int = #line
    ) async throws -> PostgresRowSequence {
        fatalError("unavailable")
    }
}

/// Thrown when a query parameter has no PostgresNIO encoding.
///
/// To bind a custom type, make it conform to PostgresNIO's `PostgresEncodable`, or make it
/// `RawRepresentable` with a `String` raw value.
public struct SquealBindingError: Error, CustomStringConvertible {
    /// The name of the type that couldn't be bound.
    public let type: String
    public var description: String { "Squeal: cannot bind parameter of type \(type) to Postgres" }
}

/// Recursively unwraps (possibly nested) Optionals hidden behind `Any`, returning nil for `.none`.
private func unwrapOptional(_ value: Any) -> Any? {
    let mirror = Mirror(reflecting: value)
    guard mirror.displayStyle == .optional else { return value }
    guard let wrapped = mirror.children.first?.value else { return nil }
    return unwrapOptional(wrapped)
}
