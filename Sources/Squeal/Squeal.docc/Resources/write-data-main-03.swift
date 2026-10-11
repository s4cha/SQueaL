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

let titles = ["Hello, world", "Why I like SQL", "Type-safe queries"]

let newPosts = SQL
    .INSERT(INTO: posts,
            columns: \.id, \.author_id, \.title, \.likes,
            addValuesFrom: titles,
            mapValues: { title in (UUID(), adaId, title, 0) })
// INSERT INTO posts (id, author_id, title, likes)
//     VALUES ($1, $2, $3, $4), ($5, $6, $7, $8), ($9, $10, $11, $12)
