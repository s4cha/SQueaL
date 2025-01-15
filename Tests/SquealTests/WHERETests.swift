//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class WHERETests: XCTestCase {
    
    let users = UsersTable()
    let trades = TradesTable()
    
    func testWhereInt() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1")
    }
    
    func testWhereString() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.name == "Ada")
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? String == "Ada")
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE name = $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE name = 'Ada'")
    }
    
    func testWHEREEqual() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1")
    }
    
    func testWHERESuperior() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id > 42)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 42)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id > $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id > 42")
    }
    
    func testWHERESuperiorOrEqual() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id >= 42)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 42)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id >= $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id >= 42")
    }
    
    func testWHEREInferior() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id < 65)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 65)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id < $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id < 65")
    }
    
    func testWHEREInferiorOrEqual() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id <= 99)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 99)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id <= $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id <= 99")
    }
    
    func testWhereInList() {
        let query = SQL
            .SELECT(*, FROM: users)
            .WHERE(\.name, IN: ["Alice", "Bob", "Charlie"])
        
        XCTAssertEqual(query.parameters.count, 3)
        XCTAssert(query.parameters[0] as? String == "Alice")
        XCTAssert(query.parameters[1] as? String == "Bob")
        XCTAssert(query.parameters[2] as? String == "Charlie")
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE name IN ($1, $2, $3)")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE name IN ('Alice', 'Bob', 'Charlie')")
    }
    
    func testWhereTypeSafeString() throws {
        let query = SQL
            .SELECT(*, FROM: users)
            .WHERE(\.name == "Alice")
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? String == "Alice")
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE name = $1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE name = 'Alice'")
    }
    
    func testWHERELike() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.name, LIKE: "%ob")
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? String == "%ob")
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE name like $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE name like '%ob'")
    }
    
    func testWHERE_IS_NULL() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.name)
            .IS_NULL
        
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE name IS NULL")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE name IS NULL")
    }
    
    func testWHERE_IS_NOT_NULL() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.name)
            .IS_NOT_NULL
        
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE name IS NOT NULL")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE name IS NOT NULL")
    }
    
    func testWhereTypeSafeUUID() throws {
        let uuid = UUID(uuidString: "5DC4AC7B-37C1-4472-B1F6-974B79624FE5")!
        let query = SQL
            .SELECT(*, FROM: users)
            .WHERE(\.uuid == uuid)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? UUID == UUID(uuidString: "5DC4AC7B-37C1-4472-B1F6-974B79624FE5")!)
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE uuid = $1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE uuid = '5DC4AC7B-37C1-4472-B1F6-974B79624FE5'")
    }
    
    // AND
    
    func testWHEREANDEqualSign() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
            .AND(\.name == "Jack")
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssert(query.parameters[1] as? String == "Jack")
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1 AND name = $2")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1 AND name = 'Jack'")
    }
    
    // OR
    
    func testWHEREOREqualSign() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
            .OR(\.name == "john")
        XCTAssertEqual(query.parameters.count, 2)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssert(query.parameters[1] as? String == "john")
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1 OR name = $2")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1 OR name = 'john'")
    }
}
