import XCTest
@testable import Squeal

// 1 make it more type safe.
// 2 DRY table names.
// 3 local reasoning / maintenance on DB schema, aka change in one place updates all queries.

// 4 - Changing your table representation breaks Type safe SQL queries.

// -- Danger zone You're going await from RAW SQL into ORM repository
// 5 Desirable ? query shortcuts.


final class squirrelTests: XCTestCase {
    
    let users = UsersTable()
    
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
    
    func testSelectOneColums() {
        let query2 = Squeal.query()
            .SELECT(users.name)
        XCTAssertEqual(query2.raw, "SELECT name")
    }
    
    func testSelectTwoColums() {
        let query2 = Squeal.query()
            .SELECT(users.id, users.name)
        XCTAssertEqual(query2.raw, "SELECT id, name")
    }
    
    func testFrom() throws {
        let query = Squeal.query()
            .SELECT(.all)
            .FROM(users)
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
    
    func testLimit() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .AND("name = 'jack'")
            .LIMIT(3)
        XCTAssertEqual(query.raw, "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 3")
    }
    
    func testInsert() {
        let query = BareSQLQuery(raw: "")
            .INSERT(INTO:"users", columns: "name", "email")
            .VALUES("john", "john@bar.com")
        XCTAssertEqual(query.raw, "INSERT INTO users (name, email) VALUES ('john', 'john@bar.com')")
    }
    
    func testInsertTypeSafe() {
        let query = ""
            .INSERTX(INTO: users, columns: \.name)
//            .INSERTX(INTO: users, columns: \.name)
        
//            .INSERT(INTO:"users", columns: "name", "email")
//            .VALUES("john", "john@bar.com")
//        XCTAssertEqual(query.raw, "INSERT INTO users (name, email) VALUES ('john', 'john@bar.com')")
    }

}


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

