import Foundation
import Hummingbird
import Logging
import PostgresNIO

let logger = Logger(label: "HummingbirdBlog")
let env = ProcessInfo.processInfo.environment

// One client for the whole app. It keeps a pool of connections.
let client = PostgresClient(
    configuration: .init(
        host: env["DATABASE_HOST"] ?? "localhost",
        port: env["DATABASE_PORT"].flatMap(Int.init) ?? 5432,
        username: env["DATABASE_USERNAME"] ?? "postgres",
        password: env["DATABASE_PASSWORD"],
        database: env["DATABASE_NAME"] ?? "hummingbird_blog",
        tls: .disable
    ),
    backgroundLogger: logger
)

let router = Router()
router.middlewares.add(LogRequestsMiddleware(.info))
addRoutes(to: router, repository: PostgresBlogRepository(client: client, logger: logger))

var app = Application(
    router: router,
    configuration: .init(address: .hostname("127.0.0.1", port: 8080)),
    logger: logger
)
// Runs the Postgres client alongside the server, and shuts both down together.
app.addServices(client)
try await app.runService()
