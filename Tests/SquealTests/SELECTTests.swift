//
//  TypedQueryTests.swift
//  
//
//  Created by Sacha Durand Saint Omer on 28/03/2024.
//

import XCTest
@testable import Squeal


@available(macOS 14.0.0, *)
final class SELECTTests: XCTestCase {
    
    let users = UsersTable()
    let trades = TradesTable()
    
    func testSelect1Column() {
        let query = SQL
            .SELECT(\.id, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id FROM users")
        XCTAssertEqual("\(query)", "SELECT id FROM users")
    }
    
    func testSelect2Columns() {
        let query = SQL
            .SELECT(\.id, \.name, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id, name FROM users")
        XCTAssertEqual("\(query)", "SELECT id, name FROM users")
    }
    
    func testSelect3Columns() {
        let query = SQL
            .SELECT([users.uuid, users.id, users.name], FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT uuid, id, name FROM users")
        XCTAssertEqual("\(query)", "SELECT uuid, id, name FROM users")
    }
    
    func testSelectStringColumns() {
        let query = SQL
            .SELECT("uuid, id, name", FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT uuid, id, name FROM users")
        XCTAssertEqual("\(query)", "SELECT uuid, id, name FROM users")
    }
    
    func testSelectVariadicColumns() {
        let query = SQL
            .SELECT(\.uuid, \.id, \.name, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT uuid, id, name FROM users")
        XCTAssertEqual("\(query)", "SELECT uuid, id, name FROM users")
    }

    func testSelectTypesShortKeypath() {
        let query = SQL
            .SELECT(\.name, FROM: users)
        XCTAssert(query.parameters.isEmpty)
        XCTAssertEqual(query.query, "SELECT name FROM users")
        XCTAssertEqual("\(query)", "SELECT name FROM users")
    }
}
