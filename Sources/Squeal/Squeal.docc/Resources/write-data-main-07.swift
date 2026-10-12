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

let rename = SQL
    .UPDATE(users, SET: (\.name, "Ada Lovelace"))
    .WHERE(\.id == adaId)
    .RETURNING(\.id, \.name)
// UPDATE users SET name = $1 WHERE id = $2 RETURNING id, name

let postId = UUID()

let like = SQL
    .UPDATE(posts, SET: (\.likes, SQLExpr("likes + ?", 1)))
    .WHERE(\.id == postId)
    .RETURNING(\.likes)
// UPDATE posts SET likes = likes + $1 WHERE id = $2 RETURNING likes

let publish = SQL
    .UPDATE(posts, SET: (\.published_at, RawSQL("now()")))
    .WHERE(\.id == postId)
// UPDATE posts SET published_at = now() WHERE id = $1

let cleanUp = SQL
    .DELETE(FROM: posts)
    .WHERE(\.author_id == adaId)
    .AND(\.likes < 1)
    .RETURNING(\.id)
// DELETE FROM posts WHERE author_id = $1 AND likes < $2 RETURNING id
