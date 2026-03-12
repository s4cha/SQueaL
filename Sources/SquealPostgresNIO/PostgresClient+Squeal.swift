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
            if let value = param as? any RawRepresentable<String> {
                bindings.append(value.rawValue)
            } else if let value = param as? PostgresThrowingDynamicTypeEncodable {
                try bindings.append(value)
            } else if param == nil {
                bindings.appendNull()
            }
        }
        let postgresQuery = PostgresQuery(unsafeSQL: query.query, binds: bindings)
        return try await self.query(postgresQuery, logger: logger)
    }
}
