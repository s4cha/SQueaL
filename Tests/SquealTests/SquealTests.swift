import XCTest
@testable import Squeal

// 1 make it more type safe.
// 2 DRY table names.
// 3 local reasoning / maintenance on DB schema, aka change in one place updates all queries.

// 4 - Changing your table representation breaks Type safe SQL queries.

// -- Danger zone You're going await from RAW SQL into ORM repository
// 5 Desirable ? query shortcuts.


final class squirrelTests: XCTestCase {
    
//    let sql = SQLQueryBuilder()
    
    func testSelectBare() throws {
        let query = ""
            .SELECT("*")
        XCTAssertEqual(query.raw, "SELECT *")
    }
    
    func testSelectAll() {
        let query2 = ""
            .SELECT(.all)
        XCTAssertEqual(query2.raw, "SELECT *")
    }
    
    func testTypesafeFullQuery() {
        let query = TypedSQLQuery(for: DB.users)
            .SELECT(\.id)
//            .FROM(DB.users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "Jack")
        XCTAssertEqual(query.raw, "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    func testSelectTypesShortKeypath() {
        let query2 = TypedSQLQuery(for: DB.users)
            .SELECT(\.name)
        XCTAssertEqual(query2.raw, "SELECT name FROM users")
    }
    
    func testSelectOneColums() {
        let query2 = Squeal.query()
            .SELECT(DB.users.name)
        XCTAssertEqual(query2.raw, "SELECT name")
    }
    
    func testSelectOneColumnType() {
        let query2 = TypedSQLQuery(for: DB.users)
            .SELECT(\.name)
        XCTAssertEqual(query2.raw, "SELECT name FROM users")
    }
    
    func testSelectTwoColums() {
        let query2 = Squeal.query()
            .SELECT(DB.users.id, DB.users.name)
        XCTAssertEqual(query2.raw, "SELECT id, name")
    }
    
    func testFrom() throws {
        let query = Squeal.query()
            .SELECT(.all)
            .FROM(DB.users)
        XCTAssertEqual(query.raw, "SELECT * FROM users")
    }
    
    func testWhereClause() throws {
        let query = Squeal.query()
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1")
    }
    
    func testWhereEquation() throws {

        
        let query = Squeal.query()
            .SELECT("*")
            .FROM("users")
//            .WHERE(v1: "id", op: =, v2: "1")
            .WHERE("id" == 1)
//            .WHERE("id = 1")
        
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1")
    }
    
    func testWhereEquals() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id", equals: 43)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 43")
    }
    
    func testWhereTypeSafe() throws {
        let query = TypedSQLQuery(for: DB.users)
            .SELECT(.all)
            .FROM(DB.users)
            .WHERE(\.id, equals: 1)
        print(query)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1")
    }

    func testAnd() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .AND("name = 'jack'")
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }
    
    func testMultipleAnd() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .AND("name = 'jack'")
            .AND("name = 'john'")
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack' AND name = 'john'")
    }
    
    func testOr() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .OR("id = 3")
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 OR id = 3")
    }
    
    func testAndTypeSafe() throws {
        let query = TypedSQLQuery(for: DB.users)
            .SELECT(.all)
            .FROM(DB.users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "jack")
        
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }

    
    func testLimit() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .AND("name = 'jack'")
            .LIMIT(3)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 3")
    }
    
    func testAndTypeSafeLimit() throws {
        let query = TypedSQLQuery(for: DB.users)
            .SELECT(.all)
            .FROM(DB.users)
            .WHERE(\.id, equals: 1)
            .AND(\.name, equals: "jack")
            .LIMIT(1)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 1")
    }
    
    func testInsert() {
        let query = BareSQLQuery(raw: "")
            .INSERT(INTO:"users", columns: "name", "email")
            .VALUES("john", "john@bar.com")
        XCTAssertEqual(query.raw, "INSERT INTO users (name, email) VALUES ('john', 'john@bar.com')")
    }
    
    func testDelete() {
        let query = TypedSQLQuery(for: DB.users)
            .DELETE()
            .FROM(DB.users)
            .WHERE(\.id, equals: 243)
        XCTAssertEqual(query.raw, "DELETE FROM users WHERE id = 243")
    }
    
    // Helpers
    func testAll() {
        let query = TypedSQLQuery(for: DB.users)
            .all()
        XCTAssertEqual(query.raw, "SELECT * FROM users")
    }
    
    func testTableAll() {
        let query = DB.users.all()
        XCTAssertEqual(query.raw, "SELECT * FROM users")
    }
    
    func testFind() {
        let query = TypedSQLQuery(for: DB.users)
            .find(\.id, equals: 12)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 12 LIMIT 1")
    }
    
    func testFindTable() {
        let query = DB.users.find(\.id, equals: 12)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 12 LIMIT 1")
    }
    
    func testOrderOfcommands() {
        let query = Squeal.query()
            .SELECT("email")
            .FROM("users")
            
        
        XCTAssertEqual(query.raw, "SELECT email FROM users")
            
        
        
    }
    
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

struct DB {
    static let users = UsersTable()
}

struct UsersTable: Table {
    let tableName = "users"
    let id = Field<Int>(name: "id")
    let name = Field<String>(name: "name")
    //let status = Field<String>(name: "status")
}
