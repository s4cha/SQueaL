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
    
    func testSelectAll2() {
        let query = SQL
            .SELECT(*, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT * FROM users")
        XCTAssertEqual("\(query)", "SELECT * FROM users")
    }
    
    func testSelectCount() {
        let query = SQL
            .SELECT(COUNT(*), FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT COUNT(*) FROM users")
        XCTAssertEqual("\(query)", "SELECT COUNT(*) FROM users")
    }
    
    func testSelectHeterogeneousList1() {
        let query = SQL
            .SELECT(users.name)
            .FROM(users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT users.name FROM users")
        XCTAssertEqual("\(query)", "SELECT users.name FROM users")
    }
    
    func testSelectHeterogeneousList2() {
        let query = SQL
            .SELECT(users.id, users.name)
            .FROM(users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT users.id, users.name FROM users")
        XCTAssertEqual("\(query)", "SELECT users.id, users.name FROM users")
    }
    
    func testSelectHeterogeneousList3() {
        let query = SQL
            .SELECT(users.id, COUNT(users.name))
            .FROM(users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT users.id, COUNT(users.name) FROM users")
        XCTAssertEqual("\(query)", "SELECT users.id, COUNT(users.name) FROM users")
    }
    
    func testSelectHeterogeneousList4() {
        let query = SQL
            .SELECT(COUNT(*), COUNT(users.name))
            .FROM(users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT COUNT(*), COUNT(users.name) FROM users")
        XCTAssertEqual("\(query)", "SELECT COUNT(*), COUNT(users.name) FROM users")
    }
    
    
    func testSelectCountNameShortKeyPath() {
        let query = SQL
            .SELECT(COUNT(\UsersTable.name), FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT COUNT(name) FROM users")
        XCTAssertEqual("\(query)", "SELECT COUNT(name) FROM users")
    }
    
    func testSelect1Column() {
        let query = SQL
            .SELECT(\.id, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id FROM users")
        XCTAssertEqual("\(query)", "SELECT id FROM users")
    }
    
    func testSelectWithSingleField() {
        let query = SQL
            .SELECT(\UsersTable.id)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id")
        XCTAssertEqual("\(query)", "SELECT id")
    }
    
    func testSelectWithSingleFieldAndFROM() {
        let query = SQL
            .SELECT(\.id)
            
            .FROM(users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id FROM users")
        XCTAssertEqual("\(query)", "SELECT id FROM users")
    }
    
    func testSelectCountWithSingleField() {
        let query = SQL
            .SELECT(COUNT(\UsersTable.id))
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT COUNT(id)")
        XCTAssertEqual("\(query)", "SELECT COUNT(id)")
    }
    
    // TODO
//    func testSelectCountWithSingleFieldAndFROM() {
//        let query = SQL
//            .SELECT(COUNT(\.id))
//            .FROM(users)
//        XCTAssertEqual(query.parameters.count, 0)
//        XCTAssertEqual(query.query, "SELECT COUNT(id) FROM users")
//        XCTAssertEqual("\(query)", "SELECT COUNT(id) FROM users")
//    }

    func testSelect2Columns() {
        let query = SQL
            .SELECT(\.id, \.name, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id, name FROM users")
        XCTAssertEqual("\(query)", "SELECT id, name FROM users")
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
    
    // AS
    func testSelectAS() {
        let query = SQL
            .SELECT((\.id, AS: "user_id"), FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT id AS user_id FROM users")
        XCTAssertEqual("\(query)", "SELECT id AS user_id FROM users")
    }

    func testSelectMultipleAS() {
        let query = SQL
            .SELECT(
                (\.uuid, AS: "unique_id"),
                (\.id, AS: "user_id"),
                (\.name, AS: "username"),
                FROM: users)
        
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT uuid AS unique_id, id AS user_id, name AS username FROM users")
        XCTAssertEqual("\(query)", "SELECT uuid AS unique_id, id AS user_id, name AS username FROM users")
    }
    
    // DISTINCT
    
    func testSELECT_DISTINCT() {
        let query = SQL
            .SELECT_DISTINCT(\.name, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT DISTINCT name FROM users")
        XCTAssertEqual("\(query)", "SELECT DISTINCT name FROM users")
    }
    
    func testMultipleSELECT_DISTINCT() {
        let query = SQL
            .SELECT_DISTINCT(\.id, \.name, FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT DISTINCT id, name FROM users")
        XCTAssertEqual("\(query)", "SELECT DISTINCT id, name FROM users")
    }
    
    func testSELECT_DISTINCTwithAliase() {
        let query = SQL
            .SELECT_DISTINCT((\.name, AS: "username"), FROM: users)
        XCTAssertEqual(query.parameters.count, 0)
        XCTAssertEqual(query.query, "SELECT DISTINCT name AS username FROM users")
        XCTAssertEqual("\(query)", "SELECT DISTINCT name AS username FROM users")
    }
}
    
    
