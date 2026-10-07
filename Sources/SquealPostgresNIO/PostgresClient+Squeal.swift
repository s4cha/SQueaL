import PostgresNIO
import Squeal
import Logging

extension PostgresClient {
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

/// Thrown when a query parameter has no PostgresNIO encoding.
public struct SquealBindingError: Error, CustomStringConvertible {
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
