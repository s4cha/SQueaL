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

    let rows = try await client.query(
        SQL
            .SELECT(\.id, \.name, \.email)
            .FROM(users)
            .ORDER_BY(\.name, .ASC)
            .LIMIT(20)
    )
    for try await (id, name, email) in rows.decode((UUID, String, String).self) {
        print(id, name, email)
    }

    let inserted = try await client.query(
        SQL
            .INSERT(INTO: users,
                    columns: \.id, \.email, \.name, \.age,
                    VALUES: UUID(), "ada@example.com", "Ada", 36)
            .ON_CONFLICT(\.email, DO: .NOTHING)
            .RETURNING(\.id)
    )
    for try await id in inserted.decode(UUID.self) {
        print("Created user", id)
    }

    group.cancelAll()
}
