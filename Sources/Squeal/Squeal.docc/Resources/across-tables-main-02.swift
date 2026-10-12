import Squeal

let feed = SQL
    .SELECT(posts.title, users.name)
    .FROM(posts)
    .JOIN(users, ON: posts.author_id == users.id)
    .WHERE(users.age >= 18)
    .ORDER_BY(posts.likes, .DESC)
    .LIMIT(50)
// SELECT posts.title, users.name FROM posts JOIN users ON posts.author_id = users.id
//     WHERE users.age >= $1 ORDER BY posts.likes DESC LIMIT $2
