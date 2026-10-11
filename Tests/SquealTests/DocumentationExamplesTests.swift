//
//  DocumentationExamplesTests.swift
//  Squeal
//
//  Every snippet in Sources/Squeal/Squeal.docc is mirrored here, with the SQL the docs show.
//  If one of these fails, update the matching article too.
//

import Foundation
import Testing
import Squeal

@Table(schema: "users")
struct User {
    let id: UUID
    let email: String
    let name: String
    let age: Int
    let bio: String?
}

@Table(schema: "posts")
struct Post {
    let id: UUID
    let author_id: UUID
    let title: String
    let likes: Int
    let published_at: Date?
}

private let usersTable = UserTable()
private let postsTable = PostTable()

struct DocumentationExamplesTests {

    let userId = UUID(uuidString: "485DBC0B-4C82-4442-BB2A-1879D4E28A14")!
    let postId = UUID(uuidString: "5DC4AC7B-37C1-4472-B1F6-974B79624FE5")!

    // MARK: - Landing page / Getting Started

    @Test
    func gettingStarted() {
        let users = usersTable
        let query = SQL
            .SELECT(\.id, \.name, \.email)
            .FROM(users)
            .WHERE(\.age >= 18)
            .AND(\.name == "Ada")
            .ORDER_BY(\.name, .ASC)
            .LIMIT(10)
        #expect(query.query == "SELECT id, name, email FROM users WHERE age >= $1 AND name = $2 ORDER BY name ASC LIMIT 10")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 18)
        #expect(query.parameters[1] as? String == "Ada")
        #expect("\(query)" == "SELECT id, name, email FROM users WHERE age >= 18 AND name = 'Ada' ORDER BY name ASC LIMIT 10")
    }

    // MARK: - Defining Tables

    @Test
    func handWrittenTable() {
        struct UsersTable: Table {
            static let schema = "users"
            @Column<UUID>(name: "id") var id
            @Column<String>(name: "email_address") var email
        }
        let query = SQL.SELECT(\.id, \.email).FROM(UsersTable())
        #expect(query.query == "SELECT id, email_address FROM users")
    }

    // MARK: - Selecting Data

    @Test
    func selectStar() {
        let users = usersTable
        #expect(SQL.SELECT(*).FROM(users).query == "SELECT * FROM users")
    }

    @Test
    func selectQualifiedColumns() {
        let users = usersTable
        let query = SQL.SELECT(users.id, users.name).FROM(users)
        #expect(query.query == "SELECT users.id, users.name FROM users")
    }

    @Test
    func selectAliases() {
        let users = usersTable
        let query = SQL
            .SELECT((\UserTable.id, AS: "user_id"), (\UserTable.name, AS: "username"))
            .FROM(users)
        #expect(query.query == "SELECT id AS user_id, name AS username FROM users")
    }

    @Test
    func selectDistinct() {
        let users = usersTable
        #expect(SQL.SELECT_DISTINCT(\.age).FROM(users).query == "SELECT DISTINCT age FROM users")
    }

    @Test
    func whereOperators() {
        let users = usersTable
        let query = SQL
            .SELECT(\.id)
            .FROM(users)
            .WHERE(\.age > 17)
            .AND(\.name != "admin")
            .OR(\.email == "ada@example.com")
        #expect(query.query == "SELECT id FROM users WHERE age > $1 AND name != $2 OR email = $3")
    }

