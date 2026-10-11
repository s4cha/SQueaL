import Foundation
import Squeal

let adaId = UUID()

let newUser = SQL
    .INSERT(INTO: users,
            columns: \.id, \.email, \.name, \.age,
            VALUES: adaId, "ada@example.com", "Ada", 36)
    .ON_CONFLICT(\.email, DO: .NOTHING)
    .RETURNING(\.id)
// INSERT INTO users (id, email, name, age) VALUES ($1, $2, $3, $4)
//     ON CONFLICT (email) DO NOTHING RETURNING id
