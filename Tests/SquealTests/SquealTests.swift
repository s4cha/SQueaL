import XCTest
@testable import Squeal

// 1 make it more type safe.
// 2 DRY table names.
// 3 local reasoning / maintenance on DB schema, aka change in one place updates all queries.

// 4 - Changing your table representation breaks Type safe SQL queries.

// -- Danger zone You're going await from RAW SQL into ORM repository
// 5 Desirable ? query shortcuts.


final class squirrelTests: XCTestCase {
    
    let sql = SQLQueryBuilder()
    let users = Users()
    
    func testSelectBare() throws {
        let query = sql.query()
            .SELECT("*")
        XCTAssertEqual(query.raw, "SELECT *")
        
    }
    
    func testSelectAll() {
        let query2 = sql.query()
            .SELECT(.all)
        XCTAssertEqual(query2.raw, "SELECT *")
    }
    
    func testSelectOneColums() {
        let query2 = sql.query()
            .SELECT(users.name)
        XCTAssertEqual(query2.raw, "SELECT name")
    }
    
    func testSelectOneColumnType() {
        let query2 = sql.query(for: users)
            .SELECT(\.name)
        XCTAssertEqual(query2.raw, "SELECT name")
    }
    
    func testSelectTwoColums() {
        let query2 = sql.query()
            .SELECT(users.id, users.name)
        XCTAssertEqual(query2.raw, "SELECT id, name")
    }
    
    func testFrom() throws {
        let query = sql.query()
            .SELECT(.all)
            .FROM(users)
        XCTAssertEqual(query.raw, "SELECT * FROM users")
    }
    
    func testWhereClause() throws {
        let query = sql.query()
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1")
    }
    
    func testWhereEquals() throws {
        let query = sql.query()
            .SELECT("*")
            .FROM("users")
            .WHERE("id", equals: 43)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 43")
    }
    
    func testWhereTypeSafe() throws {
        let query = sql.query(for: users)
            .SELECT(.all)
            .FROM(users)
            .WHERE(\.id, equals: 1)
        print(query)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1")
    }

    func testAnd() throws {
        let query = sql.query()
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .AND("name = 'jack'")
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }
    
    func testAndTypeSafe() throws {
        let query = sql.query(for: users)
            .SELECT(.all)
            .FROM(users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "jack")
        
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }

    
    func testLimit() throws {
        let query = sql.query()
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .AND("name = 'jack'")
            .LIMIT(3)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 3")
    }
    
    func testAndTypeSafeLimit() throws {
        let query =  sql.query(for: users)
            .SELECT(.all)
            .FROM(users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "jack")
            .LIMIT(1)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 1")
    }
    
    func testInsert() {
        let query = sql.query()
            .INSERT(INTO:"users", columns: "name", "email")
            .VALUES("john", "john@bar.com")
        XCTAssertEqual(query.raw, "INSERT INTO users (name, email) VALUES ('john', 'john@bar.com')")
    }
    
    func testDelete() {
        let query = sql.query(for: users)
            .DELETE()
            .FROM(users)
            .WHERE(\.id, equals: 243)
        XCTAssertEqual(query.raw, "DELETE FROM users WHERE id = 243")
    }
    
    // Helpers
    func testAll() {
        let query = sql.query(for: users)
            .all()
        XCTAssertEqual(query.raw, "SELECT * FROM users")
    }
    
    func testTableAll() {
        let query = users.all()
        XCTAssertEqual(query.raw, "SELECT * FROM users")
    }
    
    func testFind() {
        let query = sql.query(for: users)
            .find(\.id, equals: 12)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 12 LIMIT 1")
    }
    
    func testFindTable() {
        let query = users.find(\.id, equals: 12)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 12 LIMIT 1")
    }
    
}


struct Users: Table {
    let tableName = "users"
    let id = Field<Int>(name: "id")
    let name = Field<String>(name: "name")
    //let status = Field<String>(name: "status")
}


//
//    let query = SQLQuery()
//        .SELECT("name", "id")
////        .SELECT(Users.ColumnsEnum.id, .name)

//    let query = SQLQuery(schema: Users.self)
////        .SELECT(.all)
////        .SELECT(keypaths: \Users.name, \Users.name) / TODO
//        .SELECT(\.id)
//        .FROM(Users.self)
 
        
//
///// Example queries
//guard let row = try await db.select().columns("*")
//    .from(tableName)
//    .where("id", .equal, id)
//    .first() else {
//    throw Abort(.notFound)
//}
//return try row.toAdmin()

//func foo() {
//    let sql = SQLQueryBuilder()
//    let q1 = sql.query(for: Admins.self)
//        .SELECT(.all)
//        .FROM(Admins.self)
//        .WHERE(\.id, equals: 12)
//        .LIMIT(1)
//    
//    let q2 = sql.query(for: AdminTokens.self)
//        .SELECT(.all)
//        .FROM(AdminTokens.self)
//        .WHERE(\.value, equals: "token")
//        
////    query.fetchRow()
////    engine.query(query).fetchRows[
//}


//try await db.insert(into: AdminToken.tableName)
//    .columns( "value", "admin_id")
//    .values(SQLBind(value), SQLBind(adminId))
//    .run()


// Where =  like NULL NOT NULL
// OR
// Group by
// Order By
// Having
// UPDATE SET

// PREVENT QUERYS (force order)?

//public enum SQLDirection: SQLExpression {
//    case ascending
//    case descending
//    /// Order in which NULL values come first.
//    case null
//    /// Order in which NOT NULL values come first.
//    case notNull
//    
//    @inlinable
//    public func serialize(to serializer: inout SQLSerializer) {
//        switch self {
//        case .ascending:  serializer.write("ASC")
//        case .descending: serializer.write("DESC")
//        case .null:       serializer.write("NULL")
//        case .notNull:    serializer.write("NOT NULL")
//        }
//    }
//}
//
