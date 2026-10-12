import Squeal

let feed = SQL
    .SELECT(posts.title, users.name)
    .FROM(posts)
    .JOIN(users, ON: posts.author_id == users.id)
    .WHERE(users.age >= 18)
    .ORDER_BY(posts.likes, .DESC)
    .LIMIT(50)
// SELECT posts.title, users.name FROM posts JOIN users ON posts.author_id = users.id
//     WHERE users.age >= $1 ORDER BY posts.likes DESC LIMIT 50

let popularAuthorIds = SQL
    .SELECT(\.author_id)
    .FROM(posts)
    .WHERE(\.likes > 1000)
// SELECT author_id FROM posts WHERE likes > $1

let popularAuthors = SQL
    .SELECT(\.name, \.email)
    .FROM(users)
    .WHERE(\.age > 30)
    .AND(\.id, IN: popularAuthorIds)
// SELECT name, email FROM users WHERE age > $1
//     AND id IN (SELECT author_id FROM posts WHERE likes > $2)

let postsPerAuthor = SQL
    .SELECT(users.name, COUNT(posts.id), SUM(posts.likes))
    .FROM(users)
    .LEFT_JOIN(posts, ON: users.id == posts.author_id)
    .GROUP_BY(\.name)
// SELECT users.name, COUNT(posts.id), SUM(posts.likes) FROM users
//     LEFT JOIN posts ON users.id = posts.author_id GROUP BY name

let prolificAuthors = SQL
    .SELECT(users.name, COUNT(posts.id), SUM(posts.likes))
    .FROM(users)
    .LEFT_JOIN(posts, ON: users.id == posts.author_id)
    .GROUP_BY(\.name)
    .HAVING(COUNT(posts.id) >= 3)
    .ORDER_BY(\.name, .ASC)
// SELECT users.name, COUNT(posts.id), SUM(posts.likes) FROM users
//     LEFT JOIN posts ON users.id = posts.author_id GROUP BY name
//     HAVING COUNT(posts.id) >= $1 ORDER BY name ASC
