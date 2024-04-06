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
        XCTAssertEqual("\(query)", "SELECT *")
    }
    
    func testSelectAll() {
        let query = ""
            .SELECT(.all)
        XCTAssertEqual("\(query)", "SELECT *")
    }
    
    func testSelectOneColums() {
        let query = "".SELECT("name")
    
        XCTAssertEqual("\(query)", "SELECT name")
    }
    
    func testSelectTwoColums() {
        let query = ""
            .SELECT("id, name")
        XCTAssertEqual("\(query)", "SELECT id, name")
    }
    
    func testFrom() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
        XCTAssertEqual("\(query)", "SELECT * FROM users")
    }
    
    func testWhereClause() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1")
    }
    
    func testWhereEquation() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
//            .WHERE(v1: "id", op: =, v2: "1")
            .WHERE("id" == 1)
//            .WHERE("id = 1")
        
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1")
    }
    
    func testWhereEquals() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id", equals: 43)
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 43")
    }
    
    func testAnd() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .AND("name = 'jack'")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1 AND name = 'jack'")
    }
    
    func testMultipleAnd() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .AND("name = 'jack'")
            .AND("name = 'john'")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1 AND name = 'jack' AND name = 'john'")
    }
    
    func testOr() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .OR("id = 3")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1 OR id = 3")
    }
    
    func testLimit() throws {
        let query = ""
            .SELECT("*")
            .FROM("users")
            .WHERE("id = 1")
            .AND("name = 'jack'")
            .LIMIT(3)
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1 AND name = 'jack' LIMIT 3")
    }
    
    func testInsert() {
        let query = BareSQLQuery(query: "", parameters: [])
            .INSERT(INTO:"users", columns: "name", "email")
            .VALUES("john", "john@bar.com")
        XCTAssertEqual("\(query)", "INSERT INTO users (name, email) VALUES ('john', 'john@bar.com')")
    }
    
//    func testInsertTypeSafe() {
//        let query = ""
////            .INSERTX(INTO: users, columns: \.name)
////            .INSERTX(INTO: users, columns: \.name)
//        
//            .INSERT(INTO: users, columns: "name", "email",
//                    VALUES: "john", "john@bar.com")
//        XCTAssertEqual(query.raw, "INSERT INTO users (name, email) VALUES ('john', 'john@bar.com')")
//    }

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

