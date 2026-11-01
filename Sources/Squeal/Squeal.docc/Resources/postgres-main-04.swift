import Foundation
import PostgresNIO
import Squeal
import SquealPostgresNIO

let client = PostgresClient(
    configuration: .init(
        host: "localhost",
        port: 5432,
        username: "postgres",
        password: "postgres",
        database: "blog",
        tls: .disable
    )
)

try await withThrowingDiscardingTaskGroup { group in
    group.addTask { await client.run() }

    let rows = try await client.rows(
        SQL
            .SELECT(\.id, \.name, \.email)
            .FROM(users)
            .ORDER_BY(\.name, .ASC)
            .LIMIT(20)
    )
    for (id, name, email) in rows {
        print(id, name, email)
    }

    let insertedId = try await client.firstRow(
        SQL
            .INSERT(INTO: users,
                    columns: \.id, \.email, \.name, \.age,
                    VALUES: UUID(), "ada@example.com", "Ada", 36)
            .ON_CONFLICT(\.email, DO: .NOTHING)
            .RETURNING(\.id),
        as: UUID.self
    )
    if let insertedId {
        print("Created user", insertedId)
    }

    group.cancelAll()
}
