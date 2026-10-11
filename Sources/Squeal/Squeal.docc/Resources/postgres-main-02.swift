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

    // Queries go here.

    group.cancelAll()
}