    @Test
    func whereInLikeBetweenNull() {
        let users = usersTable
        #expect(SQL.SELECT(*).FROM(users).WHERE(\.name, IN: ["Ada", "Grace"]).query
                == "SELECT * FROM users WHERE name IN ($1, $2)")
        #expect(SQL.SELECT(*).FROM(users).WHERE(\.email, LIKE: "%@example.com").query
                == "SELECT * FROM users WHERE email like $1")
        #expect(SQL.SELECT(*).FROM(users).WHERE(\.age, BETWEEN: 18, AND: 65).query
                == "SELECT * FROM users WHERE age BETWEEN $1 AND $2")
        #expect(SQL.SELECT(*).FROM(users).WHERE(\.bio).IS_NULL.query
                == "SELECT * FROM users WHERE bio IS NULL")
    }

    @Test
    func whereLabelledConditions() {
        let users = usersTable
        let base = SQL.SELECT(\.id).FROM(users)
        #expect(base.WHERE(\.name, NOT_IN: ["root"]).query == "SELECT id FROM users WHERE name NOT IN ($1)")
        #expect(base.WHERE(\.email, NOT_LIKE: "%@test.com").query == "SELECT id FROM users WHERE email NOT LIKE $1")
        #expect(base.WHERE(\.bio).IS_NOT_NULL.query == "SELECT id FROM users WHERE bio IS NOT NULL")
        #expect(base.ORDER_BY(\.name).query == "SELECT id FROM users ORDER BY name")
        #expect(base.ORDER_BY(\.name, .DESC).query == "SELECT id FROM users ORDER BY name DESC")
        #expect(base.ORDER_BY(\.name).DESC.query == "SELECT id FROM users ORDER BY name DESC")
    }

    @Test
    func orderLimitOffset() {
        let posts = postsTable
        let query = SQL
            .SELECT(\.id, \.title)
            .FROM(posts)
            .ORDER_BY((\.likes, .DESC), (\.title, .ASC))
            .LIMIT(20)
            .OFFSET(40)
        #expect(query.query == "SELECT id, title FROM posts ORDER BY likes DESC, title ASC LIMIT 20 OFFSET 40")
    }

    @Test
    func aggregates() {
        let posts = postsTable
        let query = SQL
            .SELECT(posts.author_id, COUNT(*), SUM(posts.likes))
            .FROM(posts)
            .GROUP_BY(\.author_id)
            .HAVING("COUNT(*) > 5")
        #expect(query.query == "SELECT posts.author_id, COUNT(*), SUM(posts.likes) FROM posts GROUP BY author_id HAVING COUNT(*) > 5")
    }

    @Test
    func dynamicFilters() {
        let posts = postsTable
        let minLikes: Int? = 10
        let authorId: UUID? = nil
        var query = SQL.SELECT(\.id, \.title).FROM(posts).WHERE(\.title, LIKE: "%swift%")
        if let minLikes { query = query.AND(\.likes >= minLikes) }
        if let authorId { query = query.AND(\.author_id == authorId) }
        #expect(query.query == "SELECT id, title FROM posts WHERE title like $1 AND likes >= $2")
    }

    // MARK: - Joins

    @Test
    func join() {
        let users = usersTable
        let posts = postsTable
        let query = SQL
            .SELECT(posts.title, users.name)
            .FROM(posts)
            .JOIN(users, ON: posts.author_id == users.id)
            .WHERE(users.age >= 18)
            .ORDER_BY(users.name, .ASC)
        #expect(query.query == "SELECT posts.title, users.name FROM posts JOIN users ON posts.author_id = users.id WHERE users.age >= $1 ORDER BY users.name ASC")
    }

    @Test
    func leftJoin() {
        let users = usersTable
        let posts = postsTable
        let query = SQL
            .SELECT(users.name, COUNT(posts.id))
            .FROM(users)
            .LEFT_JOIN(posts, ON: users.id == posts.author_id)
            .GROUP_BY(\.name)
        #expect(query.query == "SELECT users.name, COUNT(posts.id) FROM users LEFT JOIN posts ON users.id = posts.author_id GROUP BY name")
    }

    @Test
    func joinedTableFilters() {
        let users = usersTable
        let posts = postsTable
        let query = SQL
            .SELECT(posts.title)
            .FROM(posts)
            .JOIN(users, ON: users.id == posts.author_id)
            .WHERE(users.age >= 18)
            .AND(users.name != "admin")
            .ORDER_BY(users.name, .DESC)
        #expect(query.query == "SELECT posts.title FROM posts JOIN users ON users.id = posts.author_id WHERE users.age >= $1 AND users.name != $2 ORDER BY users.name DESC")
    }

    @Test
    func manyToManyJoin() {
        let query = SQL
            .SELECT(users.name, departments.name)
            .FROM(users_departments)
            .JOIN(users, ON: users.uuid == users_departments.user_id)
            .JOIN(departments, ON: departments.id == users_departments.department_id)
        #expect(query.query == "SELECT users.name, departments.name FROM users_departments JOIN users ON users.uuid = users_departments.user_id JOIN departments ON departments.id = users_departments.department_id")
    }

    // MARK: - Subqueries

    @Test
    func whereInSubquery() {
        let users = usersTable
        let posts = postsTable
        let popularAuthors = SQL
            .SELECT(\.author_id)
            .FROM(posts)
            .WHERE(\.likes > 1000)
        let query = SQL
            .SELECT(\.name)
            .FROM(users)
            .WHERE(\.age >= 18)
            .AND(\.id, IN: popularAuthors)
        #expect(query.query == "SELECT name FROM users WHERE age >= $1 AND id IN (SELECT author_id FROM posts WHERE likes > $2)")
        #expect(query.parameters.count == 2)
        #expect(query.parameters[0] as? Int == 18)
        #expect(query.parameters[1] as? Int == 1000)
    }

    @Test
    func updateSetSubquery() {
        let users = usersTable
        let posts = postsTable
        let query = SQL
            .UPDATE(posts, SET: (\.author_id, SQL.SELECT(\.id).FROM(users).WHERE(\.email == "ada@example.com").LIMIT(1)))
            .WHERE(\.id == postId)
        #expect(query.query == "UPDATE posts SET author_id = (SELECT id FROM users WHERE email = $1 LIMIT 1) WHERE id = $2")
    }

    // MARK: - Inserting Data

    @Test
    func insert() {
        let users = usersTable
        let query = SQL
            .INSERT(INTO: users,
                    columns: \.id, \.email, \.name, \.age,
                    VALUES: userId, "ada@example.com", "Ada", 36)
            .RETURNING(\.id)
        #expect(query.query == "INSERT INTO users (id, email, name, age) VALUES ($1, $2, $3, $4) RETURNING id")
    }

    @Test
    func insertMultipleRows() {
        let users = usersTable
        let query = SQL
            .INSERT(INTO: users, columns: \.name, \.age)
            .VALUES("Ada", 36)
            .VALUES("Grace", 45)
        #expect(query.query == "INSERT INTO users (name, age) VALUES ($1, $2), ($3, $4)")
    }

    @Test
    func insertFromSequence() {
        struct NewUser { let name: String; let age: Int }
        let newUsers = [NewUser(name: "Ada", age: 36), NewUser(name: "Grace", age: 45)]
        let users = usersTable
        let query = SQL.INSERT(INTO: users,
                               columns: \.name, \.age,
                               addValuesFrom: newUsers,
                               mapValues: { ($0.name, $0.age) })
        #expect(query.query == "INSERT INTO users (name, age) VALUES ($1, $2), ($3, $4)")
    }

    @Test
    func insertRowsInLoop() {
        struct NewUser { let name: String; let age: Int }
        let newUsers = [NewUser(name: "Ada", age: 36), NewUser(name: "Grace", age: 45)]
        let users = usersTable
        var insert = SQL.INSERT(INTO: users, columns: \.name, \.age)
        for user in newUsers {
            insert.ADDVALUES(user.name, user.age)
        }
        #expect(insert.query == "INSERT INTO users (name, age) VALUES ($1, $2), ($3, $4)")
    }

    @Test
    func insertValueFromSubquery() {
        let users = usersTable
        let posts = postsTable
        let query = SQL.INSERT(INTO: posts,
                               columns: \.id, \.author_id, \.title,
                               VALUES: postId, SQL.SELECT(\.id).FROM(users).WHERE(\.email == "ada@example.com").LIMIT(1), "Hello")
        #expect(query.query == "INSERT INTO posts (id, author_id, title) VALUES ($1, (SELECT id FROM users WHERE email = $2 LIMIT 1), $3)")
        #expect(query.parameters.count == 3)
    }

    @Test
    func joinedColumnInSubquery() {
        let users = usersTable
        let posts = postsTable
        let prolificAuthors = SQL
            .SELECT(\.author_id)
            .FROM(posts)
            .GROUP_BY(\.author_id)
            .HAVING("COUNT(*) >= 5")
        let query = SQL
            .SELECT(posts.title, users.name)
            .FROM(posts)
            .JOIN(users, ON: posts.author_id == users.id)
            .WHERE(users.id, IN: prolificAuthors)
        #expect(query.query == "SELECT posts.title, users.name FROM posts JOIN users ON posts.author_id = users.id WHERE users.id IN (SELECT author_id FROM posts GROUP BY author_id HAVING COUNT(*) >= 5)")
        #expect(query.parameters.isEmpty)
    }

    @Test
    func deleteVariants() {
        let posts = postsTable
        #expect(SQL.DELETE_FROM(posts).WHERE(\.id == postId).query == "DELETE FROM posts WHERE id = $1")
    }

    @Test
    func whereString() {
        let users = usersTable
        #expect(SQL.SELECT(\.id).FROM(users).WHERE("age >= 18").query == "SELECT id FROM users WHERE age >= $1")
        #expect(SQL.SELECT(\.id).FROM(users).WHERE("bio IS NULL OR email LIKE '%@example.com'").query == "SELECT id FROM users WHERE bio IS NULL OR email LIKE '%@example.com'")
        // A string containing a spaced comparison operator is split on it: the right-hand side is bound as one value.
        #expect(SQL.SELECT(\.id).FROM(users).WHERE("(age >= 18 OR bio IS NULL)").query == "SELECT id FROM users WHERE (age >= $1")
    }

    @Test
    func insertOnConflict() {
        let users = usersTable
        let query = SQL
            .INSERT(INTO: users, columns: \.id, \.email, VALUES: userId, "ada@example.com")
            .ON_CONFLICT(\.email, DO: .NOTHING)
            .RETURNING(\.id)
        #expect(query.query == "INSERT INTO users (id, email) VALUES ($1, $2) ON CONFLICT (email) DO NOTHING RETURNING id")
    }

    @Test
    func onConflictTargets() {
        let users = usersTable
        let insert = SQL.INSERT(INTO: users, columns: \.id, \.email, VALUES: userId, "ada@example.com")
        #expect(insert.ON_CONFLICT(DO: .NOTHING).query == "INSERT INTO users (id, email) VALUES ($1, $2) ON CONFLICT DO NOTHING")
        #expect(insert.ON_CONFLICT(ON_CONSTRAINT: "users_email_key", DO: .NOTHING).query == "INSERT INTO users (id, email) VALUES ($1, $2) ON CONFLICT ON CONSTRAINT users_email_key DO NOTHING")
        #expect(insert.ON_CONFLICT(\.email, WHERE: RawSQL("email IS NOT NULL"), DO: .NOTHING).query == "INSERT INTO users (id, email) VALUES ($1, $2) ON CONFLICT (email) WHERE email IS NOT NULL DO NOTHING")
    }

    @Test
    func insertReturningVariants() {
        let users = usersTable
        let insert = SQL.INSERT(INTO: users, columns: \.id, \.email, VALUES: userId, "ada@example.com")
        #expect(insert.RETURNING(\.id, \.email).query.hasSuffix(" RETURNING id, email"))
        #expect(insert.RETURNING(users.id, RawSQL("upper(name)")).query.hasSuffix(" RETURNING users.id, upper(name)"))
        let returningAll = SQL.UPDATE(users, SET: (\.name, "Ada")).WHERE(\.id == userId).RETURNING(*)
        #expect(returningAll.query == "UPDATE users SET name = $1 WHERE id = $2 RETURNING *")
    }

    @Test
    func insertWithExpressions() {
        let posts = postsTable
        let query = SQL.INSERT(INTO: posts,
                               columns: \.id, \.title, \.published_at,
                               VALUES: RawSQL("gen_random_uuid()"), SQLExpr("trim(?)", "  Hello  "), RawSQL("now()"))
        #expect(query.query == "INSERT INTO posts (id, title, published_at) VALUES (gen_random_uuid(), trim($1), now())")
        #expect(query.parameters.count == 1)
    }

    // MARK: - Updating and Deleting

    @Test
    func update() {
        let users = usersTable
        let query = SQL
            .UPDATE(users, SET: (\.name, "Ada Lovelace"), (\.age, 37))
            .WHERE(\.id == userId)
            .RETURNING(\.id, \.name)
        #expect(query.query == "UPDATE users SET name = $1, age = $2 WHERE id = $3 RETURNING id, name")
    }

    @Test
    func updateWithExpressions() {
        let posts = postsTable
        let query = SQL
            .UPDATE(posts, SET: (\.likes, SQLExpr("likes + ?", 1)), (\.published_at, RawSQL("now()")))
            .WHERE(\.id == postId)
        #expect(query.query == "UPDATE posts SET likes = likes + $1, published_at = now() WHERE id = $2")
    }

    @Test
    func partialUpdate() {
        let users = usersTable
        let newName: String? = nil
        let query = SQL.UPDATE(users, SET: (\.name, SQLExpr("COALESCE(?, name)", newName)))
        #expect(query.query == "UPDATE users SET name = COALESCE($1, name)")
        #expect(query.parameters.count == 1)
    }

    @Test
    func tsql() {
        let users = usersTable
        #expect(TSQL<UserTable>.SELECT(\.id, \.name).FROM(users).query == "SELECT id, name FROM users")
    }

    @Test
    func delete() {
        let posts = postsTable
        let query = SQL
            .DELETE(FROM: posts)
            .WHERE(\.likes < 1)
            .RETURNING(\.id)
        #expect(query.query == "DELETE FROM posts WHERE likes < $1 RETURNING id")
    }

    // MARK: - Parameters and Safety

    @Test
    func injectionAttemptIsBound() {
        let users = usersTable
        let name = "Robert'); DROP TABLE users;--"
        let query = SQL.SELECT(\.id).FROM(users).WHERE(\.name == name)
        #expect(query.query == "SELECT id FROM users WHERE name = $1")
        #expect(query.parameters.count == 1)
        #expect(query.parameters[0] as? String == name)
    }

    // MARK: - Escape Hatches

    @Test
    func rawSQLInSelect() {
        let users = usersTable
        let query = SQL.SELECT(users.id, RawSQL("upper(name) AS shout")).FROM(users)
        #expect(query.query == "SELECT users.id, upper(name) AS shout FROM users")
    }

    @Test
    func returningExpressions() {
        let users = usersTable
        let query = SQL
            .UPDATE(users, SET: (\.name, "Ada"))
            .WHERE(\.id == userId)
            .RETURNING(users.id, RawSQL("length(name)"))
        #expect(query.query == "UPDATE users SET name = $1 WHERE id = $2 RETURNING users.id, length(name)")
    }
}
