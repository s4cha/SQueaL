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
    
    func testWHEREqualSign() {
        let query = SQL
            .SELECT(\.id, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssertEqual(query.query, "SELECT id FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "SELECT id FROM users WHERE id = 1")
    }
    
    func testWhereTypeSafeInt() throws {
        let query = SQL
            .SELECT(.all, FROM: users)
            .WHERE(\.id == 1)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? Int == 1)
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE id = $1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE id = 1")
    }
    
    func testWhereTypeSafeString() throws {
        let query = SQL
            .SELECT(.all, FROM: users)
            .WHERE(\.name == "Alice")
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? String == "Alice")
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE name = $1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE name = 'Alice'")
    }
    
    func testWhereTypeSafeUUID() throws {
        let uuid = UUID(uuidString: "5DC4AC7B-37C1-4472-B1F6-974B79624FE5")!
        let query = SQL
            .SELECT(.all, FROM: users)
            .WHERE(\.uuid == uuid)
        XCTAssertEqual(query.parameters.count, 1)
        XCTAssert(query.parameters[0] as? UUID == UUID(uuidString: "5DC4AC7B-37C1-4472-B1F6-974B79624FE5")!)
        XCTAssertEqual(query.query, "SELECT * FROM users WHERE uuid = $1")
        XCTAssertEqual("\(query)", "SELECT * FROM users WHERE uuid = '5DC4AC7B-37C1-4472-B1F6-974B79624FE5'")
    }
}
