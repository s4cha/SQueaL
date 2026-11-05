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
        SELECT(\.id, \.name, \.email)
            .FROM(users)
            .ORDER_BY(\.name, .ASC)
            .LIMIT(20)
    )
    for (id, name, email) in rows {
        print(id, name, email)
    }

    group.cancelAll()
}
