import Squeal

let feed = SQL
    .SELECT(posts.title, users.name)
    .FROM(posts)
    .JOIN(users, ON: posts.author_id == users.id)
// SELECT posts.title, users.name FROM posts JOIN users ON posts.author_id = users.id
